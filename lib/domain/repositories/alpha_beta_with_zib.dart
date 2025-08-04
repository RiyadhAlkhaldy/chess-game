import 'dart:math';

import '../entities/board.dart';
import '../entities/move.dart';

/// أنواع القيمة المخزنة في جدول التحويل
enum EntryType { exact, lowerBound, upperBound }

/// الكائن الذي يتم تخزينه داخل جدول التحويل
class TranspositionEntry {
  final int zobristKey;
  final int value;
  final int depth;
  final EntryType type;

  TranspositionEntry({
    required this.zobristKey,
    required this.value,
    required this.depth,
    required this.type,
  });
}

class AlphaBeta {
  // جدول التحويل: المفتاح هو zobristKey، والقيمة هي التقييم المحفوظ
  final Map<int, TranspositionEntry> _transpositionTable = {};

  /// دالة البحث عن أفضل حركة
  Future<Move?> findBestMove(Board board, int depth) async {
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    Move? bestMove;
    int bestValue = -10000;

    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);

      int moveValue = await alphaBeta(
        simulatedBoard,
        depth - 1,
        -10000,
        10000,
        false,
      );

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }
    return bestMove;
  }

  /// دالة Alpha-Beta مع دعم جدول التحويل
  Future<int> alphaBeta(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
  ) async {
    // الحصول على zobristKey من كائن اللوحة (يجب تنفيذه داخل كلاس Board)
    final int zobristKey = board.zobristKey;

    // تحقق مما إذا كانت هذه الحالة تم تقييمها مسبقًا
    final entry = _transpositionTable[zobristKey];
    if (entry != null && entry.depth >= depth) {
      // استخدام القيمة المحفوظة حسب نوعها
      if (entry.type == EntryType.exact) return entry.value;
      if (entry.type == EntryType.lowerBound && entry.value >= beta)
        return entry.value;
      if (entry.type == EntryType.upperBound && entry.value <= alpha)
        return entry.value;
    }

    // الحالة النهائية أو الوصول إلى أقصى عمق
    if (depth == 0 || board.isGameOver()) {
      return board.evaluateBoard();
    }

    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();

    int originalAlpha = alpha;
    int value;

    if (isMaximizing) {
      value = -10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        int eval = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          false,
        );
        value = max(value, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Beta cut-off
      }
    } else {
      value = 10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        int eval = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          true,
        );
        value = min(value, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha cut-off
      }
    }

    // تحديد نوع النتيجة المخزنة
    EntryType type;
    if (value <= originalAlpha) {
      type = EntryType.upperBound;
    } else if (value >= beta) {
      type = EntryType.lowerBound;
    } else {
      type = EntryType.exact;
    }

    // تخزين النتيجة في جدول التحويل
    _transpositionTable[zobristKey] = TranspositionEntry(
      zobristKey: zobristKey,
      value: value,
      depth: depth,
      type: type,
    );

    return value;
  }

  // أدوات إضافية كما هي
  bool hasAnyLegalMoves(Board board, String playerColor) {
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    return legalMoves.isNotEmpty;
  }

  bool isMoveResultingInCheck(Board board, Move move) {
    Board simulatedBoard = board.simulateMove(move);
    return simulatedBoard.isKingInCheck(board.currentPlayer);
  }

  Board simulateMove(Board board, Move move) {
    return board.simulateMove(move);
  }

  int evaluateBoard(Board board) {
    return board.evaluateBoard();
  }
}
