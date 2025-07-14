// lib/data/ai_engine.dart
import 'dart:math'; // For min/max

import '../domain/entities/board.dart';
import '../domain/entities/cell.dart';
import '../domain/entities/move.dart';
import '../domain/entities/piece.dart';

/// Engine responsible for AI logic and core game rule checks (e.g., check detection).
class AIEngine {
  /// Evaluates the given board state and returns a numerical score.
  /// A higher score is better for White, a lower score is better for Black.
  /// This is a simplified evaluation function.
  double evaluateBoard(Board board) {
    double score = 0;
    final pieceValues = {
      PieceType.pawn: 100.0,
      PieceType.knight: 320.0,
      PieceType.bishop: 330.0,
      PieceType.rook: 500.0,
      PieceType.queen: 900.0,
      PieceType.king: 20000.0, // High value to encourage king safety
    };

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          double pieceValue = pieceValues[piece.type]!;
          // Add positional bonuses/penalties here using Piece Square Tables (PSTs)
          // For simplicity, PSTs are omitted in this runnable example.
          score += (piece.color == PieceColor.white ? pieceValue : -pieceValue);
        }
      }
    }

    // Check game outcome for immediate high/low scores (checkmate/stalemate)
    // Note: This needs careful integration with the main game state logic
    // to avoid redundant checks and ensure consistency.
    // For AI, a simplified check is often integrated directly into the evaluation.
    return score;
  }

  /// Checks if the king of a given color is currently in check on the board.
  bool isKingInCheck(Board board, PieceColor kingColor) {
    final kingPosition = board.kingPositions[kingColor];
    if (kingPosition == null) return false; // Should not happen in a valid game

    final opponentColor =
        kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Iterate through all opponent's pieces
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null && piece.color == opponentColor) {
          // Get raw moves of opponent's piece (does not consider if move puts own king in check)
          // This is critical: we need to know if this piece *threatens* the king.

          final rawMoves = piece.getRawMoves(board, Cell(row: r, col: c));
          for (final move in rawMoves) {
            if (move.end == kingPosition) {
              return true; // King is under attack
            }
          }
        }
      }
    }
    return false;
  }

  bool isKingInCheckWithMoveCastling(
    Board board,
    PieceColor kingColor,
    Move moveCheck,
  ) {
    final kingPosition = board.kingPositions[kingColor];
    if (kingPosition == null) return false; // Should not happen in a valid game

    final opponentColor =
        kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Iterate through all opponent's pieces
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null && piece.color == opponentColor) {
          // Get raw moves of opponent's piece (does not consider if move puts own king in check)
          // This is critical: we need to know if this piece *threatens* the king.

          final rawMoves = piece.getRawMoves(board, Cell(row: r, col: c));
          for (final move in rawMoves) {
            if (move.end == kingPosition) {
              return true; // King is under attack
            } else if (moveCheck.isCastling) {
              if ((moveCheck.end.col == 2 &&
                      move.end.col == moveCheck.end.col + 1) ||
                  (moveCheck.end.col == 6 &&
                      move.end.col == moveCheck.end.col - 1)) {
                // Castling move, check if the king is under attack after castling
                return true; // King is under attack
              }
            }
          }
        }
      }
    }
    return false;
  }

  /// Checks if the game is a draw due to insufficient material.
  /// This is a simplified check and can be expanded for more complex draw rules.
  bool isDrawByInsufficientMaterial(Board board) {
    final allPieces = <PieceType, int>{};
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          allPieces.update(piece.type, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    // King vs King
    if (allPieces.length == 2 &&
        allPieces.containsKey(PieceType.king) &&
        allPieces[PieceType.king] == 2) {
      return true;
    }
    // King + Bishop/Knight vs King
    if (allPieces.length == 3 &&
        allPieces.containsKey(PieceType.king) &&
        allPieces[PieceType.king] == 2) {
      if (allPieces.containsKey(PieceType.bishop) &&
          allPieces[PieceType.bishop] == 1) {
        return true;
      }
      if (allPieces.containsKey(PieceType.knight) &&
          allPieces[PieceType.knight] == 1) {
        return true;
      }
    }
    // King + Bishop vs King + Bishop (on same color squares is a draw) - more complex
    return false;
  }

  /// Finds the best move for the current player using Minimax with Alpha-Beta Pruning.
  /// [depth] defines how many moves ahead the AI will look.
  Future<Move?> findBestMove(Board board, int depth) async {
    Move? bestMove;
    double bestValue =
        board.currentPlayer == PieceColor.white
            ? double.negativeInfinity
            : double.infinity;

    final legalMoves = await _getAllLegalMoves(board, board.currentPlayer);
    if (legalMoves.isEmpty) return null; // No moves available

    // Apply move ordering for Alpha-Beta efficiency
    _sortMoves(legalMoves, board);

    for (final move in legalMoves) {
      final simulatedBoard = _applyMoveForAI(board, move);
      final value = await _minimax(
        simulatedBoard,
        depth - 1,
        board.currentPlayer == PieceColor.white
            ? false
            : true, // Next player's turn
        double.negativeInfinity,
        double.infinity,
      );

      if (board.currentPlayer == PieceColor.white) {
        // Maximizing player (White)
        if (value > bestValue) {
          bestValue = value;
          bestMove = move;
        }
      } else {
        // Minimizing player (Black)
        if (value < bestValue) {
          bestValue = value;
          bestMove = move;
        }
      }
    }
    return bestMove;
  }

  /// Recursive Minimax function with Alpha-Beta Pruning.
  Future<double> _minimax(
    Board board,
    int depth,
    bool isMaximizingPlayer,
    double alpha,
    double beta,
  ) async {
    // Base case: if depth is 0 or game is over (checkmate/stalemate)
    if (depth == 0 || await _isGameOver(board)) {
      return evaluateBoard(board);
    }

    // Get all legal moves for the current player in the simulated board
    final legalMoves = await _getAllLegalMoves(
      board,
      board.currentPlayer,
    ); // Simplified for sync call
    // final legalMoves =  _getAllLegalMoves(board, board.currentPlayer).toCompleter().future.result; // Simplified for sync call
    if (legalMoves.isEmpty) {
      // If no legal moves, check for checkmate or stalemate
      if (isKingInCheck(board, board.currentPlayer)) {
        return isMaximizingPlayer
            ? double.negativeInfinity
            : double.infinity; // Checkmate
      } else {
        return 0.0; // Stalemate
      }
    }

    if (isMaximizingPlayer) {
      double maxEval = double.negativeInfinity;
      for (final move in legalMoves) {
        final simulatedBoard = _applyMoveForAI(board, move);
        final eval = await _minimax(
          simulatedBoard,
          depth - 1,
          false,
          alpha,
          beta,
        );
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          break; // Beta cut-off
        }
      }
      return maxEval;
    } else {
      // Minimizing player
      double minEval = double.infinity;
      for (final move in legalMoves) {
        final simulatedBoard = _applyMoveForAI(board, move);
        final eval = await _minimax(
          simulatedBoard,
          depth - 1,
          true,
          alpha,
          beta,
        );
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) {
          break; // Alpha cut-off
        }
      }
      return minEval;
    }
  }

  /// Helper to get all legal moves for a player (for AI to iterate).
  /// This version is simplified for internal AI use and might not replicate all
  /// complexities of `GameRepositoryImpl.getLegalMovesForPiece`.
  Future<List<Move>> _getAllLegalMoves(
    Board board,
    PieceColor playerColor,
  ) async {
    final List<Move> allLegalMoves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final cell = Cell(row: r, col: c);
        final piece = board.getPieceAt(cell);
        if (piece != null && piece.color == playerColor) {
          final rawMoves = piece.getRawMoves(board, cell);
          for (final move in rawMoves) {
            final simulatedBoard = _simulateMoveForAI(
              board,
              move,
              piece.type,
              piece.color,
            );
            if (!isKingInCheck(simulatedBoard, playerColor)) {
              allLegalMoves.add(move);
            }
          }
          // TODO: Add complex castling and en passant legality checks here for AI
          // TODO: Add complex castling and en passant legality checks here for AI
          // TODO: Add complex castling and en passant legality checks here for AI
          // Castling and en passant are special moves that require additional checks.
          // For castling, check if the king and rook have not moved, and that the
          // squares between them are empty and not under attack.
          // For en passant, check if the last move was a two-square pawn advance
          // and that the target square is adjacent to the pawn's current position.
          // These checks are not included in this simplified version but are crucial
          // for a complete chess engine.
          // These typically involve checking squares under attack by opponent pieces.
          // For example, for castling, you would check if the squares between the king
          // and rook are empty and not under attack, and that the king is not currently
          // in check, and that the squares the king moves through are not under attack.
          if (piece.type == PieceType.king && piece.hasMoved == false) {
            // Check for castling moves
            // final castlingMoves = piece.getCastlingMoves(board, cell);
            // for (final castlingMove in castlingMoves) {
            //   final simulatedBoard = _simulateMoveForAI(
            //     board,
            //     castlingMove,
            //     piece.type,
            //     piece.color,
            //   );
            // if (!isKingInCheck(simulatedBoard, playerColor)) {
            //   allLegalMoves.add(castlingMove);
            // }
            // }
          }
          // For pawns, check for en passant captures
          if (piece.type == PieceType.pawn) {
            // final enPassantMoves = piece.getEnPassantMoves(board, cell);
            // for (final enPassantMove in enPassantMoves) {
            //   final simulatedBoard = _simulateMoveForAI(
            //     board,
            //     enPassantMove,
            //     piece.type,
            //     piece.color,
            //   );
            //   if (!isKingInCheck(simulatedBoard, playerColor)) {
            //     allLegalMoves.add(enPassantMove);
            //   }
            // }
          }
          // For promotions, check if the pawn can promote
          if (piece.type == PieceType.pawn &&
              (piece.color == PieceColor.white && r == 6 ||
                  piece.color == PieceColor.black && r == 1)) {
            // // Pawn can promote, add promotion moves
            // final promotionMoves = piece.getPromotionMoves(board, cell);
            // for (final promotionMove in promotionMoves) {
            //   final simulatedBoard = _simulateMoveForAI(
            //     board,
            //     promotionMove,
            //     piece.type,
            //     piece.color,
            //   );
            //   if (!isKingInCheck(simulatedBoard, playerColor)) {
            //     allLegalMoves.add(promotionMove);
            //   }
            // }
          }

          // Note: This is a simplified version and does not include all complex rules
          // such as pinned pieces, check evasion, or more advanced chess rules.  These typically involve checking squares under attack by opponent pieces.
        }
      }
    }
    return allLegalMoves;
  }

  /// Simulates a move on a board copy, primarily for AI's internal checks.
  Board _simulateMoveForAI(
    Board originalBoard,
    Move move,
    PieceType pieceType,
    PieceColor pieceColor,
  ) {
    Board tempBoard = originalBoard.copyWithDeepPieces();
    tempBoard = tempBoard.placePiece(move.start, null);
    tempBoard = tempBoard.placePiece(
      move.end,
      originalBoard.getPieceAt(move.start)!,
    );

    // Update king position in simulated board if king moved
    if (pieceType == PieceType.king) {
      tempBoard = tempBoard.copyWith(
        kingPositions: Map.from(tempBoard.kingPositions)
          ..update(pieceColor, (value) => move.end),
      );
    }
    // Handle en passant capture in simulation for AI
    if (move.isEnPassant) {
      final capturedPawnCell = Cell(row: move.start.row, col: move.end.col);
      tempBoard = tempBoard.placePiece(capturedPawnCell, null);
    }
    // Handle castling rook move in simulation for AI
    if (move.isCastling) {
      final rookStartCol = move.end.col == 6 ? 7 : 0;
      final rookEndCol = move.end.col == 6 ? 5 : 3;
      final rookPiece = tempBoard.getPieceAt(
        Cell(row: move.start.row, col: rookStartCol),
      );
      if (rookPiece != null) {
        tempBoard = tempBoard.placePiece(
          Cell(row: move.start.row, col: rookStartCol),
          null,
        );
        tempBoard = tempBoard.placePiece(
          Cell(row: move.start.row, col: rookEndCol),
          rookPiece,
        );
      }
    } else if (move.isPromotion && move.promotedPieceType != null) {
      tempBoard = tempBoard.placePiece(
        move.end,
        Piece.create(color: pieceColor, type: move.promotedPieceType!),
      );
    }

    // Switch current player for the next level of the minimax tree
    tempBoard = tempBoard.copyWith(
      currentPlayer:
          originalBoard.currentPlayer == PieceColor.white
              ? PieceColor.black
              : PieceColor.white,
    );
    return tempBoard;
  }

  /// Simplified applyMove for AI's internal simulation.
  Board _applyMoveForAI(Board originalBoard, Move move) {
    Board newBoard = originalBoard.copyWithDeepPieces();
    final piece = newBoard.getPieceAt(move.start);

    if (piece == null) return originalBoard;

    newBoard = newBoard.placePiece(move.start, null); // Remove from start
    newBoard = newBoard.placePiece(
      move.end,
      piece.copyWith(hasMoved: true),
    ); // Place at end, update hasMoved

    // Handle special moves for simulation
    if (move.isEnPassant) {
      final capturedPawnCell = Cell(row: move.start.row, col: move.end.col);
      newBoard = newBoard.placePiece(capturedPawnCell, null);
    } else if (move.isCastling) {
      final rookStartCol = move.end.col == 6 ? 7 : 0;
      final rookEndCol = move.end.col == 6 ? 5 : 3;
      final rookPiece = originalBoard.getPieceAt(
        Cell(row: move.start.row, col: rookStartCol),
      );
      if (rookPiece != null) {
        newBoard = newBoard.placePiece(
          Cell(row: move.start.row, col: rookStartCol),
          null,
        );
        newBoard = newBoard.placePiece(
          Cell(row: move.start.row, col: rookEndCol),
          rookPiece,
        );
      }
    } else if (move.isPromotion && move.promotedPieceType != null) {
      newBoard = newBoard.placePiece(
        move.end,
        Piece.create(color: piece.color, type: move.promotedPieceType!),
      );
    }

    // Update king position for AI check detection
    if (piece.type == PieceType.king) {
      newBoard = newBoard.copyWith(
        kingPositions: Map.from(newBoard.kingPositions)
          ..update(piece.color, (value) => move.end),
      );
    }

    // Switch current player for the next level of the minimax tree
    newBoard = newBoard.copyWith(
      currentPlayer:
          originalBoard.currentPlayer == PieceColor.white
              ? PieceColor.black
              : PieceColor.white,
    );
    return newBoard;
  }

  /// Checks if the game is over (checkmate or stalemate) for AI's internal search.
  Future<bool> _isGameOver(Board board) async {
    // This needs to be a non-async check of legal moves.
    // For a real engine, this would rely on pre-calculated legal moves or a fast, synchronous legal move generator.
    final currentPlayerColor = board.currentPlayer;
    // final hasLegalMoves = _getAllLegalMoves(board, currentPlayerColor).toCompleter().future.result.isNotEmpty;
    final hasLegalMoves = await _getAllLegalMoves(board, currentPlayerColor);

    if (hasLegalMoves.isEmpty) {
      return true; // No legal moves, so it's either checkmate or stalemate
    }
    return false; // Game is not over
  }

  /// Sorts moves for Alpha-Beta Pruning efficiency (captures first, then promotions).
  void _sortMoves(List<Move> moves, Board board) {
    moves.sort((a, b) {
      final aPiece = board.getPieceAt(a.start);
      final bPiece = board.getPieceAt(b.start);

      final aIsCapture = board.getPieceAt(a.end) != null || a.isEnPassant;
      final bIsCapture = board.getPieceAt(b.end) != null || b.isEnPassant;

      // Prioritize captures
      if (aIsCapture && !bIsCapture) return -1;
      if (!aIsCapture && bIsCapture) return 1;

      // Prioritize promotions
      if (a.isPromotion && !b.isPromotion) return -1;
      if (!a.isPromotion && b.isPromotion) return 1;

      // Consider piece values for captures (capturing higher value piece is better)
      if (aIsCapture && bIsCapture) {
        final capturedAPiece = board.getPieceAt(a.end);
        final capturedBPiece = board.getPieceAt(b.end);
        if (capturedAPiece != null && capturedBPiece != null) {
          final pieceValues = {
            PieceType.pawn: 100.0,
            PieceType.knight: 320.0,
            PieceType.bishop: 330.0,
            PieceType.rook: 500.0,
            PieceType.queen: 900.0,
          };
          final aCapturedValue = pieceValues[capturedAPiece.type] ?? 0;
          final bCapturedValue = pieceValues[capturedBPiece.type] ?? 0;
          return (bCapturedValue - aCapturedValue).toInt(); // Descending order
        }
      }

      return 0; // Maintain original order if no specific priority
    });
  }
}
