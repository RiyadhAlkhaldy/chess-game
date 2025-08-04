import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/board.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

class Minimax {
  static int i = 0;
  Future<Move?> findBestMove(Board board, int depth) async {
    int bestValue = -10000;
    Move? bestMove;
    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();
    for (Move move in legalMoves) {
      Board simulatedBoard = board.simulateMove(move);
      // i++;
      // printBoard(simulatedBoard, depth, move, i);
      int moveValue = await minimax(simulatedBoard, depth - 1, false);

      if (moveValue > bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
      // debugPrint("indexx: $i");
    }
    debugPrint("index: $i");
    i = 0; // Reset index for next call
    return bestMove;
  }

  Future<int> minimax(Board board, int depth, bool isMaximizing) async {
    i++; // Increment index for each call
    // printBoard(board, depth, null, ++i);
    if (depth == 0 || board.isGameOver()) {
      return board.evaluateBoard();
    }

    List<Move> legalMoves = board.getAllLegalMovesForCurrentPlayer();

    if (isMaximizing) {
      int bestValue = -10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        int moveValue = await minimax(simulatedBoard, depth - 1, false);
        bestValue = max(bestValue, moveValue);
      }
      return bestValue;
    } else {
      int bestValue = 10000;
      for (Move move in legalMoves) {
        Board simulatedBoard = board.simulateMove(move);
        int moveValue = await minimax(simulatedBoard, depth - 1, true);
        bestValue = min(bestValue, moveValue);
      }
      return bestValue;
    }
  }

  int evaluateBoard(Board board) {
    // Implement your board evaluation logic here
    return board.evaluateBoard();
  }
}

void printBoard(Board board, [int? depth, Move? move, int? ii]) {
  // if (depth != null && depth <= 1) return;
  debugPrint("$ii starting printing board --------------");
  for (var i = 0; i < 8; i++) {
    String pieces = '';
    for (var j = 0; j < 8; j++) {
      final piece = board.squares[i][j];
      if (piece != null) {
        // debugPrint(piece.type.name);
        var p = "${piece.type.name.substring(0, 2)} ";
        if (p == "kn") {
          if (piece.color == PieceColor.white) {
            pieces += "${p.substring(1, 2).toUpperCase()} ";
          } else {
            pieces += "${p.substring(1, 2).toLowerCase()} ";
          }
        } else {
          if (piece.color == PieceColor.white) {
            pieces += "${p.substring(0, 1).toUpperCase()} ";
          } else {
            pieces += "${p.substring(0, 1).toLowerCase()} ";
          }
        }
      } else {
        // debugPrint(null);
        pieces += ". ";
      }
    }
    debugPrint(pieces);
    pieces = "";
  }
  debugPrint(board.toFenString());
  if (depth != null) {
    debugPrint("Depth: $depth");
  }
  debugPrint("Current Player: ${board.currentPlayer}");
  if (move != null) {
    debugPrint("Move: ${move.start} to ${move.end}");
  }
}
