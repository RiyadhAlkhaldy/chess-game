import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/alpha_beta3.dart';
import 'package:chess_gemini_2/domain/repositories/game_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alpha-Beta Pruning Tests', () {
    late GameRepositoryImpl gameRepositoryImpl;
    setUp(() {
      gameRepositoryImpl = GameRepositoryImpl();
    });

    test('findBestMove returns a valid Move', () async {
      int depth = 4;
      Board board = Board.initial(); // Initialize your board here
      for (int i = 0; i < 100; i++) {
        Move? bestMove = await gameRepositoryImpl.getAiMove(
          board,
          board.currentPlayer,
          depth,
        );
        debugPrint('currentPlayer: ${board.currentPlayer} Best move: $bestMove');
        // debugPrint('int3 i = ${AlphaBeta3.i}');
        // debugPrint('ENTRY TRANSP 1 = ${alphaBeta1.entryTransTable}');
        board = gameRepositoryImpl.makeMove(bestMove!);
        // bestMove = await gameRepositoryImpl.findBestMove(board, depth);
        // debugPrint('int4 i = ${AlphaBeta3.i}');
        // // debugPrint('ENTRY TRANSP 2 = ${alphaBeta2.entryTransTable}');
        // board = gameRepositoryImpl.makeMove(bestMove, board);
      }
      // print('currentPlayer: ${board.currentPlayer} Best move: $bestMove');
      debugPrint('int i = ${AlphaBeta3.i} iii');
      // Assert
      // expect(bestMove, isNotNull);
      // expect(bestMove, isA<Move>());
    });

    test('findBestMove returns a valid Move', () async {
      // Arrange
      final board = Board.initial();
      final depth = 4;

      // Act
      final bestMove = await gameRepositoryImpl.getAiMove(
        board,
        board.currentPlayer,
        depth,
      );

      // Assert
      expect(bestMove, isNotNull);
      expect(bestMove, isA<Move>());
    });

    test('minimax evaluates board correctly', () async {
      // Arrange
      final board = Board.initial();

      // Act
      final evaluation = gameRepositoryImpl.evaluateBoard(
        board,
        board.currentPlayer,
      );

      // Assert
      expect(evaluation, isA<int>());
    });
  });
}
