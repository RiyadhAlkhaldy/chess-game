// lib/domain/usecases/get_best_move_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/board.dart';
import '../entities/move.dart';
import '../repositories/game_repository.dart';
import '../../core/failures.dart';

/// Use case for getting the best AI move.
class GetBestMoveUseCase {
  final GameRepository repository; // Dependency on the GameRepository interface

  GetBestMoveUseCase(this.repository);

  /// Executes the use case to find the best AI move.
  /// Returns an [Either] with a [Failure] on the left or a [Move] on the right.
  Future<Either<Failure, Move>> call(Board board, int depth) async {
    return await repository.getBestAIMove(board, depth);
  }
}