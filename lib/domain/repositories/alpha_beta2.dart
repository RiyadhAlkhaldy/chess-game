import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

class AlphaBeta2 {
  static int i = 0;
  Future<Move?> findBestMove(Board board, int depth) async {
    i = 0; // Reset the counter for each call
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    int alpha = -1000000;
    int beta = 1000000;
    Move? bestMove;
    int bestValue = -10000;
    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);
      // Use alpha-beta pruning to evaluate the move
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

      // تحديث alpha بعد كل حركة، لأن getAiMove تعمل كلاعب معظّم
      alpha = max(alpha, bestValue);
      // إذا حدث تقليم هنا، يمكننا الخروج مبكراً
      if (beta <= alpha) break;
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
    i++; // Increment the counter for each call
    if (depth == 0 || board.isGameOver()) {
      return board.evaluateBoard();
    }

    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();

    if (isMaximizing) {
      int bestValue = -1000000;

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
        alpha = max(alpha, bestValue);

        if (beta <= alpha) {
          break; // Beta cut-off
        }
      }

      return bestValue;
    } else {
      int bestValue = 1000000;

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
        beta = min(beta, bestValue);

        if (beta <= alpha) {
          break; // Alpha cut-off
        }
      }

      return bestValue;
    }
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
      newCastlingRights = newCastlingRights..update(
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

  int evaluateBoard(Board board) {
    // Implement your board evaluation logic here

    return board.evaluateBoard();
  }
}
