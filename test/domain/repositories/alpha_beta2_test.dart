import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/alpha_beta2.dart'
    show AlphaBeta2;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alpha-Beta Pruning Tests', () {
    late AlphaBeta2 alphaBeta;

    setUp(() {
      alphaBeta = AlphaBeta2();
    });

    test('findBestMove returns a valid Move', () async {
      Board board = Board.initial(); // Initialize your board here
      for (int i = 0; i < 10; i++) {
        Move? bestMove = await alphaBeta.findBestMove(board, 4);
        // print('currentPlayer: ${board.currentPlayer} Best move: $bestMove');
        debugPrint('value= ${AlphaBeta2.i}  int i=$i ');
        board = alphaBeta.makeMove(bestMove!, board);
      }
      // print('currentPlayer: ${board.currentPlayer} Best move: $bestMove');
      debugPrint('int i = ${AlphaBeta2.i} iii');
      // Assert
      // expect(bestMove, isNotNull);
      // expect(bestMove, isA<Move>());
    });

    test('findBestMove returns a valid Move', () async {
      // Arrange
      final board = Board.initial();
      final depth = 4;

      // Act
      final bestMove = await alphaBeta.findBestMove(board, depth);

      // Assert
      expect(bestMove, isNotNull);
      expect(bestMove, isA<Move>());
    });

    test('minimax evaluates board correctly', () async {
      // Arrange
      final board = Board.initial();

      // Act
      final evaluation = alphaBeta.evaluateBoard(board);

      // Assert
      expect(evaluation, isA<int>());
    });
  });
}
// depth = 3
// int i = 1260
// int i = 1219
// int i = 1301
// int i = 1462
// int i = 1454
// int i = 1430
// int i = 1580
// int i = 1502
// int i = 1457
// int i = 1461
// int i = 1461 iii

// depth = 4
// int i = 13157
// int i = 17226
// int i = 21086
// int i = 25822
// int i = 21286
// int i = 24545
// int i = 24107
// int i = 36161
// int i = 32982
// int i = 34758
