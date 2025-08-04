// lib/data/repositories/game_repository_impl.dart
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/game_repository.dart';
import 'ai_game_repository_impl.dart';
import 'simulate_move.dart';

part 'ai_game_repo.dart';
part 'extension_repository_impl.dart';

mixin GameRepositoryImplMixin {
  /// دالة مساعدة خاصة لإضافة حركات الكاستلينج بعد التحقق من شرعيتها.
  /// الكاستلينج له قواعد خاصة لا يمكن التحقق منها فقط من خلال getRawMoves.
  void _addCastlingMoves(
    List<Move> moves,
    Cell kingCell,
    PieceColor kingColor,
    Board board,
  ) {
    if (kingColor != board.currentPlayer) return;
    if (board.isKingInCheck(kingColor)) {
      return; // لا يمكن الكاستلينج إذا كان الملك في كش
    }

    final int kingRow = kingColor == PieceColor.white ? 7 : 0;

    // الكاستلينج لجهة الملك (King-side Castling)
    if (board.castlingRights[kingColor]![CastlingSide.kingSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 7);
      final Piece? rook = board.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          board.getPieceAt(Cell(row: kingRow, col: 5)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 6)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 5)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 6))) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 6),
              isCastling: true,
              movedPiece: King(
                color: kingColor,
                type: PieceType.king,
                hasMoved: true,
              ),
              castlingRookFrom: rookCell,
              castlingRookTo: Cell(row: kingRow, col: 5),
            ),
          );
        }
      }
    }

    // الكاستلينج لجهة الملكة (Queen-side Castling)
    if (board.castlingRights[kingColor]![CastlingSide.queenSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 0);
      final Piece? rook = board.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          board.getPieceAt(Cell(row: kingRow, col: 3)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 2)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 1)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 3)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 2)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 1))) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 2),
              isCastling: true,
              movedPiece: King(
                color: kingColor,
                type: PieceType.king,
                hasMoved: true,
              ),
              castlingRookFrom: rookCell,
              castlingRookTo: Cell(row: kingRow, col: 3),
            ),
          );
        }
      }
    }
  }

  /// دالة مساعدة خاصة لإضافة حركات الـ En Passant بعد التحقق من شرعيتها.
  void _addEnPassantMoves(
    List<Move> moves,
    Cell pawnCell,
    PieceColor pawnColor,
    Board board,
  ) {
    if (board.enPassantTarget == null) return;

    final int direction = pawnColor == PieceColor.white ? -1 : 1;
    final int targetRow = pawnCell.row + direction;

    // تحقق من الخلايا المجاورة للبيدق لعملية الـ En Passant
    final List<Cell> adjacentCells = [
      Cell(row: pawnCell.row, col: pawnCell.col - 1),
      Cell(row: pawnCell.row, col: pawnCell.col + 1),
    ];

    for (final adjacentCell in adjacentCells) {
      if (adjacentCell.isValid()) {
        final Piece? adjacentPiece = board.getPieceAt(adjacentCell);
        if (adjacentPiece is Pawn &&
            adjacentPiece.color != pawnColor &&
            board.enPassantTarget ==
                Cell(row: targetRow, col: adjacentCell.col) &&
            board.moveHistory.isNotEmpty) {
          // التحقق مما إذا كانت الحركة الأخيرة هي حركة بيدق مزدوجة للبيدق المستهدف
          final lastMove = board.moveHistory.last;
          if (lastMove.isTwoStepPawnMove && lastMove.end == adjacentCell) {
            moves.add(
              Move(
                start: pawnCell,
                end: board.enPassantTarget!,
                isEnPassant: true,
                isCapture: true, // En Passant هو نوع من أنواع الأسر
                movedPiece: Pawn(
                  color: pawnColor,
                  type: PieceType.pawn,
                  hasMoved: true,
                ),
                capturedPiece: board.getPieceAt(board.enPassantTarget!),
                // enPassantTargetBefore: board.enPassantTarget,
              ),
            );
          }
        }
      }
    }
  }
}

/// تطبيق [GameRepository] الذي يحتوي على منطق لعبة الشطرنج الفعلي.
class GameRepositoryImpl extends GameRepository with GameRepositoryImplMixin {
  Board currentBoard;
  List<Board> _boardHistory = []; // لتتبع تكرار اللوحة
  List<Move> redoStack = []; // لتتبع الحركات التي يمكن التراجع عنها
  static bool _zobristKeysInitialized = false;

  /// مُنشئ لـ [GameRepositoryImpl]. يبدأ اللعبة بلوحة أولية للاعب الأبيض.
  // 'rnbqk2r/pp3ppp/2p2n2/3p2B1/1b1P4/2N2N2/PP2PPPP/R2QKB1R w KQkq - 0 1',
  GameRepositoryImpl() : currentBoard = Board.initial() {
    _boardHistory.add(currentBoard);
    if (!_zobristKeysInitialized) {
      _initializeZobristKeys();
      _zobristKeysInitialized = true;
    }
  }

  @override
  Board getCurrentBoard() {
    return currentBoard;
  }

  @override
  List<Move> getLegalMoves(Cell cell, [Board? boardParameter]) {
    debugPrint("getLegalMoves");
    final boardToUse = boardParameter ?? currentBoard;
    final piece = boardToUse.getPieceAt(cell);
    if (piece == null || piece.color != boardToUse.currentPlayer) {
      return []; // لا توجد قطعة أو ليست قطعة اللاعب الحالي
    }

    // الحصول على الحركات الأولية للقطعة (بغض النظر عن الكش)
    final rawMoves = piece.getRawMoves(boardToUse, cell);

    // تصفية الحركات لإزالة تلك التي تضع الملك في كش
    final legalMoves =
        rawMoves.where((move) {
          return !isMoveResultingInCheck(boardToUse, move);
        }).toList();

    // إضافة حركات الكاستلينج القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.king) {
      _addCastlingMoves(legalMoves, cell, piece.color, boardToUse);
    }
    // إضافة حركات En Passant القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.pawn) {
      _addEnPassantMoves(legalMoves, cell, piece.color, boardToUse);
    }

    return legalMoves;
  }

  @override
  Board makeMove(Move move, [Board? boardParameter]) {
    Board newBoard = boardParameter ?? currentBoard.copyWithDeepPieces();
    final Piece? pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      debugPrint("خطأ: لا توجد قطعة في خلية البداية.");
      return currentBoard; // لا تفعل شيئًا إذا لم تكن هناك قطعة
    }
    if (pieceToMove.color != newBoard.currentPlayer) {
      debugPrint("خطأ: ليس دور هذا اللاعب ${pieceToMove.color.name} الان ");
      return currentBoard; // لا تفعل شيئًا إذا لم يكون دور هذا اللاعب
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
    // if (move.isTwoStepPawnMove && pieceToMove.type == PieceType.pawn) {
    //   final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
    //   newEnPassantTarget = Cell(
    //     row: move.end.row + direction,
    //     col: move.end.col,
    //   );
    // }

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
      newCastlingRights[pieceToMove.color] = {
        CastlingSide.kingSide: false,
        CastlingSide.queenSide: false,
      };
    }

    // إذا تحرك الرخ من موضعه الأصلي، يفقد حقوق الكاستلينج لتلك الجهة
    if (pieceToMove.type == PieceType.rook) {
      if (pieceToMove.color == PieceColor.white) {
        if (move.start == const Cell(row: 7, col: 0)) {
          // رخ أبيض يسار
          newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 7, col: 7)) {
          // رخ أبيض يمين
          newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
        }
      } else {
        // Black rook
        if (move.start == const Cell(row: 0, col: 0)) {
          // رخ أسود يسار
          newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 0, col: 7)) {
          // رخ أسود يمين
          newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
        }
      }
    }
    // إذا تم أسر الرخ، يفقد حقوق الكاستلينج للخصم لتلك الجهة
    if (move.isCapture) {
      // تحقق من الرخ الذي تم أسره (إذا كان رخ)
      if (move.end == const Cell(row: 0, col: 0)) {
        // رخ أسود يسار
        newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 0, col: 7)) {
        // رخ أسود يمين
        newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
      } else if (move.end == const Cell(row: 7, col: 0)) {
        // رخ أبيض يسار
        newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 7, col: 7)) {
        // رخ أبيض يمين
        newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
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

  @override
  bool isMoveResultingInCheck(Board board, Move move) {
    final simulatedBoard = simulateMove(board, move);
    return simulatedBoard.isKingInCheck(board.currentPlayer);
  }

  @override
  List<Move> getAllLegalMovesForCurrentPlayer(Board board) {
    // debugPrint("getAllLegalMovesForCurrentPlayer");

    final List<Move> allLegalMoves = [];
    final currentPlayerColor = board.currentPlayer;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == currentPlayerColor) {
          final legalmoves = getLegalMoves(currentCell, board);
          if (legalmoves.isNotEmpty) {
            allLegalMoves.addAll(legalmoves);
          }
        }
      }
    }
    return allLegalMoves;
  }

  @override
  bool hasAnyLegalMoves(PieceColor playerColor, [Board? boardParameter]) {
    // debugPrint("hasAnyLegalMoves");
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
    // return findBestMove(board, aiDepth);
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    Move? bestMove;
    int bestValue = -10000;

    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);
      // Use alpha-beta pruning to evaluate the move
      int moveValue = await alphaBeta(
        simulatedBoard,
        aiDepth - 1,
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

  Future<int> alphaBeta(
    Board board,
    int depth,
    int alpha,
    int beta,

    bool isMaximizing,
  ) async {
    if (depth == 0 || board.isGameOver()) {
      return board.evaluateBoard();
    }

    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();

    if (isMaximizing) {
      int bestValue = -10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);

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
          break; // Beta cut-off
        }
      }

      return bestValue;
    } else {
      int bestValue = 10000;

      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);

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
          break; // Alpha cut-off
        }
      }

      return bestValue;
    }
  }

  static int i = 0;

  /// تنفيذ خوارزمية Minimax مع تقليم ألفا-بيتا.
  /// [board]: اللوحة الحالية.
  /// [depth]: العمق المتبقي للبحث.
  /// [maximizingPlayer]: صحيح إذا كان اللاعب الحالي هو لاعب التعظيم (AI).
  /// [aiPlayerColor]: لون قطع الذكاء الاصطناعي.
  /// [alpha]: أفضل قيمة (الحد الأدنى) تم العثور عليها حتى الآن في مسار لاعب التعظيم.
  /// [beta]: أفضل قيمة (الحد الأقصى) تم العثور عليها حتى الآن في مسار لاعب التقليل.

  /// دالة مساعدة للحصول على جميع الحركات القانونية للوحة معينة ولون لاعب معين.
  /// هذه نسخة من `getAllLegalMovesForCurrentPlayer` ولكنها تعمل على لوحة مُعطاة.
  List<Move> _getAllLegalMovesForBoard(Board board, PieceColor playerColor) {
    final List<Move> allLegalMoves = [];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == playerColor) {
          allLegalMoves.addAll(
            getLegalMoves(currentCell, board),
          ); // استدعاء مع اللوحة
        }
      }
    }
    return allLegalMoves;
  }

  @override
  Future<Move?> findBestMove(Board board, int depth) async {
    // استخدم compute لتشغيل البحث في معالج منفصل لتجنب تجميد واجهة المستخدم.
    // Use compute to run the search in an isolated processor to avoid freezing the UI.
    // يتم تمرير نسخة عميقة من اللوحة لضمان عدم وجود مشاكل في تزامن البيانات.
    // A deep copy of the board is passed to ensure no data synchronization issues.
    // return compute(
    //   _searchBestMove,
    //   SearchParams(board.copyWithDeepPieces(), depth),
    // );
    return _searchBestMove(SearchParams(board.copyWithDeepPieces(), depth));
  }

  // دالة مساعدة لتشغيلها في معالج منفصل
  // Helper function to be run in an isolated processor
  Move? _searchBestMove(SearchParams params) {
    // final ai = _AILogicClass(params.board);
    return minimaxRoot(params);
  }
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
    print("bestMove $bestMove myint i = $i ");
    // الحصول على جميع الحركات القانونية للاعب الحالي.
    // Get all legal moves for the current player.
    final List<Move> legalMoves = getAllLegalMovesForCurrentPlayer(board);
    // final List<Move> legalMoves = _getLegalMoves(board, aIcurrentPlayer);
    // print("bestMove ${legalMoves.length}  ");

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
    print("bestMove $bestMove myint i = $i ");
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
      return _evaluateBoard(board, currentPlayer);
    }

    // اللاعب الذي يحاول تعظيم نتيجته.
    // Player trying to maximize their score.
    if (currentPlayer == aIcurrentPlayer) {
      // AI's turn
      int maxEval = -99999;
      final List<Move> legalMoves = _getLegalMoves(board, currentPlayer);
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
      final List<Move> legalMoves = _getLegalMoves(board, currentPlayer);
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

  /// [_getLegalMoves]
  /// تُرجع قائمة بجميع الحركات القانونية للاعب الحالي على اللوحة المعطاة.
  /// Returns a list of all legal moves for the current player on the given board.
  List<Move> _getLegalMoves(Board board, PieceColor playerColor) {
    // debugPrint("_getLegalMoves");

    final List<Move> legalMoves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == playerColor) {
          final rawMoves = piece.getRawMoves(board, currentCell);
          for (final move in rawMoves) {
            // تحقق من شرعية الحركة (لا تضع الملك في كش)
            // Check move legality (does not put king in check)
            final simulatedBoard = simulateMove(
              board.copyWithDeepPieces(),
              move,
            );
            if (!simulatedBoard.isKingInCheck(playerColor)) {
              legalMoves.add(move);
            }
          }
        }
      }
    }
    return legalMoves;
  }

  bool _isGameOver(Board board) {
    // debugPrint("_isGameOver");

    // التحقق من شروط نهاية اللعبة
    final gameResult = checkGameEndConditions(board, true);
    if (gameResult.outcome != GameOutcome.playing) return true;
    return false;
  }
}

extension ZobristHashing on GameRepositoryImpl {
  static final Map<int, TranspositionEntry> _transpositionTable = {};

  // جداول Zobrist Hashing
  // يتم تهيئتها مرة واحدة فقط عند بدء التطبيق أو إنشاء الـ repository.
  static final Map<PieceType, Map<PieceColor, List<List<int>>>>
  _zobristPieceKeys = {};
  static final Map<PieceColor, int> _zobristSideToMoveKeys = {};
  static final Map<CastlingSide, Map<PieceColor, int>> _zobristCastlingKeys =
      {};
  static final Map<int, int> _zobristEnPassantKeys = {}; // 8 قيم لـ a-h

  void _initializeZobristKeys() {
    final Random random = Random(42); // استخدام seed ثابت لأغراض الاختبار

    // مفاتيح القطع والمربعات
    for (var type in PieceType.values) {
      _zobristPieceKeys[type] = {};
      for (var color in PieceColor.values) {
        _zobristPieceKeys[type]![color] = List.generate(
          8,
          (_) => List.generate(8, (_) => random.nextInt(0xFFFFFFFF)),
        );
      }
    }

    // مفاتيح الدور (للاعب الأبيض والأسود)
    _zobristSideToMoveKeys[PieceColor.white] = random.nextInt(0xFFFFFFFF);
    _zobristSideToMoveKeys[PieceColor.black] = random.nextInt(0xFFFFFFFF);

    // مفاتيح حقوق التبييت
    _zobristCastlingKeys[CastlingSide.kingSide] = {
      PieceColor.white: random.nextInt(0xFFFFFFFF),
      PieceColor.black: random.nextInt(0xFFFFFFFF),
    };
    _zobristCastlingKeys[CastlingSide.queenSide] = {
      PieceColor.white: random.nextInt(0xFFFFFFFF),
      PieceColor.black: random.nextInt(0xFFFFFFFF),
    };

    // مفاتيح الأسر بالمرور (لـ 8 أعمدة)
    for (int col = 0; col < 8; col++) {
      _zobristEnPassantKeys[col] = random.nextInt(0xFFFFFFFF);
    }
  }

  /// يحسب مفتاح Zobrist لموقف اللوحة الحالي.
  int _calculateZobristKey(Board board) {
    int hash = 0;

    // 1. القطع في المربعات
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          hash ^= _zobristPieceKeys[piece.type]![piece.color]![r][c];
        }
      }
    }

    // 2. الدور
    hash ^= _zobristSideToMoveKeys[board.currentPlayer]!;

    // 3. حقوق التبييت
    if (board.castlingRights[PieceColor.white]![CastlingSide.kingSide]!) {
      hash ^= _zobristCastlingKeys[CastlingSide.kingSide]![PieceColor.white]!;
    }
    if (board.castlingRights[PieceColor.white]![CastlingSide.queenSide]!) {
      hash ^= _zobristCastlingKeys[CastlingSide.queenSide]![PieceColor.white]!;
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.kingSide]!) {
      hash ^= _zobristCastlingKeys[CastlingSide.kingSide]![PieceColor.black]!;
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.queenSide]!) {
      hash ^= _zobristCastlingKeys[CastlingSide.queenSide]![PieceColor.black]!;
    }

    ///
    // 4. هدف الأسر بالمرور
    if (board.enPassantTarget != null) {
      hash ^= _zobristEnPassantKeys[board.enPassantTarget!.col]!;
    }

    return hash;
  }
}

// تعريف بسيط لمدخل جدول التحويل (يمكن أن يكون أكثر تعقيداً)
// يجب أن يحتوي على ما يكفي من المعلومات لاتخاذ قرار جيد.
class TranspositionEntry {
  final int score;
  final int depth; // العمق الذي تم عنده حساب هذه النتيجة
  final NodeType type; // نوع العقدة: EXACT, ALPHA, BETA

  TranspositionEntry(this.score, this.depth, this.type);
}
