import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/minimax.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Minimax Tests', () {
    late Minimax minimax;
    late String testFen;
    late String initialFen;

    setUp(() {
      minimax = Minimax();
      initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      // initialFen = 'rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1';

      testFen =
          'rnbqk2r/pp3ppp/2p2n2/3p2B1/1b1P4/2N2N2/PP2PPPP/R2QKB1R w KQkq - 0 1';
    });

    test('findBestMove returns a valid Move', () async {
      // Arrange
      final board = Board.fenToBoard(initialFen);
      final depth = 5;

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
      final evaluation = await minimax.minimax(board, depth, true);

      // Assert
      expect(evaluation, isA<int>());
    });
  });

  group('Board Evaluation Tests', () {
    late Minimax minimax;
    setUp(() {
      minimax = Minimax();
    });
    setUp(() {
      // Any setup needed before each test
    });
    test('Initial board evaluation', () {
      // Arrange
      final board = Board.initial();

      // Act
      var evaluation = minimax.evaluateBoard(board);

      // Assert
      expect(evaluation, isNotNull);
    });
  });
}
