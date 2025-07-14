// lib/domain/usecases/get_legal_moves_usecase.dart
import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/move.dart';
import '../repositories/game_repository.dart';

/// Use case for getting all legal moves for a piece at a specific cell.
class GetLegalMovesUseCase {
  final GameRepository repository; // Dependency on the GameRepository interface

  GetLegalMovesUseCase(this.repository);

  /// Executes the use case to get legal moves.
  /// Returns an [Either] with a [Failure] on the left or a [List<Move>] on the right.
  Future<Either<Failure, List<Move>>> call(Board board, Cell startCell) async {
    return await repository.getLegalMovesForPiece(board, startCell);
  }

  /// Executes the use case to get legal moves for a piece at a specific cell.
  /// Returns an [Either] with a [Failure] on the left or a [List
  /// <Move>] on the right.
  Future<Either<Failure, List<Move>>> getLegalMoves(
    Board board,
    Cell startCell,
  ) async {
    return await call(board, startCell);
  }
}
