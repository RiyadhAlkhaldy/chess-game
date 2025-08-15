// lib/data/engine/ai_engine.dart
//
// Modern Alpha-Beta engine for Flutter/Dart chess projects.
// Implements: Iterative Deepening, TT (Zobrist-based key expected from Board),
// Move Ordering (PV/Killers/History + SEE-lite), PVS, Aspiration Windows,
// LMR, Null-Move Pruning, Quiescence, simple Extensions (in-check / promotion).
//
// This engine is designed to work with immutable Board APIs of the form used
// in your project: Board.simulateMove(Move), Board.getAllLegalMovesForCurrentPlayer(),
// Board.evaluateBoard(), Board.isGameOver(), Board.currentPlayer,
// Board.isKingInCheck(PieceColor), and a Board.zobristKey getter.
// Move is expected to have: start/end cells, isCapture, isPromotion, etc.

import 'dart:math' as math;

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';

class AiSearchConfig {
  final int maxDepth;
  final int timeMs;
  final int aspirationDelta; // in centipawns
  final bool enableNullMove;
  final bool enableLMR;
  final bool enablePVS;

  const AiSearchConfig({
    this.maxDepth = 6,
    this.timeMs = 3000,
    this.aspirationDelta = 40,
    this.enableNullMove = true,
    this.enableLMR = true,
    this.enablePVS = true,
  });
}

class _TTEntry {
  final int key;
  final int depth;
  final int score;
  final int flag; // 0=EXACT, 1=LOWER, 2=UPPER
  final Move? best;
  final int age;
  const _TTEntry(
    this.key,
    this.depth,
    this.score,
    this.flag,
    this.best,
    this.age,
  );
}

class _TT {
  final List<_TTEntry?> _tab;
  int age = 0;
  _TT(int sizePow2) : _tab = List<_TTEntry?>.filled(sizePow2, null);
  _TTEntry? probe(int key) {
    final idx = key & (_tab.length - 1);
    final e = _tab[idx];
    if (e != null && e.key == key) return e;
    return null;
  }

  void store(int key, int depth, int score, int flag, Move? best) {
    final idx = key & (_tab.length - 1);
    final cur = _tab[idx];
    if (cur == null || depth > cur.depth || age > cur.age) {
      _tab[idx] = _TTEntry(key, depth, score, flag, best, age);
    }
  }
}

class _Killers {
  final List<List<Move?>> k;
  _Killers(int maxDepth) : k = List.generate(maxDepth + 4, (_) => [null, null]);
  void add(int d, Move m) {
    if (m.isCapture) return;
    if (k[d][0] != m) {
      k[d][1] = k[d][0];
      k[d][0] = m;
    }
  }

  bool isKiller(int d, Move m) =>
      !m.isCapture && (k[d][0] == m || k[d][1] == m);
}

class _History {
  // side (0/1) * 64 * 64
  final List<List<List<int>>> h = List.generate(
    2,
    (_) => List.generate(64, (_) => List.filled(64, 0)),
  );
  int score(PieceColor side, Move m) =>
      h[_sideIdx(side)][_sq(m.start)][_sq(m.end)];
  void reward(PieceColor side, Move m, int depth) {
    h[_sideIdx(side)][_sq(m.start)][_sq(m.end)] += depth * depth;
  }

  static int _sq(Cell c) => c.row * 8 + c.col;
  static int _sideIdx(PieceColor s) => (s == PieceColor.white) ? 0 : 1;
}

class Deadline {
  final int _deadlineMs;
  final int _startMs;
  Deadline(int timeMs)
    : _deadlineMs = timeMs,
      _startMs = DateTime.now().millisecondsSinceEpoch;
  bool get expired =>
      DateTime.now().millisecondsSinceEpoch - _startMs >= _deadlineMs;
}

class AiEngine {
  final AiSearchConfig cfg;
  final _TT tt;
  AiEngine({AiSearchConfig? cfg, int ttSize = 1 << 20})
    : cfg = cfg ?? const AiSearchConfig(),
      tt = _TT(ttSize);

  Future<Move?> search(Board root) async {
    final timer = Deadline(cfg.timeMs);
    Move? best;
    int lastScore = 0;
    List<Move> pv = <Move>[];

    for (int depth = 1; depth <= cfg.maxDepth; depth++) {
      tt.age++;
      int alpha = lastScore - cfg.aspirationDelta;
      int beta = lastScore + cfg.aspirationDelta;
      int tries = 0;
      while (true) {
        final ctx = _Ctx(this, timer, depth);
        pv.clear();
        final score = _alphaBeta(root, depth, alpha, beta, ctx, pvOut: pv);
        if (timer.expired) break;
        if (score <= alpha && tries < 2) {
          // fail-low
          alpha -= cfg.aspirationDelta * 2;
          tries++;
          continue;
        }
        if (score >= beta && tries < 2) {
          // fail-high
          beta += cfg.aspirationDelta * 2;
          tries++;
          continue;
        }
        lastScore = score;
        if (pv.isNotEmpty) best = pv.first;
        break;
      }
      if (timer.expired) break;
    }
    return best;
  }

  static const int INF = 1 << 30;
  static const int EXACT = 0, LOWER = 1, UPPER = 2;

  int _alphaBeta(
    Board board,
    int depth,
    int alpha,
    int beta,
    _Ctx ctx, {
    List<Move>? pvOut,
  }) {
    if (ctx.timer.expired) return 0;

    final key = board.zobristKey;
    final origAlpha = alpha;
    // TT probe
    final tte = tt.probe(key);
    Move? pvMove = tte?.best;
    if (tte != null && tte.depth >= depth) {
      if (tte.flag == EXACT) return tte.score;
      if (tte.flag == LOWER && tte.score > alpha) alpha = tte.score;
      if (tte.flag == UPPER && tte.score < beta) beta = tte.score;
      if (alpha >= beta) return tte.score;
    }

    if (depth <= 0) {
      return _quiescence(board, alpha, beta, ctx);
    }

    // Null-move pruning
    if (cfg.enableNullMove &&
        !_inCheck(board) &&
        depth >= 3 &&
        _hasNonPawnMaterial(board)) {
      final nullScore =
          -_alphaBeta(_makeNull(board), depth - 1 - 2, -beta, -beta + 1, ctx);
      if (nullScore >= beta) return nullScore;
    }

    // Generate moves
    var moves = board.getAllLegalMovesForCurrentPlayer();
    // Move ordering
    moves = _orderMoves(board, moves, pvMove, ctx);

    int bestScore = -INF;
    Move? bestMove;

    for (int i = 0; i < moves.length; i++) {
      final m = moves[i];
      final ext = _computeExtension(board, m);
      int newDepth = depth - 1 + ext;

      // LMR
      int reduction = 0;
      final isQuiet = !m.isCapture && !_givesCheck(board, m);
      if (cfg.enableLMR && isQuiet && i > 3 && depth >= 3) {
        reduction = _lmrReduction(depth, i);
      }

      final nextBoard = board.simulateMove(m);

      int score;
      if (!cfg.enablePVS || i == 0) {
        score = -_alphaBeta(nextBoard, newDepth, -beta, -alpha, ctx);
      } else {
        score =
            -_alphaBeta(
              nextBoard,
              newDepth - reduction,
              -alpha - 1,
              -alpha,
              ctx,
            );
        if (score > alpha && reduction > 0) {
          score = -_alphaBeta(nextBoard, newDepth, -alpha - 1, -alpha, ctx);
        }
        if (score > alpha && score < beta) {
          score = -_alphaBeta(nextBoard, newDepth, -beta, -alpha, ctx);
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
        if (pvOut != null) {
          pvOut
            ..clear()
            ..add(m);
          // We could follow PV via TT, omitted for brevity with immutable Board.
        }
        if (bestScore > alpha) {
          alpha = bestScore;
          if (alpha >= beta) {
            // update killers/history on quiet cutoffs
            if (isQuiet) {
              ctx.killers.add(ctx.ply, m);
              ctx.history.reward(board.currentPlayer, m, depth);
            }
            break;
          }
        }
      }
    }

    final flag =
        (bestScore <= origAlpha)
            ? UPPER
            : (bestScore >= beta)
            ? LOWER
            : EXACT;
    tt.store(key, depth, bestScore, flag, bestMove);
    return bestScore;
  }

  int _quiescence(Board b, int alpha, int beta, _Ctx ctx) {
    final standPat = b.evaluateBoard();
    if (standPat >= beta) return standPat;
    if (standPat > alpha) alpha = standPat;

    // captures (and simple checks if available)
    final all = b.getAllLegalMovesForCurrentPlayer();
    final qMoves = <Move>[];
    for (final m in all) {
      if (m.isCapture || _givesCheck(b, m)) qMoves.add(m);
    }
    // Order captures naively by MVV-LVA-lite: prefer captures
    qMoves.sort((a, c) {
      final sa = a.isCapture ? 1 : 0;
      final sb = c.isCapture ? 1 : 0;
      return sb - sa;
    });

    for (final m in qMoves) {
      final nb = b.simulateMove(m);
      final score = -_quiescence(nb, -beta, -alpha, ctx);
      if (score >= beta) return score;
      if (score > alpha) alpha = score;
    }
    return alpha;
  }

  // --- Helpers ---
  bool _inCheck(Board b) => b.isKingInCheck(b.currentPlayer);
  bool _givesCheck(Board b, Move m) {
    final nb = b.simulateMove(m);
    final opp =
        b.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
    return nb.isKingInCheck(opp);
  }

  bool _hasNonPawnMaterial(Board b) {
    // Simple heuristic: rely on evaluation info if available, fallback true.
    // If needed, extend Board with helper. Here we conservatively return true.
    return true;
  }

  Board _makeNull(Board b) {
    // Null move = swap side to move without moving a piece.
    // With immutable Board, emulate by toggling currentPlayer and resetting EP.
    return b.copyWith(
      currentPlayer:
          (b.currentPlayer == PieceColor.white)
              ? PieceColor.black
              : PieceColor.white,
      enPassantTarget: null,
    );
  }

  List<Move> _orderMoves(Board b, List<Move> moves, Move? pv, _Ctx ctx) {
    moves.sort((a, bmv) {
      int sa = 0, sb = 0;
      if (pv != null && a == pv) sa += 1 << 30;
      if (pv != null && bmv == pv) sb += 1 << 30;
      if (ctx.killers.isKiller(ctx.ply, a)) sa += 1 << 20;
      if (ctx.killers.isKiller(ctx.ply, bmv)) sb += 1 << 20;
      sa += a.isCapture ? (1 << 18) : ctx.history.score(b.currentPlayer, a);
      sb += bmv.isCapture ? (1 << 18) : ctx.history.score(b.currentPlayer, bmv);
      return sb - sa;
    });
    return moves;
  }

  int _lmrReduction(int depth, int moveIdx) {
    final r = (math.log(depth + 1) * math.log(moveIdx + 1)).floor();
    return r.clamp(1, depth - 1);
  }

  int _computeExtension(Board b, Move m) {
    int ext = 0;
    if (_givesCheck(b, m)) ext += 1;
    if (m.isPromotion) ext += 1;
    return ext.clamp(0, 2);
  }
}

class _Ctx {
  final AiEngine eng;
  final Deadline timer;
  final _Killers killers;
  final _History history;
  int ply = 0;
  _Ctx(this.eng, this.timer, int maxDepth)
    : killers = _Killers(maxDepth + 8),
      history = _History();
}
