import 'package:chess_gemini_2/core/some_boards_for_test.dart';
import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/piece.dart';
import 'package:chess_gemini_2/domain/repositories/game_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('group AI game_repository_impl', () {
    late GameRepositoryImpl gameRepositoryImpl;
    setUp(() {
      gameRepositoryImpl = GameRepositoryImpl();
    });
    test('test legal moves for white Pwan ', () async {
      Board board1 = gameRepositoryImpl.currentBoard;
      Board board2 = gameRepositoryImpl.currentBoard;
      // Piece? piece1 = board1.squares[0][0];
      // Piece? piece2 = board2.squares[0][0];
      board1 = board1.copyWith(fullMoveNumber: 2);
      // piece1 = piece1!.copyWith(hasMoved: true);
      // debugPrint("piece 1 :${piece1.hashCode}");
      // debugPrint(identityHashCode(piece1).toString());
      // debugPrint("piece 2 :${piece2.hashCode}");
      // debugPrint(identityHashCode(piece2).toString());
      // // debugPrint(piece2.hashCode.toString());
      // debugPrint((piece1 == piece2).toString());
      ////////
      debugPrint(board1.squares[0][0].toString());
      debugPrint(board2.squares[0][0].toString());

      ///
      board1.squares[0][0] = Knight(
        color: PieceColor.black,
        type: PieceType.knight,
      );
      debugPrint(board1.squares[0][0].toString());
      debugPrint(board2.squares[0][0].toString());

      debugPrint(board1.hashCode.toString());
      debugPrint(identityHashCode(board1).toString());
      debugPrint(board2.hashCode.toString());
      debugPrint(identityHashCode(board2).toString());

      ///
      // debugPrint(board1.hashCode.toString());
      // debugPrint(board2.hashCode.toString());
      // debugPrint((board1.hashCode == board2.hashCode).toString());
    });

    ///
    ///

    test('test legal moves for black knight', () async {
      gameRepositoryImpl.currentBoard = SomeBaordsForAITest.statrtAIasBlack;
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      debugPrint('\n new \n');

      final move = await gameRepositoryImpl.getAiMove(
        gameRepositoryImpl.currentBoard,
        gameRepositoryImpl.currentBoard.currentPlayer,
        5,
      );
      // debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      // debugPrint('\n new \n');
      debugPrint(gameRepositoryImpl.getGameResult().toString());

      gameRepositoryImpl.makeMove(move!);
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      debugPrint('\n new \n');

      // final response = gameRepositoryImpl.getLegalMoves(Cell(row: 0, col: 1));
      // debugPrint(response.toString());
    });

    test('test get game result king vs king', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.kingVsKing;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });
  });
}
