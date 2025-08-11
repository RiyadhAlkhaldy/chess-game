import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/game_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alpha-Beta Pruning Tests', () {
    late GameRepositoryImpl gameRepository;

    setUp(() {
      gameRepository = GameRepositoryImpl();
    });

    test('findBestMove returns a valid Move', () async {
      // Arrange
      final board = Board.initial();
      final depth = 4;

      // Act
      final bestMove = await gameRepository.getAiMove(
        board,
        gameRepository.currentBoard.currentPlayer,
        depth,
      );

      // Assert
      expect(bestMove, isNotNull);
      expect(bestMove, isA<Move>());
    });

    test('minimax evaluates board correctly', () async {
      // Arrange
      final board = Board.initial();
      final depth = 2;

      // Act
      final evaluation = gameRepository.evaluateBoard(
        board,
        board.currentPlayer,
      );

      // Assert
      expect(evaluation, isA<int>());
    });
  });
}
