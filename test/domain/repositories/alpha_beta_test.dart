import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/alpha_beta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alpha-Beta Pruning Tests', () {
    late AlphaBeta minimax;

    setUp(() {
      minimax = AlphaBeta();
    });

    test('findBestMove returns a valid Move', () async {
      // Arrange
      final board = Board.initial();
      final depth = 3;

      // Act
      final bestMove = await minimax.findBestMove(board, depth);

      // Assert
      expect(bestMove, isNotNull);
      expect(bestMove, isA<Move>());
    });

    test('minimax evaluates board correctly', () async {
      // Arrange
      final board = Board.initial();
      final depth = 2;

      // Act
      final evaluation = minimax.evaluateBoard(board);

      // Assert
      expect(evaluation, isA<int>());
    });
  });
}
