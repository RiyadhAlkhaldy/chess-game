import 'dart:math';

import 'package:chess_gemini_2/domain/repositories/zobrist_hashing.dart';
import 'package:flutter/material.dart';

import '../../data/chess_logic.dart';
import '../../domain/repositories/game_repository.dart';
import '../entities/export.dart';
import 'ai_game_repository_impl.dart';
import 'simulate_move.dart';

part 'extension_repository_impl.dart';

/// تطبيق [GameRepository] الذي يحتوي على منطق لعبة الشطرنج الفعلي.
class GameRepositoryImpl extends GameRepository {
  Board currentBoard;
  List<Board> _boardHistory = []; // لتتبع تكرار اللوحة
  List<Move> redoStack = []; // لتتبع الحركات التي يمكن التراجع عنها
  // 'rnbqk2r/pp3ppp/2p2n2/3p2B1/1b1P4/2N2N2/PP2PPPP/R2QKB1R w KQkq - 0 1',
  GameRepositoryImpl() : currentBoard = Board.initial() {
    if (!ZobristHashing.zobristKeysInitialized) {
      ZobristHashing.initializeZobristKeys();
      ZobristHashing.zobristKeysInitialized = true;
    }
    _boardHistory.add(currentBoard);
    // if (!_zobristKeysInitialized) {
    //   _initializeZobristKeys();
    //   _zobristKeysInitialized = true;
    // }
  }

  @override
  Board getCurrentBoard() {
    return currentBoard;
  }

  // الحصول على الحركات القانونية للقطعة في الخلية المحددة.
  @override
  List<Move> getLegalMoves(Cell cell, [Board? boardParameter]) =>
      ChessLogic.getLegalMoves(cell, boardParameter ?? currentBoard);

  // تحديث اللوحة الحالية بعد إجراء حركة.
  @override
  Board makeMove(Move move) {
    Board newBoard = currentBoard;
    final Piece? pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      debugPrint("خطأ: لا توجد قطعة في خلية البداية.");
      return currentBoard; // لا تفعل شيئًا إذا لم تكن هناك قطعة
    }
    if (pieceToMove.color != newBoard.currentPlayer) {
      debugPrint("خطأ: ليس دور هذا اللاعب ${pieceToMove.color.name} الان ");
      return currentBoard; // لا تفعل شيئًا إذا لم يكن دور هذا اللاعب
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
        currentBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    newBoard = newBoard.copyWith(
      moveHistory: List.from(currentBoard.moveHistory)..add(move),
      currentPlayer: nextPlayer,
      enPassantTarget: newEnPassantTarget,
      castlingRights: newCastlingRights,
      kingPositions: newKingPositions,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      zobristKey: ZobristHashing.updateZobristKeyAfterMove(currentBoard, move),
    );

    currentBoard = newBoard.copyWith(positionHistory: [newBoard.toFenString()]);
    _boardHistory.add(currentBoard); // إضافة اللوحة الجديدة إلى سجل التاريخ

    return currentBoard;
  }

  @override
  bool isKingInCheck(PieceColor kingColor, [Board? boardParameter]) {
    if (boardParameter != null) return boardParameter.isKingInCheck(kingColor);
    return currentBoard.isKingInCheck(kingColor);
  }

  @override
  GameResult getGameResult([Board? boardParameter, bool isAI = false]) {
    return checkGameEndConditions(boardParameter ?? currentBoard, isAI);
  }

  @override
  void resetGame() {
    currentBoard = Board.initial();
    _boardHistory = [currentBoard]; // إعادة تعيين تاريخ اللوحة أيضًا
  }

  @override
  Board simulateMove(Board board, Move move) {
    // debugPrint("simulateMove");

    return SimulateMove.simulateMove(board, move);
  }

  // @override
  // bool isMoveResultingInCheck(Board board, Move move) {
  //   final simulatedBoard = simulateMove(board, move);
  //   return simulatedBoard.isKingInCheck(board.currentPlayer);
  // }

  @override
  List<Move> getAllLegalMovesForCurrentPlayer(Board board) =>
      ChessLogic.getAllLegalMovesForCurrentPlayer(board);

  @override
  bool hasAnyLegalMoves(PieceColor playerColor, [Board? boardParameter]) {
    Board newBoard = boardParameter ?? currentBoard.copyWithDeepPieces();
    // لحساب الحركات القانونية للاعب، نحتاج إلى التأكد من أن isKingInCheck
    // والمنطق يعتمد على "اللاعب الحالي" في اللوحة.
    // نقوم بتغيير currentPlayer مؤقتًا إذا لم يكن اللون المطلوب.
    // final originalCurrentPlayer = newBoard.currentPlayer;
    newBoard = newBoard.copyWith(currentPlayer: playerColor);

    final bool hasMoves = getAllLegalMovesForCurrentPlayer(newBoard).isNotEmpty;

    // استعادة اللاعب الحالي الأصلي
    // currentBoard = currentBoard.copyWith(currentPlayer: originalCurrentPlayer);
    return hasMoves;
  }

  ///
  ///
  ///
  ///
  ///

  @override
  GameResult checkGameEndConditions(Board board, [bool isAI = false]) {
    // debugPrint("checkGameEndConditions");

    final currentPlayerColor = board.currentPlayer;

    // 1. تحقق أولاً من وجود حركات قانونية
    final bool hasNoLegalMoves = !hasAnyLegalMoves(currentPlayerColor, board);
    final bool kingInCheck = isKingInCheck(currentPlayerColor, board);
    // return GameResult.stalemate();

    if (hasNoLegalMoves) {
      if (kingInCheck) {
        // كش ملك
        final PieceColor winner =
            currentPlayerColor == PieceColor.white
                ? PieceColor.black
                : PieceColor.white;
        return GameResult.checkmate(winner);
      } else {
        // طريق مسدود (لا يوجد كش ملك ولا حركات قانونية)
        return GameResult.stalemate();
      }
    }

    // 2. إذا كان هناك حركات قانونية، تحقق من شروط التعادل الأخرى
    final DrawReason? drawReason = checkForDrawConditions(board, isAI);
    if (drawReason != null) {
      return GameResult.draw(drawReason);
    }

    // 3. إذا لم يتم تحديد أي نهاية للعبة، فاللعبة مستمرة
    return GameResult.playing();
  }

  // lib/data/repositories/game_repository_impl.dart

  // ... (الاستيرادات وبقية الكود) ...

  @override
  DrawReason? checkForDrawConditions(Board board, [bool isAI = false]) {
    // 1. التعادل بالمواد غير الكافية
    if (_isInsufficientMaterialDraw(board)) {
      return DrawReason.insufficientMaterial;
    }

    // 2. قاعدة الخمسين حركة
    if (board.halfMoveClock >= 100) {
      return DrawReason.fiftyMoveRule;
    }
    if (!isAI) {
      // 3. التكرار الثلاثي
      if (_isThreefoldRepetition(board)) {
        return DrawReason.threefoldRepetition;
      }
    }

    // التعادل بالاتفاق لا يتم التحقق منه هنا لأنه يتطلب تفاعل المستخدم
    return null; // لا يوجد تعادل حاليًا من القواعد
  }

  /// العمق الأقصى لـ Minimax.
  /// (يمكن زيادته للحصول على AI أقوى، ولكنه يزيد من وقت المعالجة).
  // static const int _maxMinimaxDepth = 3; // مثال: 3 حركات للأمام
  @override
  Future<Move?> getAiMove(
    Board board,
    PieceColor aiPlayerColor,
    int aiDepth,
  ) async {
    i = 0; // Reset the counter for each call  final int zobristKey = board.zobristKey;
    final int zobristKey = board.zobristKey;

    if (ZobristHashing.transpositionTable.containsKey(zobristKey)) {
      final entry = ZobristHashing.transpositionTable[zobristKey]!;
      if (entry.bestMove != null) {
        // return entry.bestMove; // إذا كان هناك نتيجة مخزنة، استخدمها
      }
    }
    List<Move> moves = board.getAllLegalMovesForCurrentPlayer();

    // 3. ترتيب الحركات: ضع أفضل حركة مخزنة أولاً
    _sortMoves(moves, board);
    // هذا يزيد من كفاءة تقليم ألفا-بيتا
    if (ZobristHashing.transpositionTable.containsKey(zobristKey) &&
        ZobristHashing.transpositionTable[zobristKey]!.bestMove != null) {
      final bestMoveFromTable =
          ZobristHashing.transpositionTable[zobristKey]!.bestMove!;
      // ضع أفضل حركة في بداية القائمة
      moves.remove(bestMoveFromTable);
      moves.insert(0, bestMoveFromTable);
    }
    Move? bestMove;
    int bestValue = -1000000; // قيمة أولية صغيرة جداً
    // قم بضبط قيم ألفا وبيتا الأولية للبحث الأولي
    int alpha = -1000000;
    int beta = 1000000;
    for (var move in moves) {
      final newBoard = board.simulateMove(move);
      final moveValue = await alphaBeta(
        newBoard,
        aiDepth - 1,
        alpha,
        beta,
        false,
      );

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }

      // تحديث alpha بعد كل حركة، لأن getAiMove تعمل كلاعب معظّم
      alpha = max(alpha, bestValue);
      // إذا حدث تقليم هنا، يمكننا الخروج مبكراً
      if (beta <= alpha) break;
    }
    // 4. تخزين النتيجة النهائية وأفضل حركة في جدول التحويل
    // هذا ضروري لتخزين النتيجة وأفضل حركة في جدول التحويل عند العمق الأقصى
    ZobristHashing.transpositionTable[zobristKey] = TranspositionEntry(
      score: bestValue,
      depth: aiDepth,
      type: NodeType.exact,
      bestMove: bestMove,
    );
    return bestMove;
  }

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
          //debugprint("Node type: Exact");
          return entry.score; // النتيجة دقيقة، أعدها مباشرة
        }
        if (entry.type == NodeType.alpha) {
          //debugprint("Node type: Alpha");
          // النتيجة هي حد أدنى. إذا كانت أعلى من ألفا الحالي، حدث ألفا
          alpha = max(alpha, entry.score);
        }
        if (entry.type == NodeType.beta) {
          // //debugprint("Node type: Beta");
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
    _sortMoves(legalMoves, board);
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
        // //debugprint("bestValue <= alpha");
        nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
      } else if (bestValue >= beta) {
        //debugprint("bestValue >= beta");
        nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
      } else {
        //debugprint("bestValue == exact");
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
        // //debugprint("bestValue <= alpha");
        nodeType = NodeType.beta; // القيمة هي حد أقصى (حدث تقليم)
      } else if (bestValue >= beta) {
        //debugprint("bestValue >= beta");
        nodeType = NodeType.alpha; // القيمة هي حد أدنى (حدث تقليم)
      } else {
        //debugprint("bestValue == exact");
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

  static int i = 0;
}

extension AiLogic on GameRepositoryImpl {
  // PieceColor _getOppenentColor(PieceColor color) =>
  //     color == PieceColor.white ? PieceColor.black : PieceColor.white;

  ///
  static late PieceColor aIcurrentPlayer;
  static int i = 0;

  /// [minimaxRoot]
  /// نقطة الدخول لخوارزمية Minimax/Alpha-Beta.
  /// The entry point for the Minimax/Alpha-Beta algorithm.
  Move? minimaxRoot(SearchParams searchParams) {
    Board board = searchParams.board;
    int depth = searchParams.depth;
    aIcurrentPlayer = board.currentPlayer;
    Move? bestMove;
    int bestValue = -99999;
    debugPrint("bestMove $bestMove myint i = $i ");
    // الحصول على جميع الحركات القانونية للاعب الحالي.
    // Get all legal moves for the current player.
    final List<Move> legalMoves = getAllLegalMovesForCurrentPlayer(board);
    // ترتيب الحركات لتحسين Alpha-Beta Pruning.
    // Order moves to improve Alpha-Beta Pruning.
    _sortMoves(legalMoves, board);
    int boardValue = -99999;
    for (final move in legalMoves) {
      // تطبيق الحركة على نسخة من اللوحة.
      // Apply the move to a copy of the board.
      // debugPrint(
      //   "minimaxRoot n = ${++n} from ${legalMoves.length} $boardValue",
      // );

      final newBoard = simulateMove(board, move);
      // تبديل اللاعب الحالي.
      // Switch the current player.
      final simulatedBoard = newBoard.copyWith(
        currentPlayer:
            aIcurrentPlayer == PieceColor.white
                ? PieceColor.black
                : PieceColor.white,
      );

      // استدعاء Minimax لحساب قيمة هذه الوضعية.
      // Call Minimax to calculate the value of this position.
      boardValue = _minimax(
        simulatedBoard,
        depth - 1,
        -99999,
        99999,
        aIcurrentPlayer == PieceColor.white
            ? PieceColor
                .black // الخصم هو الذي سيلعب بعد هذه الحركة
            : PieceColor.white,
      );
      // debugPrint("boardValue  $boardValue");

      // إذا كانت هذه الحركة أفضل من أفضل حركة سابقة، قم بتحديثها.
      // If this move is better than the previous best move, update it.
      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
    }
    debugPrint("bestMove $bestMove myint i = $i ");
    // i = 0;
    return bestMove;
  }

  /// [_minimax]
  /// تنفيذ خوارزمية Minimax مع Alpha-Beta Pruning.
  /// Minimax algorithm implementation with Alpha-Beta Pruning.
  int _minimax(
    Board board,
    int depth,
    int alpha,
    int beta,
    PieceColor currentPlayer,
  ) {
    i++;
    // debugPrint(
    //   "int i = $i depth $depth alpha $alpha, beta $beta , $currentPlayer",
    // );
    // القاعدة الأساسية: إذا وصل العمق إلى صفر أو كانت اللعبة قد انتهت (كش ملك/تعادل).
    // Base case: If depth is zero or the game is over (checkmate/draw).
    if (depth == 0 || _isGameOver(board)) {
      return evaluateBoard(board, currentPlayer);
    }

    // اللاعب الذي يحاول تعظيم نتيجته.
    // Player trying to maximize their score.
    if (currentPlayer == aIcurrentPlayer) {
      // AI's turn
      int maxEval = -99999;
      final List<Move> legalMoves = getAllLegalMovesForCurrentPlayer(board);
      _sortMoves(legalMoves, board);

      for (final move in legalMoves) {
        final newBoard = simulateMove(board, move);
        final simulatedBoard = newBoard.copyWith(
          currentPlayer:
              currentPlayer == PieceColor.white
                  ? PieceColor.black
                  : PieceColor.white,
        );
        final eval = _minimax(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          simulatedBoard.currentPlayer,
        );
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          // Alpha-Beta Pruning
          break;
        }
      }
      // _transpositionTable[fen] = TranspositionEntry(
      //   maxEval,
      //   depth,
      //   NodeType.exact,
      // ); // حفظ النتيجة الدقيقة
      return maxEval;
    }
    // اللاعب الذي يحاول تقليل نتيجته (الخصم).
    // Player trying to minimize their score (opponent).
    else {
      // Opponent's turn
      int minEval = 99999;
      final List<Move> legalMoves = getAllLegalMovesForCurrentPlayer(board);
      _sortMoves(legalMoves, board);

      for (final move in legalMoves) {
        final newBoard = simulateMove(board, move);
        final simulatedBoard = newBoard.copyWith(
          currentPlayer:
              currentPlayer == PieceColor.white
                  ? PieceColor.black
                  : PieceColor.white,
        );
        final eval = _minimax(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          simulatedBoard.currentPlayer,
        );
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) {
          // Alpha-Beta Pruning
          break;
        }
      }

      // _transpositionTable[fen] = TranspositionEntry(
      //   minEval,
      //   depth,
      //   NodeType.exact,
      // ); // حفظ النتيجة الدقيقة
      return minEval;
    }
  }

  bool _isGameOver(Board board) {
    // debugPrint("_isGameOver");

    // التحقق من شروط نهاية اللعبة
    final gameResult = checkGameEndConditions(board, true);
    if (gameResult.outcome != GameOutcome.playing) return true;
    return false;
  }
}

// extension ZobristHashingImp on GameRepositoryImpl {
//   void _initializeZobristKeys() {
//     random = Random(42); // استخدام seed ثابت لأغراض الاختبار
//     // تهيئة جدول zobrist بـ أرقام عشوائية

//     // مفاتيح القطع والمربعات
//     for (var type in PieceType.values) {
//       _zobristPieceKeys[type] = {};
//       for (var color in PieceColor.values) {
//         _zobristPieceKeys[type]![color] = List.generate(
//           8,
//           (_) => List.generate(8, (_) => random.nextInt(0xFFFFFFFF)),
//         );
//       }
//     }
//     //  1^
//     //
//     //
//     // مفاتيح الدور (للاعب الأبيض والأسود)
//     _zobristSideToMoveKeys[PieceColor.white] = random.nextInt(0xFFFFFFFF);
//     _zobristSideToMoveKeys[PieceColor.black] = random.nextInt(0xFFFFFFFF);

//     // مفاتيح حقوق التبييت
//     _zobristCastlingKeys[PieceColor.white] = {
//       CastlingSide.kingSide: random.nextInt(0xFFFFFFFF),
//       CastlingSide.queenSide: random.nextInt(0xFFFFFFFF),
//     };
//     _zobristCastlingKeys[PieceColor.black] = {
//       CastlingSide.kingSide: random.nextInt(0xFFFFFFFF),
//       CastlingSide.queenSide: random.nextInt(0xFFFFFFFF),
//     };

//     // مفاتيح الأسر بالمرور (لـ 8 أعمدة)
//     for (int col = 0; col < 8; col++) {
//       _zobristEnPassantKeys[col] = random.nextInt(0xFFFFFFFF);
//     }
//   }

//   /// يحسب مفتاح Zobrist لموقف اللوحة الحالي.
//   int _calculateZobristKey(Board board) {
//     int hash = 0;

//     // 1. القطع في المربعات
//     for (int r = 0; r < 8; r++) {
//       for (int c = 0; c < 8; c++) {
//         final piece = board.squares[r][c];
//         if (piece != null) {
//           hash ^= _zobristPieceKeys[piece.type]![piece.color]![r][c];
//         }
//       }
//     }

//     // 2. الدور
//     hash ^= _zobristSideToMoveKeys[board.currentPlayer]!;

//     // 3. حقوق التبييت
//     if (board.castlingRights[PieceColor.white]![CastlingSide.kingSide]!) {
//       hash ^= _zobristCastlingKeys[PieceColor.white]![CastlingSide.kingSide]!;
//     }
//     if (board.castlingRights[PieceColor.white]![CastlingSide.queenSide]!) {
//       hash ^= _zobristCastlingKeys[PieceColor.white]![CastlingSide.queenSide]!;
//     }
//     if (board.castlingRights[PieceColor.black]![CastlingSide.kingSide]!) {
//       hash ^= _zobristCastlingKeys[PieceColor.black]![CastlingSide.kingSide]!;
//     }
//     if (board.castlingRights[PieceColor.black]![CastlingSide.queenSide]!) {
//       hash ^= _zobristCastlingKeys[PieceColor.black]![CastlingSide.queenSide]!;
//     }

//     ///
//     // 4. هدف الأسر بالمرور
//     if (board.enPassantTarget != null) {
//       hash ^= _zobristEnPassantKeys[board.enPassantTarget!.col]!;
//     }

//     return hash;
//   }
// }
