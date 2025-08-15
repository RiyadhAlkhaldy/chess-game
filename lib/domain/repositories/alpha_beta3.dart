import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/export.dart';
import 'alpha_beta_evaluate.dart';
import 'zobrist_hashing.dart';

class AlphaBeta3 extends AlphaBetaEvaluate {
  AlphaBeta3() {
    if (ZobristHashing.zobristKeysInitialized == false) {
      ZobristHashing.initializeZobristKeys();

      ZobristHashing.zobristKeysInitialized = true;
    }
  }
  static int i = 0;
  Map<NodeType, int> entryTransTable = {
    NodeType.exact: 0,
    NodeType.alpha: 0,
    NodeType.beta: 0,
  };
  Future<Move?> findBestMove(Board board, int depth) async {
    // 💡 قم بتهيئة ساعة توقيت لمراقبة الوقت
    final stopwatch = Stopwatch()..start();
    // 💡 تحديد الحد الأقصى للوقت المسموح به (مثلاً 3 ثوانٍ)
    final Duration maxThinkTime = Duration(seconds: 3);

    Move? bestMove;

    // 💡 أفضل قيمة تم العثور عليها حتى الآن
    int bestScore = -1000000;

    // 💡 حلقة التعميق التكراري
    // تبدأ البحث من عمق 1 وتزيد العمق تدريجياً
    for (int currentDepth = 1; currentDepth <= depth; currentDepth++) {
      // 💡 إذا نفد الوقت، نوقف البحث
      if (stopwatch.elapsed > maxThinkTime) {
        break;
      }

      // 💡 الحصول على جميع الحركات القانونية
      final List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();

      // 💡 قم بتحديد قيم ألفا وبيتا الأولية لكل دورة
      int alpha = -1000000;
      int beta = 1000000;

      Move? currentBestMove;
      int currentBestScore = -1000000;

      // 💡 ترتيب الحركات بناءً على أفضل حركة سابقة (إذا وجدت)
      if (bestMove != null) {
        legalMoves.remove(bestMove);
        legalMoves.insert(0, bestMove);
      }

      // 💡 حلقة لتقييم كل حركة في العمق الحالي
      for (final move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);

        // 💡 استدعاء alphaBeta من منظور الخصم (المقلل)
        // playerColor here is opponent
        int score = await alphaBeta(
          simulatedBoard,
          currentDepth - 1,
          alpha,
          beta,
          false, // ❌ تم تصحيح الخطأ: الخصم سيلعب بعدنا
        );

        // 💡 تحديث أفضل حركة وأفضل قيمة في هذا العمق
        if (score > currentBestScore) {
          currentBestScore = score;
          currentBestMove = move;
        }

        // 💡 تحديث ألفا في المستوى الأعلى
        alpha = max(alpha, score);

        // 💡 إذا حدث تقليم، نخرج من الحلقة
        if (alpha >= beta) {
          break;
        }
      }

      // 💡 إذا كانت هناك أفضل حركة في هذا العمق، نقوم بحفظها
      // هذا يضمن أن لدينا دائماً أفضل حركة حتى لو نفد الوقت
      if (currentBestMove != null) {
        bestMove = currentBestMove;
        bestScore = currentBestScore;
      }

      // 💡 في نهاية كل دورة، يمكننا تخزين أفضل حركة ونتيجتها
      // هذا ليس ضرورياً ولكنه يحسن أداء البحث التالي
      ZobristHashing.transpositionTable[board.zobristKey] = TranspositionEntry(
        score: bestScore,
        depth: currentDepth,
        type: NodeType.exact, // يمكن أن يكون هذا NodeType.ALPHA أو BETA
        bestMove: bestMove,
      );
    }

    stopwatch.stop();
    return bestMove;
  }
  // Future<Move?> findBestMove(Board board, int depth) async {

  //   i = 0; // Reset the counter for each call
  //   final int zobristKey = board.zobristKey;

  //   if (ZobristHashing.transpositionTable.containsKey(zobristKey)) {
  //     final entry = ZobristHashing.transpositionTable[zobristKey]!;
  //     if (entry.bestMove != null) {
  //       return entry.bestMove; // إذا كان هناك نتيجة مخزنة، استخدمها
  //     }
  //   }
  //   List<Move> moves = board.getAllLegalMovesForCurrentPlayer();

  //   // 3. ترتيب الحركات: ضع أفضل حركة مخزنة أولاً
  //   sortMoves(moves, board);
  //   // هذا يزيد من كفاءة تقليم ألفا-بيتا
  //   if (ZobristHashing.transpositionTable.containsKey(zobristKey) &&
  //       ZobristHashing.transpositionTable[zobristKey]!.bestMove != null) {
  //     final bestMoveFromTable =
  //         ZobristHashing.transpositionTable[zobristKey]!.bestMove!;
  //     // ضع أفضل حركة في بداية القائمة
  //     moves.remove(bestMoveFromTable);
  //     moves.insert(0, bestMoveFromTable);
  //   }

  //   Move? bestMove;
  //   int bestValue = -1000000; // قيمة أولية صغيرة جداً
  //   // قم بضبط قيم ألفا وبيتا الأولية للبحث الأولي
  //   int alpha = -1000000;
  //   int beta = 1000000;
  //   for (var move in moves) {
  //     final newBoard = board.simulateMove(move);
  //     final moveValue = await alphaBeta(
  //       newBoard,
  //       depth - 1,
  //       alpha,
  //       beta,
  //       false,
  //     );

  //     if (moveValue > bestValue) {
  //       bestValue = moveValue;
  //       bestMove = move;
  //     }

  //     // تحديث alpha بعد كل حركة، لأن getAiMove تعمل كلاعب معظّم
  //     alpha = max(alpha, bestValue);

  //     // إذا حدث تقليم هنا، يمكننا الخروج مبكراً
  //     if (beta <= alpha) break;
  //   }
  //   // 4. تخزين النتيجة النهائية وأفضل حركة في جدول التحويل
  //   // هذا ضروري لتخزين النتيجة وأفضل حركة في جدول التحويل عند العمق الأقصى
  //   ZobristHashing.transpositionTable[zobristKey] = TranspositionEntry(
  //     score: bestValue,
  //     depth: depth,
  //     type: NodeType.exact,
  //     bestMove: bestMove,
  //   );
  //   return bestMove;
  // }

  Future<int> alphaBeta(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
  ) async {
    i++; // Increment the counter for each call
    if (depth == 0 || board.isGameOver()) {
      return board.evaluateBoard();
    }
    // 2. حساب مفتاح Zobrist للموقف الحالي
    final int zobristKey = board.zobristKey;

    // 3. البحث في جدول التحويل
    // هذا يسمح للخوارزمية باستخدام النتائج المحسوبة مسبقًا
    if (ZobristHashing.transpositionTable.containsKey(zobristKey)) {
      final entry = ZobristHashing.transpositionTable[zobristKey]!;

      // إذا كان العمق المخزن أكبر من أو يساوي العمق الحالي، يمكننا استخدام النتيجة
      if (entry.depth >= depth) {
        if (entry.type == NodeType.exact) {
          return entry.score; // النتيجة دقيقة، أعدها مباشرة
        }
        if (entry.type == NodeType.alpha) {
          // النتيجة هي حد أدنى. إذا كانت أعلى من ألفا الحالي، حدث ألفا
          alpha = max(alpha, entry.score);
        }
        if (entry.type == NodeType.beta) {
          // النتيجة هي حد أقصى. إذا كانت أقل من بيتا الحالي، حدث بيتا
          beta = min(beta, entry.score);
        }
        // إذا كان هناك تقليم محتمل بناءً على القيم المخزنة، قم بالتقليم
        if (alpha >= beta) {
          return entry.score;
        }
      }
    }
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    sortMoves(legalMoves, board);
    // 5. ترتيب الحركات (لتحسين أداء ألفا-بيتا)
    // أفضل الحركات يتم فحصها أولاً، مما يزيد من فرص التقليم
    // نستخدم أفضل حركة مخزنة في جدول التحويل كأول خيار إذا كانت موجودة
    if (ZobristHashing.transpositionTable.containsKey(zobristKey) &&
        ZobristHashing.transpositionTable[zobristKey]!.bestMove != null) {
      final bestMoveFromTable =
          ZobristHashing.transpositionTable[zobristKey]!.bestMove!;
      // ضع أفضل حركة في بداية القائمة
      legalMoves.remove(bestMoveFromTable);
      legalMoves.insert(0, bestMoveFromTable);
    }
    int bestValue;
    Move? bestMove;
    NodeType nodeType;

    if (isMaximizing) {
      bestValue = -1000000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        int moveValue = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          false,
        );
        if (moveValue > bestValue) {
          bestValue = moveValue;
          bestMove = move;
        }

        alpha = max(alpha, bestValue); // تم التصحيح لاستخدام bestValue
        if (beta <= alpha) break; // Beta cut-off
      }

      // تحديد نوع العقدة
      if (bestValue <= alpha) {
        entryTransTable[NodeType.beta] = entryTransTable[NodeType.beta]! + 1;

        nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
      } else if (bestValue >= beta) {
        entryTransTable[NodeType.alpha] = entryTransTable[NodeType.alpha]! + 1;

        nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
      } else {
        entryTransTable[NodeType.exact] = entryTransTable[NodeType.exact]! + 1;
        nodeType = NodeType.exact; // القيمة دقيقة
      }
    } else {
      bestValue = 10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);

        int moveValue = await alphaBeta(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          true,
        );
        if (moveValue < bestValue) {
          bestValue = moveValue;
          bestMove = move;
        }

        beta = min(beta, bestValue); // تم التصحيح لاستخدام bestValue
        if (beta <= alpha) break; // Alpha cut-off
      }
      // تحديد نوع العقدة
      if (bestValue <= alpha) {
        entryTransTable[NodeType.beta] = entryTransTable[NodeType.beta]! + 1;
        nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
      } else if (bestValue >= beta) {
        entryTransTable[NodeType.alpha] = entryTransTable[NodeType.alpha]! + 1;
        nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
      } else {
        entryTransTable[NodeType.exact] = entryTransTable[NodeType.exact]! + 1;
        nodeType = NodeType.exact; // القيمة دقيقة
      }
    }
    // 8. تخزين النتيجة وأفضل حركة في جدول التحويل
    ZobristHashing.transpositionTable[zobristKey] = TranspositionEntry(
      score: bestValue,
      depth: depth,
      type: nodeType,
      bestMove: bestMove,
    );

    return bestValue;
  }

  Board makeMove(Move move, [Board? boardParameter]) {
    Board newBoard = boardParameter!;
    final Piece? pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      debugPrint("خطأ: لا توجد قطعة في خلية البداية.");
      return newBoard; // لا تفعل شيئًا إذا لم تكن هناك قطعة
    }
    if (pieceToMove.color != newBoard.currentPlayer) {
      debugPrint("خطأ: ليس دور هذا اللاعب ${pieceToMove.color.name} الان ");
      return newBoard; // لا تفعل شيئًا إذا لم يكون دور هذا اللاعب
    }

    // تحديث hasMoved للقطعة التي تتحرك
    final Piece updatedPiece = pieceToMove.copyWith(hasMoved: true);
    newBoard = newBoard.placePiece(move.end, updatedPiece);
    newBoard = newBoard.placePiece(
      move.start,
      null,
    ); // إزالة القطعة من الخلية الأصلية

    // منطق الـ En Passant
    Cell? newEnPassantTarget;
    // تحديد ما إذا كانت الحركة الحالية هي حركة بيدق مزدوجة
    bool isCurrentMoveTwoStepPawnMove =
        pieceToMove.type == PieceType.pawn &&
        (move.end.row - move.start.row).abs() == 2;

    if (isCurrentMoveTwoStepPawnMove) {
      final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
      newEnPassantTarget = Cell(
        row: move.end.row + direction,
        col: move.end.col,
      );
    }
    if (!isCurrentMoveTwoStepPawnMove) {
      newEnPassantTarget = null;
    }
    if (move.isTwoStepPawnMove && pieceToMove.type == PieceType.pawn) {
      final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
      newEnPassantTarget = Cell(
        row: move.end.row + direction,
        col: move.end.col,
      );
    }

    if (move.isEnPassant) {
      final int capturedPawnRow =
          pieceToMove.color == PieceColor.white
              ? move.end.row + 1
              : move.end.row - 1;
      final Cell capturedPawnCell = Cell(
        row: capturedPawnRow,
        col: move.end.col,
      );
      newBoard = newBoard.placePiece(
        capturedPawnCell,
        null,
      ); // إزالة البيدق المأسور
    }

    // منطق الكاستلينج
    if (move.isCastling && pieceToMove.type == PieceType.king) {
      final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // King-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 7);
        final Cell newRookCell = Cell(row: kingRow, col: 5);
        final Rook? rook = newBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith(hasMoved: true);
          newBoard = newBoard.placePiece(newRookCell, updatedRook);
          newBoard = newBoard.placePiece(oldRookCell, null);
        }
      } else if (move.end.col == 2) {
        // Queen-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 0);
        final Cell newRookCell = Cell(row: kingRow, col: 3);
        final Rook? rook = newBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith(hasMoved: true);
          newBoard = newBoard.placePiece(newRookCell, updatedRook);
          newBoard = newBoard.placePiece(oldRookCell, null);
        }
      }
    }

    // منطق ترقية البيدق
    if (move.isPromotion && pieceToMove.type == PieceType.pawn) {
      // افتراض الترقية إلى ملكة إذا لم يحدد نوع آخر (يمكن توسيع هذا لاحقًا)
      final promotedPiece = Queen(
        color: pieceToMove.color,
        type: PieceType.queen,
        hasMoved: true,
      );
      newBoard = newBoard.placePiece(move.end, promotedPiece);
    }
    // تحديث حقوق الكاستلينج بعد حركة الملك أو الرخ
    Map<PieceColor, Map<CastlingSide, bool>> newCastlingRights = Map.from(
      newBoard.castlingRights,
    );

    // إذا تحرك الملك، يفقد حقوق الكاستلينج
    if (pieceToMove.type == PieceType.king) {
      newCastlingRights =
          newCastlingRights..update(
            pieceToMove.color,
            (value) =>
                Map.from(value)
                  ..update(CastlingSide.kingSide, (value) => false)
                  ..update(CastlingSide.queenSide, (value) => false),
          );
    }

    // إذا تحرك الرخ من موضعه الأصلي، يفقد حقوق الكاستلينج لتلك الجهة
    if (pieceToMove.type == PieceType.rook) {
      if (pieceToMove.color == PieceColor.white) {
        if (move.start == const Cell(row: 7, col: 0)) {
          // رخ أبيض يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.start == const Cell(row: 7, col: 7)) {
          // رخ أبيض يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        }
      } else {
        // Black rook
        if (move.start == const Cell(row: 0, col: 0)) {
          // رخ أسود يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.start == const Cell(row: 0, col: 7)) {
          // رخ أسود يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        }
      }
    }
    // إذا تم أسر الرخ، يفقد حقوق الكاستلينج للخصم لتلك الجهة
    if (move.isCapture) {
      // تحقق من الرخ الذي تم أسره (إذا كان رخ)
      if (move.end == const Cell(row: 0, col: 0) &&
          newBoard.getPieceAt(move.end)?.type == PieceType.rook) {
        // رخ أسود يسار
        newCastlingRights =
            newCastlingRights..update(
              PieceColor.black,
              (value) =>
                  Map.from(value)
                    ..update(CastlingSide.queenSide, (value) => false),
            );
      } else if (move.end == const Cell(row: 0, col: 7) &&
          newBoard.getPieceAt(move.end)?.type == PieceType.rook) {
        // رخ أسود يمين
        newCastlingRights =
            newCastlingRights..update(
              PieceColor.black,
              (value) =>
                  Map.from(value)
                    ..update(CastlingSide.kingSide, (value) => false),
            );
      } else if (move.end == const Cell(row: 7, col: 0) &&
          newBoard.getPieceAt(move.end)?.type == PieceType.rook) {
        // رخ أبيض يسار
        newCastlingRights =
            newCastlingRights..update(
              PieceColor.white,
              (value) =>
                  Map.from(value)
                    ..update(CastlingSide.queenSide, (value) => false),
            );
      } else if (move.end == const Cell(row: 7, col: 7) &&
          newBoard.getPieceAt(move.end)?.type == PieceType.rook) {
        // رخ أبيض يمين
        newCastlingRights =
            newCastlingRights..update(
              PieceColor.white,
              (value) =>
                  Map.from(value)
                    ..update(CastlingSide.kingSide, (value) => false),
            );
      }
    }

    // تحديث مواضع الملك
    Map<PieceColor, Cell> newKingPositions = Map.from(newBoard.kingPositions);
    if (pieceToMove.type == PieceType.king) {
      newKingPositions[pieceToMove.color] = move.end;
    }

    // تحديث HalfMoveClock
    int newHalfMoveClock = newBoard.halfMoveClock + 1;
    if (pieceToMove.type == PieceType.pawn || move.isCapture) {
      newHalfMoveClock = 0; // إعادة تعيين العداد عند حركة بيدق أو أسر
    }

    // تحديث FullMoveNumber
    int newFullMoveNumber = newBoard.fullMoveNumber;
    if (newBoard.currentPlayer == PieceColor.black) {
      newFullMoveNumber++; // يزداد بعد حركة اللاعب الأسود
    }

    // تحديث اللاعب الحالي
    final PieceColor nextPlayer =
        newBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    newBoard = newBoard.copyWith(
      moveHistory: List.from(newBoard.moveHistory)..add(move),
      currentPlayer: nextPlayer,
      enPassantTarget: newEnPassantTarget,
      castlingRights: newCastlingRights,
      kingPositions: newKingPositions,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      zobristKey: ZobristHashing.updateZobristKeyAfterMove(
        boardParameter,
        move,
      ),
    );

    newBoard = newBoard.copyWith(positionHistory: [newBoard.toFenString()]);
    _boardHistory.add(newBoard); // إضافة اللوحة الجديدة إلى سجل التاريخ

    return newBoard;
  }

  final List<Board> _boardHistory = [];
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
}

// import 'dart:math';

// import 'package:flutter/rendering.dart';

// import '../entities/export.dart';
// import 'zobrist_hashing.dart';

class AlphaBeta4 extends AlphaBeta3 {
  // static int i = 0;

  // @override
  // Future<int> alphaBeta(
  //   Board board,
  //   int depth,
  //   int alpha,
  //   int beta,
  //   bool isMaximizing,
  // ) async {
  //   i++; // Increment the counter for each call
  //   if (depth == 0 || board.isGameOver()) {
  //     return board.evaluateBoard();
  //   }
  //   // 2. حساب مفتاح Zobrist للموقف الحالي
  //   final int zobristKey = _zobristHashing.calculateZobristKey(board);

  //   // 3. البحث في جدول التحويل
  //   // هذا يسمح للخوارزمية باستخدام النتائج المحسوبة مسبقًا
  //   if (_zobristHashing.transpositionTable.containsKey(zobristKey)) {
  //     final entry = _zobristHashing.transpositionTable[zobristKey]!;

  //     // إذا كان العمق المخزن أكبر من أو يساوي العمق الحالي، يمكننا استخدام النتيجة
  //     if (entry.depth >= depth) {
  //       if (entry.type == NodeType.exact) {
  //         //debugprint("Node type: Exact");
  //         return entry.score; // النتيجة دقيقة، أعدها مباشرة
  //       }
  //       if (entry.type == NodeType.alpha) {
  //         //debugprint("Node type: Alpha");
  //         // النتيجة هي حد أدنى. إذا كانت أعلى من ألفا الحالي، حدث ألفا
  //         alpha = max(alpha, entry.score);
  //       }
  //       if (entry.type == NodeType.beta) {
  //         // //debugprint("Node type: Beta");
  //         // النتيجة هي حد أقصى. إذا كانت أقل من بيتا الحالي، حدث بيتا
  //         beta = min(beta, entry.score);
  //       }
  //       // إذا كان هناك تقليم محتمل بناءً على القيم المخزنة، قم بالتقليم
  //       if (alpha >= beta) {
  //         return entry.score;
  //       }
  //     }
  //   }
  //   List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
  // _sortMoves(legalMoves, board);
  //   // 5. ترتيب الحركات (لتحسين أداء ألفا-بيتا)
  //   // أفضل الحركات يتم فحصها أولاً، مما يزيد من فرص التقليم
  //   // نستخدم أفضل حركة مخزنة في جدول التحويل كأول خيار إذا كانت موجودة
  //   if (_zobristHashing.transpositionTable.containsKey(zobristKey) &&
  //       _zobristHashing.transpositionTable[zobristKey]!.bestMove != null) {
  //     final bestMoveFromTable =
  //         _zobristHashing.transpositionTable[zobristKey]!.bestMove!;
  //     // ضع أفضل حركة في بداية القائمة
  //     legalMoves.remove(bestMoveFromTable);
  //     legalMoves.insert(0, bestMoveFromTable);
  //   }
  //   int bestValue;
  //   Move? bestMove;
  //   NodeType nodeType;

  //   if (isMaximizing) {
  //     bestValue = -1000000;
  //     for (Move move in legalMoves) {
  //       Board simulatedBoard = board.simulateMove(move);
  //       int moveValue = await alphaBeta(
  //         simulatedBoard,
  //         depth - 1,
  //         alpha,
  //         beta,
  //         false,
  //       );
  //       if (moveValue > bestValue) {
  //         bestValue = moveValue;
  //         bestMove = move;
  //       }

  //       alpha = max(alpha, bestValue); // تم التصحيح لاستخدام bestValue
  //       if (beta <= alpha) break; // Beta cut-off
  //     }

  //     // تحديد نوع العقدة
  //     if (bestValue <= alpha) {
  //       // //debugprint("bestValue <= alpha");
  //       nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
  //     } else if (bestValue >= beta) {
  //       //debugprint("bestValue >= beta");
  //       nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
  //     } else {
  //       //debugprint("bestValue == exact");
  //       nodeType = NodeType.exact; // القيمة دقيقة
  //     }
  //   } else {
  //     bestValue = 10000;
  //     for (Move move in legalMoves) {
  //       Board simulatedBoard = board.simulateMove(move);

  //       int moveValue = await alphaBeta(
  //         simulatedBoard,
  //         depth - 1,
  //         alpha,
  //         beta,
  //         true,
  //       );
  //       if (moveValue < bestValue) {
  //         bestValue = moveValue;
  //         bestMove = move;
  //       }

  //       beta = min(beta, bestValue); // تم التصحيح لاستخدام bestValue
  //       if (beta <= alpha) break; // Alpha cut-off
  //     }
  //     // تحديد نوع العقدة
  //     if (bestValue <= alpha) {
  //       // //debugprint("bestValue <= alpha");
  //       nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
  //     } else if (bestValue >= beta) {
  //       //debugprint("bestValue >= beta");
  //       nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
  //     } else {
  //       //debugprint("bestValue == exact");
  //       nodeType = NodeType.exact; // القيمة دقيقة
  //     }
  //   }
  //   // 8. تخزين النتيجة وأفضل حركة في جدول التحويل
  //   _zobristHashing.transpositionTable[zobristKey] = TranspositionEntry(
  //     score: bestValue,
  //     depth: depth,
  //     type: nodeType,
  //     bestMove: bestMove,
  //   );

  //   return bestValue;
  // }
}
