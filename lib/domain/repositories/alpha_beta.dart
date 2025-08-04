import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/board.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

class AlphaBeta {
  static int i = 0;
  // تعريف جدول التحويل (Transposition Table)

  final Map<int, TranspositionEntry> transpositionTable = {};

  // مفتاح التجزئة (Hash key) للموقف الحالي
  int zobristHash = 0;

  // مصفوفة Zobrist (Zobrist Array) لإنشاء مفاتيح التجزئة
  // يتم توليد هذه الأرقام العشوائية مرة واحدة عند بدء اللعبة
  final List<List<List<int>>> zobristPieces = List.generate(
    8,
    (i) => List.generate(
      8,
      (j) => List.generate(12, (piece) => Random().nextInt(4294967296)),
    ),
  );

  // مفتاح تجزئة خاص بالدور (side to move hash key)
  final int zobristSide = Random().nextInt(4294967296);

  // دالة لتحديث مفتاح التجزئة Zobrist
  void updateZobristHash(Board board) {
    int hash = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        Piece? piece = board.squares[r][c];
        if (piece != null) {
          int pieceIndex = _getPieceIndex(piece);
          hash ^= zobristPieces[r][c][pieceIndex];
        }
      }
    }
    // إذا كان الدور للأبيض، نقوم بتغيير مفتاح التجزئة
    if (board.currentPlayer == PieceColor.white) {
      hash ^= zobristSide;
    }
    zobristHash = hash;
  }

  int _getPieceIndex(Piece piece) {
    switch (piece.color) {
      case PieceColor.white:
        switch (piece.type) {
          case PieceType.pawn:
            return 0;
          case PieceType.knight:
            return 1;
          case PieceType.bishop:
            return 2;
          case PieceType.rook:
            return 3;
          case PieceType.queen:
            return 4;
          case PieceType.king:
            return 5;
        }
      case PieceColor.black:
        switch (piece.type) {
          case PieceType.pawn:
            return 6;
          case PieceType.knight:
            return 7;
          case PieceType.bishop:
            return 8;
          case PieceType.rook:
            return 9;
          case PieceType.queen:
            return 10;
          case PieceType.king:
            return 11;
        }
      default:
        return 0; // fallback
    }
  }

  // دالة لإيجاد أفضل حركة باستخدام خوارزمية Alpha-Beta Pruning
  Future<Move?> findBestMove(Board board, int depth) async {
    updateZobristHash(board); // تحديث مفتاح التجزئة قبل البحث
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    // قم بترتيب الحركات هنا قبل البدء بالبحث
    // يمكن أن يكون هذا الترتيب بسيطاً أو معقداً
    _sortMoves(legalMoves, board);

    Move? bestMove;
    int bestValue = -10000;
    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);
      updateZobristHash(simulatedBoard); // تحديث مفتاح التجزئة بعد المحاكاة
      // Use alpha-beta pruning to evaluate the move
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
    debugPrint("index: $i");
    return bestMove;
  }

  Future<int> alphaBeta(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
  ) async {
    i++; // Increment index for each call
    updateZobristHash(board); // تحديث مفتاح التجزئة قبل التقييم
    // 1. فحص جدول التحويل
    // التحقق مما إذا كان الموقف موجودًا بالفعل في الجدول
    if (transpositionTable.containsKey(zobristHash)) {
      TranspositionEntry entry = transpositionTable[zobristHash]!;
      // إذا كان العمق المخزن أكبر من أو يساوي العمق الحالي
      if (entry.depth >= depth) {
        // إذا كان القيمة دقيقة (exact value)
        if (entry.type == NodeType.exact) {
          return entry.value;
        }
        // إذا كانت القيمة حدًا أدنى (lowerBound) وتتناسب مع Alpha
        if (entry.type == NodeType.lowerBound) {
          alpha = max(alpha, entry.value);
        }
        // إذا كانت القيمة حدًا أعلى (upperBound) وتتناسب مع Beta
        else if (entry.type == NodeType.upperBound) {
          beta = min(beta, entry.value);
        }
        // إذا كانت الحدود تتقاطع، يمكننا التقليص (prune)
        if (alpha >= beta) {
          return entry.value;
        }
      }
    }
    if (depth == 0 || board.isGameOver()) {
      int evaluation = board.evaluateBoard();
      // تخزين النتيجة في جدول التحويل
      // 3. تخزين النتيجة في جدول التحويل
      transpositionTable[zobristHash] = TranspositionEntry(
        depth: depth,
        value: evaluation,
        type: NodeType.exact,
      );
      return evaluation;
    }

    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    // قم بترتيب الحركات هنا قبل البدء بالبحث
    // يمكن أن يكون هذا الترتيب بسيطاً أو معقداً

    _sortMoves(legalMoves, board);
    int originalAlpha = alpha;
    int value = 0;

    if (isMaximizing) {
      int bestValue = -10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        updateZobristHash(simulatedBoard); // تحديث مفتاح التجزئة بعد المحاكاة
        // 2. استدعاء الدالة alphaBeta بشكل متكرر
        int moveValue = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          false,
        );
        bestValue = max(bestValue, moveValue);
        alpha = max(alpha, moveValue);
        if (beta <= alpha) {
          value = bestValue;
          break; // Beta cut-off
        }
      }
      value = bestValue;
      // return bestValue;
    } else {
      int bestValue = 10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        updateZobristHash(simulatedBoard); // تحديث مفتاح التجزئة بعد المحاكاة

        int moveValue = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          true,
        );
        bestValue = min(bestValue, moveValue);
        beta = min(beta, moveValue);
        if (beta <= alpha) {
          value = bestValue;
          break; // Alpha cut-off
        }
      }
      value = bestValue;
      // return bestValue;
    }
    // 4. حفظ القيمة الجديدة في جدول التحويل
    // إذا كانت القيمة النهائية لا تزال داخل الحدود، فهي قيمة دقيقة (exact)
    if (value <= originalAlpha) {
      transpositionTable[zobristHash] = TranspositionEntry(
        depth: depth,
        value: value,
        type: NodeType.upperBound,
      );
    } else if (value >= alpha) {
      // هنا يجب استخدام alpha المعدلة
      transpositionTable[zobristHash] = TranspositionEntry(
        depth: depth,
        value: value,
        type: NodeType.lowerBound,
      );
    } else {
      transpositionTable[zobristHash] = TranspositionEntry(
        depth: depth,
        value: value,
        type: NodeType.exact,
      );
    }

    return value;
  }

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
    // Implement your board evaluation logic here
    return board.evaluateBoard();
  }
}

// تعريف أنواع العقد (Node types) لتحديد حالة القيمة المخزنة
enum NodeType { exact, lowerBound, upperBound }

// تعريف فئة (Class) لتخزين البيانات في جدول التحويل
class TranspositionEntry {
  final int depth;
  final int value;
  final NodeType type;
  TranspositionEntry({
    required this.depth,
    required this.value,
    required this.type,
  });
}

void _sortMoves(List<Move> moves, Board board) {
  moves.sort((a, b) {
    final bool aIsCapture = board.getPieceAt(a.end) != null;
    final bool bIsCapture = board.getPieceAt(b.end) != null;

    if (aIsCapture && !bIsCapture) {
      return -1; // حركة A (أسر) قبل حركة B (ليست أسر)
    } else if (!aIsCapture && bIsCapture) {
      return 1; // حركة B (أسر) قبل حركة A (ليست أسر)
    }
    // يمكن إضافة المزيد من منطق الترتيب هنا (على سبيل المثال، MVV-LVA)
    return 0; // لا يوجد فرق في الترتيب
  });
}
