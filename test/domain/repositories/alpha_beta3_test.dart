import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/repositories/alpha_beta3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alpha-Beta Pruning Tests', () {
    late AlphaBeta3 alphaBeta1;
    late AlphaBeta4 alphaBeta2;

    setUp(() {
      alphaBeta1 = AlphaBeta3();
      alphaBeta2 = AlphaBeta4();
    });

    test('findBestMove returns a valid Move', () async {
      int depth = 3;
      Board board = Board.initial(); // Initialize your board here
      for (int i = 0; i < 20; i++) {
        Move? bestMove = await alphaBeta1.findBestMove(board, depth);
        debugPrint('int3 i = ${AlphaBeta3.i}');
        board = alphaBeta1.makeMove(bestMove!, board);
        bestMove = await alphaBeta2.findBestMove(board, depth);
        debugPrint('int4 i = ${AlphaBeta3.i}');
        board = alphaBeta2.makeMove(bestMove!, board);
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
      final bestMove = await alphaBeta1.findBestMove(board, depth);

      // Assert
      expect(bestMove, isNotNull);
      expect(bestMove, isA<Move>());
    });

    test('minimax evaluates board correctly', () async {
      // Arrange
      final board = Board.initial();

      // Act
      final evaluation = alphaBeta1.evaluateBoard(board, board.currentPlayer);

      // Assert
      expect(evaluation, isA<int>());
    });
  });
}

// int3 i = 538
// int4 i = 535
// int3 i = 0
// int4 i = 0
// int3 i = 646
// int4 i = 573
// int3 i = 0
// int4 i = 0
// int3 i = 1999
// int4 i = 614
// int3 i = 0
// int4 i = 0
// int3 i = 794
// int4 i = 540
// int3 i = 0
// int4 i = 0
// int3 i = 933
// int4 i = 549
// int3 i = 0
// int4 i = 0
// int3 i = 3153
// int4 i = 608
// int3 i = 0
// int4 i = 0
// int3 i = 4438
// int4 i = 572
// int3 i = 0
// int4 i = 0
// int3 i = 3381
// int4 i = 648
// int3 i = 0
// int4 i = 0
// int3 i = 4632
// int4 i = 621
// int3 i = 0
// int4 i = 0
// int3 i = 4911
// int4 i = 643
// int3 i = 0
// int4 i = 0
// int i = 0 iii


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

// depth 3 
// int3 i = 538
// int4 i = 535
// int3 i = 0
// int4 i = 535
// int3 i = 646
// int4 i = 1108
// int3 i = 0
// int4 i = 1108
// int3 i = 1999
// int4 i = 1722
// int3 i = 0
// int4 i = 1722
// int3 i = 794
// int4 i = 2262
// int3 i = 0
// int4 i = 2262
// int3 i = 933
// int4 i = 2811
// int3 i = 0
// int4 i = 2811
// int i = 0 iii

// another

// int3 i = 538
// int4 i = 535
// int3 i = 503
// int4 i = 1142
// int3 i = 646
// int4 i = 1717
// int3 i = 751
// int4 i = 2324
// int3 i = 708
// int4 i = 2897
// int3 i = 701
// int4 i = 3455
// int3 i = 723
// int4 i = 3991
// int3 i = 1119
// int4 i = 4566
// int3 i = 1262
// int4 i = 5110
// int3 i = 1586
// int4 i = 5681
// int i = 0 iii

// depth 4
// int3 i = 1436
// int4 i = 1349
// int3 i = 0
// int4 i = 1349
// int3 i = 16253
// int4 i = 2874
// int3 i = 0
// int4 i = 2874
// int3 i = 14160
// int4 i = 26869
// int3 i = 0
// int4 i = 26869
// int3 i = 14526
// int4 i = 32622
// int3 i = 0
// int4 i = 32622
// int3 i = 26796
// int4 i = 53095
// int3 i = 0
// int4 i = 53095
// int i = 0 iii
//
//
// int3 i = 1436
// int4 i = 1349
// int3 i = 4089
// int4 i = 19228
// int3 i = 2792
// int4 i = 36368
// int3 i = 6476
// int4 i = 54235
// int3 i = 10075
// int4 i = 67964
// int3 i = 11939
// int4 i = 82555
// int3 i = 5448
// int4 i = 96036
// int3 i = 10635
// int4 i = 96059
// int3 i = 71
// int4 i = 96081
// int3 i = 31
// int4 i = 96190
// int i = 0 iii