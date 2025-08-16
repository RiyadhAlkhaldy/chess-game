// lib/data/engine/ai_engine.dart
//
// نفس المحرك لكن الآن يعمل على EngineBoard (متحوّل) ويستدعي make/unmake.
//
// ملاحظات:
// - Board هنا تعني EngineBoard (انظر النوع في الدوال).
// - عدم إنشاء نسخ لكل نقلة = قفزة أداء كبيرة.
// - TT ما يزال يعمل باستخدام zobristKey من EngineBoard.
//
// المتطلبات:
//   import 'engine_board.dart';

import 'dart:math' as math;

import 'package:chess_gemini_2/domain/entities/board.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/zobrist_hashing.dart';
import '../engine/engine_board.dart'; // <-- مهم

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

  // الآن نستقبل EngineBoard مباشرة
  Future<Move?> search(EngineBoard root) async {
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
          alpha -= cfg.aspirationDelta * 2;
          tries++;
          continue;
        }
        if (score >= beta && tries < 2) {
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
    EngineBoard b,
    int depth,
    int alpha,
    int beta,
    _Ctx ctx, {
    List<Move>? pvOut,
  }) {
    if (ctx.timer.expired) return 0;

    final key = b.zobristKey;
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
      return _quiescence(b, alpha, beta, ctx);
    }

    // Null-move pruning
    if (cfg.enableNullMove &&
        !_inCheck(b) &&
        depth >= 3 &&
        _hasNonPawnMaterial(b)) {
      // null-move = تبديل الدور بدون تحريك قطعة فعلياً
      _doNullMove(b, ctx);
      final nullScore = -_alphaBeta(b, depth - 1 - 2, -beta, -beta + 1, ctx);
      _undoNullMove(b, ctx);
      if (nullScore >= beta) return nullScore;
    }

    // توليد النقلات من كودك الحالي لكن على Board غير متحوّل:
    final legal =
        b.toBoard().getAllLegalMovesForCurrentPlayer(); // سريع كفاية هنا
    var moves = _orderMoves(b, legal, pvMove, ctx);

    int bestScore = -INF;
    Move? bestMove;

    for (int i = 0; i < moves.length; i++) {
      final m = moves[i];

      final ext = _computeExtension(b, m);
      int newDepth = depth - 1 + ext;

      int reduction = 0;
      final isQuiet = !m.isCapture && !_givesCheck(b, m);
      if (cfg.enableLMR && isQuiet && i > 3 && depth >= 3) {
        reduction = _lmrReduction(depth, i);
      }

      // --- make/unmake بدلاً من simulateMove ---
      b.makeMove(m);

      int score;
      if (!cfg.enablePVS || i == 0) {
        score = -_alphaBeta(b, newDepth, -beta, -alpha, ctx);
      } else {
        score = -_alphaBeta(b, newDepth - reduction, -alpha - 1, -alpha, ctx);
        if (score > alpha && reduction > 0) {
          score = -_alphaBeta(b, newDepth, -alpha - 1, -alpha, ctx);
        }
        if (score > alpha && score < beta) {
          score = -_alphaBeta(b, newDepth, -beta, -alpha, ctx);
        }
      }

      b.unmakeMove(); // ارجع النقلة فوراً

      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
        if (pvOut != null) {
          pvOut
            ..clear()
            ..add(m);
        }
        if (bestScore > alpha) {
          alpha = bestScore;
          if (alpha >= beta) {
            if (isQuiet) {
              ctx.killers.add(ctx.ply, m);
              ctx.history.reward(b.currentPlayer, m, depth);
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

  int _quiescence(EngineBoard b, int alpha, int beta, _Ctx ctx) {
    final standPat = b.toBoard().evaluateBoard();
    if (standPat >= beta) return standPat;
    if (standPat > alpha) alpha = standPat;

    final all = b.toBoard().getAllLegalMovesForCurrentPlayer();
    final qMoves = <Move>[];
    for (final m in all) {
      if (m.isCapture || _givesCheck(b, m)) qMoves.add(m);
    }
    qMoves.sort((a, c) {
      final sa = a.isCapture ? 1 : 0;
      final sb = c.isCapture ? 1 : 0;
      return sb - sa;
    });

    for (final m in qMoves) {
      b.makeMove(m);
      final score = -_quiescence(b, -beta, -alpha, ctx);
      b.unmakeMove();
      if (score >= beta) return score;
      if (score > alpha) alpha = score;
    }
    return alpha;
  }

  // --- Helpers ---
  bool _inCheck(EngineBoard b) => b.isKingInCheck(b.currentPlayer);
  bool _givesCheck(EngineBoard b, Move m) {
    // نجرب التنفيذ ثم الفحص (سريع عبر make/unmake)
    b.makeMove(m);
    final opp = b.currentPlayer; // بعد makeMove يتبدّل الدور
    final chk = b.isKingInCheck(opp);
    b.unmakeMove();
    return chk;
  }

  bool _hasNonPawnMaterial(EngineBoard b) {
    // إبقها true (تبسيط)، أو استخلص من تقييمك
    return true;
  }

  void _doNullMove(EngineBoard b, _Ctx ctx) {
    // بدل الدور فقط مع تحديث الهاش (أبسط عبر make/unmake خاصة)
    // نستخدم حركة "وهمية"؟ أسهل: خزن في الـ stack كـ null-move
    final fake = Move(
      start: const Cell(row: -1, col: -1),
      end: const Cell(row: -1, col: -1),
      movedPiece: b.squares[0][0]!, // dummy
    );
    // حيلة: نغيّر الدور والـ zobrist بدون لمس المربعات
    final before = Undo(
      move: fake,
      captured: null,
      movedBefore: Piece.create(
        color: PieceColor.white,
        type: PieceType.king,
        hasMoved: true,
      ), // dummy
      rookBefore: null,
      rookFrom: null,
      rookTo: null,
      castlingBefore: {
        PieceColor.white: {
          CastlingSide.kingSide:
              b.castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              b.castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
        },
        PieceColor.black: {
          CastlingSide.kingSide:
              b.castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              b.castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
        },
      },
      kingsBefore: {
        PieceColor.white: b.kingPositions[PieceColor.white]!,
        PieceColor.black: b.kingPositions[PieceColor.black]!,
      },
      enPassantBefore: b.enPassantTarget,
      halfMoveBefore: b.halfMoveClock,
      fullMoveBefore: b.fullMoveNumber,
      zobristBefore: b.zobristKey,
    );
    // أزل EP من الهاش في null-move
    b.zobristKey = ZobristHashing.setEnPassantFile(
      b.zobristKey,
      prevFile: b.enPassantTarget?.col,
      newFile: null,
    );
    b.enPassantTarget = null;
    // بدّل الدور في الهاش
    b.zobristKey = ZobristHashing.toggleSideToMove(
      b.zobristKey,
      from: b.currentPlayer,
    );
    b.currentPlayer =
        (b.currentPlayer == PieceColor.white)
            ? PieceColor.black
            : PieceColor.white;
    b.stack.add(before);
  }

  void _undoNullMove(EngineBoard b, _Ctx ctx) {
    if (b.stack.isEmpty) return;
    final u = b.stack.removeLast();
    // أعد كل شيء كما كان
    b.currentPlayer =
        (b.currentPlayer == PieceColor.white)
            ? PieceColor.black
            : PieceColor.white;
    b.enPassantTarget = u.enPassantBefore;
    b.halfMoveClock = u.halfMoveBefore;
    b.fullMoveNumber = u.fullMoveBefore;
    b.castlingRights[PieceColor.white]![CastlingSide.kingSide] =
        u.castlingBefore[PieceColor.white]![CastlingSide.kingSide]!;
    b.castlingRights[PieceColor.white]![CastlingSide.queenSide] =
        u.castlingBefore[PieceColor.white]![CastlingSide.queenSide]!;
    b.castlingRights[PieceColor.black]![CastlingSide.kingSide] =
        u.castlingBefore[PieceColor.black]![CastlingSide.kingSide]!;
    b.castlingRights[PieceColor.black]![CastlingSide.queenSide] =
        u.castlingBefore[PieceColor.black]![CastlingSide.queenSide]!;
    b.kingPositions[PieceColor.white] = u.kingsBefore[PieceColor.white]!;
    b.kingPositions[PieceColor.black] = u.kingsBefore[PieceColor.black]!;
    b.zobristKey = u.zobristBefore;
  }

  List<Move> _orderMoves(EngineBoard b, List<Move> moves, Move? pv, _Ctx ctx) {
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

  int _computeExtension(EngineBoard b, Move m) {
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
