// lib/domain/usecases/make_move_usecase.dart
import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/board.dart';
import '../entities/game_result.dart';
import '../entities/move.dart';
import '../repositories/game_repository.dart';

/// Use case for making a move in the chess game.
class MakeMoveUseCase {
  final GameRepository repository; // Dependency on the GameRepository interface

  MakeMoveUseCase(this.repository);

  /// Executes the use case to apply a move.
  /// Returns an [Either] with a [Failure] on the left or a [Tuple2] containing
  /// the new [Board] state and [GameResult] on the right.
  Future<Either<Failure, Tuple2<Board, GameResult>>> call(
    Board currentBoard,
    Move move,
    Either<Failure, List<Move>>? legalMovesResult,
  ) async {
    return await repository.applyMove(currentBoard, move, legalMovesResult);
  }
}
