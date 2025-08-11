import 'package:chess_gemini_2/core/some_boards_for_test.dart';
import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/cell.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/entities/piece.dart';
import 'package:chess_gemini_2/domain/repositories/game_repository_impl.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('group game_repository_impl', () {
    late GameRepositoryImpl gameRepositoryImpl;
    setUp(() {
      // gameRepositoryImpl = Get.find<GameRepository>();
      gameRepositoryImpl = GameRepositoryImpl();
    });
    test('test legal moves for white Pwan ', () async {
      final response = gameRepositoryImpl.getLegalMoves(Cell(row: 6, col: 1));
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      debugPrint(response.toString());
    });
    test('test en passant moves for Pwan ', () async {
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());

      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 6, col: 0),
          end: Cell(row: 4, col: 0),
          isTwoStepPawnMove: true,
          movedPiece: Pawn(
            color: PieceColor.white,
            type: PieceType.pawn,
            hasMoved: false,
          ),
        ),
      );
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());

      ///

      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 1, col: 2),
          end: Cell(row: 3, col: 2),
          movedPiece: Pawn(
            color: PieceColor.black,
            type: PieceType.pawn,
            hasMoved: false,
          ),
          isTwoStepPawnMove: true,
        ),
      );
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());

      ///
      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 4, col: 0),
          end: Cell(row: 3, col: 0),
          movedPiece: Pawn(
            color: PieceColor.white,
            type: PieceType.pawn,
            hasMoved: true,
          ),
        ),
      );
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());

      ///

      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 1, col: 1),
          end: Cell(row: 3, col: 1),
          movedPiece: Pawn(
            color: PieceColor.black,
            type: PieceType.pawn,
            hasMoved: false,
          ),
          isTwoStepPawnMove: true,
        ),
      );
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
    });

    ///
    ///

    test('test legal moves for white knight', () async {
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());

      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 7, col: 1),
          end: Cell(row: 5, col: 2),
          movedPiece: Knight(
            color: PieceColor.white,
            type: PieceType.knight,
            hasMoved: false,
          ),
        ),
      );
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      debugPrint('\n new \n');

      final board = gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 6, col: 1),
          end: Cell(row: 5, col: 1),
          movedPiece: Pawn(
            color: PieceColor.black,
            type: PieceType.pawn,
            hasMoved: false,
          ),
        ),
      );

      debugPrint('\n new \n');

      debugPrint(board.positionHistory.toString());
      debugPrint('\n new \n');

      final response = gameRepositoryImpl.getLegalMoves(Cell(row: 0, col: 1));
      debugPrint(response.toString());
    });

    test('test get game result king vs king', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.kingVsKing;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });

    test('test get game result kingAndBishopVSKing', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.kingAndBishopVSKing;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });
    test('test get game result kingAndBishopVSKingAndBishopAnother', () async {
      gameRepositoryImpl.currentBoard =
          SomeBoardsForTest.kingAndBishopVSKingAndBishopAnother;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });

    ///
    ///
    test('test get game result Draw of Stalemate', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.drawFoStalemate;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });

    ///
    ///
    test('test get game result CheckMate', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.checkMate;
      gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 1, col: 2),
          end: Cell(row: 1, col: 1),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });

    ///
    ///
    test('test get game result kingAndKnightVSKing', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.kingAndKnightVSKing;

      final response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());
    });

    ///
    ///
    ///
    test('test get game result for three fold reoetition', () async {
      gameRepositoryImpl.currentBoard = SomeBoardsForTest.initial();
      debugPrint(gameRepositoryImpl.currentBoard.positionHistory.toString());
      debugPrint(gameRepositoryImpl.currentBoard.currentPlayer.toString());

      final board1 = gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 6, col: 4),
          end: Cell(row: 4, col: 4),
          movedPiece: Pawn(
            color: PieceColor.white,
            type: PieceType.pawn,
            hasMoved: false,
          ),
        ),
      );
      final board2 = gameRepositoryImpl.makeMove(
        Move(
          start: Cell(row: 1, col: 4),
          end: Cell(row: 3, col: 4),
          movedPiece: Pawn(
            color: PieceColor.black,
            type: PieceType.pawn,
            hasMoved: false,
          ),
        ),
      );
      final board3 = gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 7, col: 3),
          end: Cell(row: 5, col: 5),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: false,
          ),
        ),
      );
      final board4 = gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 0, col: 3),
          end: Cell(row: 2, col: 5),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: false,
          ),
        ),
      );

      final board5 = gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 5, col: 5),
          end: Cell(row: 7, col: 3),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      final board6 = gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 2, col: 5),
          end: Cell(row: 0, col: 3),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );

      ///
      ///
      ///
      gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 7, col: 3),
          end: Cell(row: 5, col: 5),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 0, col: 3),
          end: Cell(row: 2, col: 5),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );

      gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 5, col: 5),
          end: Cell(row: 7, col: 3),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 2, col: 5),
          end: Cell(row: 0, col: 3),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );

      ///
      ///
      ///
      gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 7, col: 3),
          end: Cell(row: 5, col: 5),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 0, col: 3),
          end: Cell(row: 2, col: 5),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );

      gameRepositoryImpl.makeMove(
        // move white queen
        Move(
          start: Cell(row: 5, col: 5),
          end: Cell(row: 7, col: 3),
          movedPiece: Queen(
            color: PieceColor.white,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      gameRepositoryImpl.makeMove(
        // move black queen
        Move(
          start: Cell(row: 2, col: 5),
          end: Cell(row: 0, col: 3),
          movedPiece: Queen(
            color: PieceColor.black,
            type: PieceType.queen,
            hasMoved: true,
          ),
        ),
      );
      var response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());

      ///
      ///
      debugPrint(board1.positionHistory.toString());
      debugPrint(board2.positionHistory.toString());
      debugPrint(board3.positionHistory.toString());
      debugPrint(board4.positionHistory.toString());
      debugPrint(board5.positionHistory.toString());
      debugPrint(board6.positionHistory.toString());
      debugPrint(
        (board2.positionHistory.equals(board6.positionHistory)).toString(),
      );
      debugPrint(board2.hashCode.toString());
      debugPrint(board2.currentPlayer.toString());
      debugPrint(board6.hashCode.toString());
      debugPrint(board6.currentPlayer.toString());

      response = gameRepositoryImpl.getGameResult();
      debugPrint(response.toString());

      ///
      ///
      printBoard(board2);
      printBoard(board6);
      // expect(board6.positionHistory, board2.positionHistory);
      // expect(gameRepositoryImpl.currentBoard,board5 );
    });
    // tearDown(() {});
  });
}

void printBoard(Board board) {
  for (var i = 0; i < 8; i++) {
    String pieces = '';
    for (var j = 0; j < 8; j++) {
      final piece = board.squares[i][j];
      if (piece != null) {
        // debugPrint(piece.type.name);
        var p = "${piece.type.name.substring(0, 2)} ";
        if (p == "kn") {
          if (piece.color == PieceColor.white) {
            pieces += "${p.substring(1, 2).toUpperCase()} ";
          } else {
            pieces += "${p.substring(1, 2).toLowerCase()} ";
          }
        } else {
          if (piece.color == PieceColor.white) {
            pieces += "${p.substring(0, 1).toUpperCase()} ";
          } else {
            pieces += "${p.substring(0, 1).toLowerCase()} ";
          }
        }
      } else {
        // debugPrint(null);
        pieces += ". ";
      }
    }
    debugPrint(pieces);
    pieces = "";
  }
}

extension MakeBoardForTest on GameRepositoryImpl {
  set currentBaord(Board board) => currentBoard = board;
  get cuttentBoard => currentBoard;
}
