import 'dart:math';

import '../entities/board.dart';
import '../entities/move.dart';

class AlphaBeta {
  Future<Move?> findBestMove(Board board, int depth) async {
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    Move? bestMove;
    int bestValue = -10000;
    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);

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
