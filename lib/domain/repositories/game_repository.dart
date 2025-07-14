// lib/domain/repositories/game_repository.dart
import 'package:dartz/dartz.dart'; // For Either and Tuple2
import '../entities/board.dart';
import '../entities/move.dart';
import '../entities/game_result.dart';
import '../entities/cell.dart';
import '../../core/failures.dart';

/// Abstract interface for managing game state and operations.
/// This defines the contract that concrete implementations in the data layer must fulfill.
abstract class GameRepository {
  /// Applies a given move to the current board state and returns the new board and game result.
  Future<Either<Failure, Tuple2<Board, GameResult>>> applyMove(Board currentBoard, Move move, Either<Failure, List<Move>>? legalMovesResult);

  /// Retrieves all legal moves for a piece at a given starting cell on the board.
  Future<Either<Failure, List<Move>>> getLegalMovesForPiece(Board board, Cell startCell);

  /// Finds the best possible move for the AI given the current board state and search depth.
  Future<Either<Failure, Move>> getBestAIMove(Board board, int depth);

  /// Loads a previously saved game state.
  Future<Either<Failure, Board>> loadGame();

  /// Saves the current game state.
  Future<Either<Failure, Unit>> saveGame(Board board);
}