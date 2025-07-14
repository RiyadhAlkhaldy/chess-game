// lib/data/repositories/game_repository_impl.dart
import 'package:dartz/dartz.dart'; // For Either and Tuple2
import 'package:flutter/material.dart';

import '../../../core/failures.dart';
import '../../data/ai_engine.dart';
import '../../data/local_storage_service.dart';
import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/game_result.dart';
import '../entities/move.dart';
import '../entities/piece.dart';
import 'game_repository.dart';

/// Concrete implementation of the [GameRepository] interface.
/// It handles the actual game logic, interaction with AI, and local storage.
/// إنه يتعامل مع منطق اللعبة الفعلي والتفاعل مع الذكاء الاصطناعي والتخزين المحلي.
class GameRepositoryImpl implements GameRepository {
  final LocalStorageService localStorageService;
  final AIEngine aiEngine; // Dependency on the AI engine

  GameRepositoryImpl(this.localStorageService, this.aiEngine);

  @override
  Future<Either<Failure, Tuple2<Board, GameResult>>> applyMove(
    Board currentBoard,
    Move move,
    Either<Failure, List<Move>>? legalMovesResult,
  ) async {
    // try {
    final pieceToMove = currentBoard.getPieceAt(move.start);

    // Basic validation: piece exists and belongs to current player
    if (pieceToMove == null ||
        pieceToMove.color != currentBoard.currentPlayer) {
      return Left(
        InvalidMoveFailure(message: 'No piece at start cell or not your turn.'),
      );
    }

    // Check if the move is actually legal for this piece (important validation)
    legalMovesResult ??= await getLegalMovesForPiece(currentBoard, move.start);
    if (legalMovesResult.isLeft()) {
      debugPrint(
        "in GameRepositoryImpl applyMove legalMovesResult isLeft ${legalMovesResult.fold((l) => l.message, (r) => 'Success')}",
      );
      return Left(
        legalMovesResult.fold(
          (l) => l,
          (r) => throw Exception("Unexpected state"),
        ),
      );
    }
    final legalMoves = legalMovesResult.getOrElse(() => []);
    debugPrint("in GameRepositoryImpl applyMove legalMoves $legalMoves \n");

    // Find the exact legal move from the list (important for promotion, castling, en passant flags)
    final actualLegalMove = legalMoves.firstWhereOrNull(
      (m) => m.start == move.start && m.end == move.end,
    );

    debugPrint(
      "in GameRepositoryImpl applyMove actualLegalMove $actualLegalMove \n",
    );

    if (actualLegalMove == null) {
      return Left(InvalidMoveFailure(message: 'Illegal move.'));
    }

    // Create a new board state to apply the move immutably
    Board newBoard = currentBoard.copyWithDeepPieces();

    if (pieceToMove.type == PieceType.king) {
      // Handle special moves
      if (actualLegalMove.isCastling) {
        // Move the rook during castling
        final rookRow = actualLegalMove.start.row;
        final rookStartCol =
            actualLegalMove.end.col == 6 ? 7 : 0; // King-side: 7, Queen-side: 0
        final rookEndCol =
            actualLegalMove.end.col == 6 ? 5 : 3; // King-side: 5, Queen-side: 3
        final rook = newBoard.getPieceAt(Cell(row: rookRow, col: rookStartCol));

        if (rook != null) {
          newBoard = newBoard
              .placePiece(Cell(row: rookRow, col: rookStartCol), null)
              .placePiece(
                Cell(row: rookRow, col: rookEndCol),
                rook.copyWith(hasMoved: true),
              )
              .copyWith(
                kingPositions: Map.from(newBoard.kingPositions)
                  ..update(newBoard.currentPlayer, (value) => move.end),
              );
        }
      } else {
        newBoard = newBoard
            .placePiece(move.start, null)
            .placePiece(move.end, pieceToMove.copyWith(hasMoved: true))
            .copyWith(
              kingPositions: Map.from(newBoard.kingPositions)
                ..update(currentBoard.currentPlayer, (value) => move.end),
            );
      }
    } else {
      // Perform the move: remove piece from start, place at end
      newBoard = newBoard
          .placePiece(move.start, null)
          .placePiece(move.end, pieceToMove.copyWith(hasMoved: true));

      if (actualLegalMove.isEnPassant) {
        // Remove the captured pawn for en passant
        final capturedPawnCell = Cell(
          row: actualLegalMove.start.row,
          col: actualLegalMove.end.col,
        );
        newBoard = newBoard.placePiece(capturedPawnCell, null);
      } else if (move.isPromotion && move.promotedPieceType != null) {
        // Replace pawn with the promoted piece
        newBoard = newBoard.placePiece(
          move.end,
          Piece.create(color: pieceToMove.color, type: move.promotedPieceType!),
        );
      }
    }
    // Update board properties for the new state
    // Switch the current player
    // Note: This assumes the move is valid and has been checked against legal moves
    newBoard = _switchCurrentPlayer(
      newBoard,
      currentBoard,
      actualLegalMove,
      pieceToMove,
    );
    final gameResult = await _checkGameStatus(newBoard);
    debugPrint("in GameRepositoryImpl applyMove last newBoard $newBoard \n");
    // Check the new game status

    return Right(Tuple2(newBoard, gameResult));
    // } catch (e) {
    //   return Left(GameFailure(message: 'Failed to apply move: $e'));
    // }
  }

  Board _switchCurrentPlayer(
    Board newBoard,
    Board currentBoard,
    Move actualLegalMove,
    Piece? pieceToMove,
  ) {
    final nextPlayer =
        currentBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
    return newBoard.copyWith(
      currentPlayer: nextPlayer,
      moveHistory:
          currentBoard.moveHistory, // Add the actual legal move with its flags
      kingPositions:
          newBoard.kingPositions, // Update king position if king moved
      enPassantTarget:
          actualLegalMove.isTwoStepPawnMove
              ? Cell(
                row: (actualLegalMove.start.row + actualLegalMove.end.row) ~/ 2,
                col: actualLegalMove.start.col,
              )
              : null, // Set en passant target if pawn moved two squares
      halfMoveClock:
          actualLegalMove.isCapture || pieceToMove!.type == PieceType.pawn
              ? 0
              : newBoard.halfMoveClock + 1, // Reset on capture/pawn move
      fullMoveNumber:
          nextPlayer == PieceColor.white
              ? newBoard.fullMoveNumber + 1
              : newBoard
                  .fullMoveNumber, // Increment full move number after Black's move
      // castlingRights: _updateCastlingRights(
      //   newBoard.castlingRights,
      //   actualLegalMove,
      //   pieceToMove!.color,
      // ), // Update castling rights
    );
  }

  Future<Either<Failure, List<Move>>> getLegalMovesForPieces(
    Board board,
    Cell startCell,
  ) async {
    final piece = board.getPieceAt(startCell);
    if (piece == null) {
      return Left(InvalidInputFailure(message: 'No piece at selected cell.'));
    }

    // 1. Get all raw moves for the piece
    final rawMoves = piece.getRawMoves(board, startCell);

    final legalMoves = <Move>[];

    // 2. Filter out moves that leave the king in check
    for (final move in rawMoves) {
      final simulatedBoard = _simulateMove(
        board,
        move,
        piece.type,
        piece.color,
      ); // Pass piece type/color for king position update
      if (!aiEngine.isKingInCheckWithMoveCastling(
        simulatedBoard,
        piece.color,
        move,
      )) {
        legalMoves.add(move);
      }
    }

    return Right(legalMoves);
  }

  @override
  Future<Either<Failure, List<Move>>> getLegalMovesForPiece(
    Board board,
    Cell startCell,
  ) async {
    // try {
    final piece = board.getPieceAt(startCell);
    if (piece == null) {
      return Left(InvalidInputFailure(message: 'No piece at selected cell.'));
    }

    // 1. Get all raw moves for the piece
    final rawMoves = piece.getRawMoves(board, startCell);

    final legalMoves = <Move>[];

    // 2. Filter out moves that leave the king in check
    for (final move in rawMoves) {
      final simulatedBoard = _simulateMove(
        board,
        move,
        piece.type,
        piece.color,
      ); // Pass piece type/color for king position update
      // debugPrint("in GameRepositoryImpl simulatedBoard $simulatedBoard \n");
      //
      if (!aiEngine.isKingInCheckWithMoveCastling(
        simulatedBoard,
        piece.color,
        move,
      )) {
        legalMoves.add(move);
      }
      debugPrint("in GameRepositoryImpl isKingInCheck  \n");
    }

    // 3. Add/Validate special moves that require more complex board state checks
    //    (Castling and En Passant need special handling here as their legality
    //     goes beyond just not being in check after the move).

    // Castling specific checks (not just king being in check after move, but passing through check)
    if (piece.type == PieceType.king) {
      _addLegalCastlingMoves(board, piece.color, legalMoves);
    }

    // En Passant specific validation (ensure previous move enabled it)
    // Filter out invalid en passant moves (those generated by raw moves but not actually legal)
    // legalMoves.removeWhere(
    //   (move) => move.isEnPassant && !_isValidEnPassant(board, move),
    // );

    return Right(legalMoves);
    // } catch (e) {
    //   return Left(GameFailure(message: 'Failed to get legal moves: $e'));
    // }
  }

  /// Simulates a move on a deep copy of the board. Used for checking if a move leads to check.
  Board _simulateMove(
    Board originalBoard,
    Move move,
    PieceType pieceType,
    PieceColor pieceColor,
  ) {
    Board tempBoard = originalBoard.copyWithDeepPieces();
    // debugPrint(" tempBoard == originalBoard $tempBoard");
    tempBoard = tempBoard
        .placePiece(move.start, null)
        .placePiece(move.end, originalBoard.getPieceAt(move.start));

    // Update king's position in the simulated board if the king itself moved
    if (pieceType == PieceType.king) {
      tempBoard = tempBoard.copyWith(
        kingPositions: Map.from(tempBoard.kingPositions)
          ..update(pieceColor, (value) => move.end),
      );
    }

    // // Handle special move effects in simulation for correct check detection
    // if (move.isEnPassant) {
    //   // Remove the captured pawn for en passant
    //   final capturedPawnCell = Cell(row: move.start.row, col: move.end.col);
    //   tempBoard = tempBoard.placePiece(capturedPawnCell, null);
    // } else

    // if (move.isCastling) {
    //   // Move the rook as well in simulation
    //   // Determine the rook's start and end columns based on castling side
    //   // King-side castling: rook starts at col 7, ends at col 5
    //   // Queen-side castling: rook starts at col 0, ends at col 3
    //   // Note: This assumes the move.end.col is either 6 (king-side) or 2 (queen-side)
    //   final rookStartCol = move.end.col == 6 ? 7 : 0;
    //   final rookEndCol = move.end.col == 6 ? 5 : 3;
    //   final rookPiece = tempBoard.getPieceAt(
    //     Cell(row: move.start.row, col: rookStartCol),
    //   );
    //   if (rookPiece != null) {
    //     tempBoard = tempBoard.placePiece(
    //       Cell(row: move.start.row, col: rookStartCol),
    //       null,
    //     );
    //     tempBoard = tempBoard.placePiece(
    //       Cell(row: move.start.row, col: rookEndCol),
    //       rookPiece,
    //     );
    //   }
    // } else if (move.isPromotion && move.promotedPieceType != null) {
    //   // Replace pawn with promoted piece in simulation
    //   tempBoard = tempBoard.placePiece(
    //     move.end,
    //     Piece.create(color: pieceColor, type: move.promotedPieceType!),
    //   );
    // }
    return tempBoard;
  }

  /// Adds legal castling moves to the list if all conditions are met.
  void _addLegalCastlingMoves(
    Board board,
    PieceColor color,
    List<Move> legalMoves,
  ) {
    final kingRow = color == PieceColor.white ? 7 : 0;
    final kingCell = Cell(row: kingRow, col: 4);
    final king = board.getPieceAt(kingCell);

    if (king == null || king.hasMoved || aiEngine.isKingInCheck(board, color)) {
      return; // King has moved, or is in check, or no king found
    }

    // King-side castling
    if (board.castlingRights[color]![CastlingSide.kingSide]!) {
      final rookCell = Cell(row: kingRow, col: 7);
      final path1 = Cell(row: kingRow, col: 5);
      final path2 = Cell(row: kingRow, col: 6);

      final rook = board.getPieceAt(rookCell);

      if (rook?.type == PieceType.rook &&
          !rook!.hasMoved &&
          board.getPieceAt(path1) == null &&
          board.getPieceAt(path2) == null &&
          !aiEngine.isKingInCheck(
            _simulateMove(
              board,
              Move(start: kingCell, end: path1),
              PieceType.king,
              color,
            ),
            color,
          ) &&
          !aiEngine.isKingInCheck(
            _simulateMove(
              board,
              Move(start: kingCell, end: path2),
              PieceType.king,
              color,
            ),
            color,
          )) {
        legalMoves.add(Move(start: kingCell, end: path2, isCastling: true));
      }
    }

    // Queen-side castling
    if (board.castlingRights[color]![CastlingSide.queenSide]!) {
      final rookCell = Cell(row: kingRow, col: 0);
      final path1 = Cell(row: kingRow, col: 3);
      final path2 = Cell(row: kingRow, col: 2);
      final path3 = Cell(row: kingRow, col: 1); // Cell b1/b8 must also be empty

      final rook = board.getPieceAt(rookCell);

      if (rook?.type == PieceType.rook &&
          !rook!.hasMoved &&
          board.getPieceAt(path1) == null &&
          board.getPieceAt(path2) == null &&
          board.getPieceAt(path3) == null &&
          !aiEngine.isKingInCheck(
            _simulateMove(
              board,
              Move(start: kingCell, end: path1),
              PieceType.king,
              color,
            ),
            color,
          ) &&
          !aiEngine.isKingInCheck(
            _simulateMove(
              board,
              Move(start: kingCell, end: path2),
              PieceType.king,
              color,
            ),
            color,
          )) {
        legalMoves.add(Move(start: kingCell, end: path2, isCastling: true));
      }
    }
  }

  /// Validates if an en passant move is truly legal based on the last move.
  bool _isValidEnPassant(Board board, Move enPassantMove) {
    // Check if the move is actually an en passant move
    // and if the board has a move history to check against.
    if (!enPassantMove.isEnPassant || board.moveHistory.isEmpty) return false;

    final lastMove = board.moveHistory.last;
    final capturedPawnCell = Cell(
      row: enPassantMove.start.row,
      col: enPassantMove.end.col,
    ); // The cell where the captured pawn should be

    // Check if the last move was a two-step pawn move by the opponent
    // and if that pawn is now on the capturedPawnCell.
    final movedPiece = board.getPieceAt(
      capturedPawnCell,
    ); // The pawn that would be captured
    if (movedPiece == null || movedPiece.type != PieceType.pawn) {
      // if (movedPiece == null || movedPiece.type != PieceType.pawn || movedPiece.color == enPassantMove.start.color) {
      return false; // No pawn to capture, or it's your own pawn
    }

    // The pawn to capture must have just moved two squares from its starting rank
    final expectedStartRow =
        movedPiece.color == PieceColor.white
            ? 6
            : 1; // White pawn from row 6, Black from row 1
    final expectedEndRow =
        movedPiece.color == PieceColor.white
            ? 4
            : 3; // White pawn to row 4, Black to row 3

    return lastMove.isTwoStepPawnMove &&
        lastMove.start ==
            Cell(row: expectedStartRow, col: capturedPawnCell.col) &&
        lastMove.end == Cell(row: expectedEndRow, col: capturedPawnCell.col) &&
        enPassantMove.end ==
            board
                .enPassantTarget; // Ensure it targets the globally tracked en passant target
  }

  /// Updates castling rights based on the executed move.
  Map<PieceColor, Map<CastlingSide, bool>> _updateCastlingRights(
    Map<PieceColor, Map<CastlingSide, bool>> currentRights,
    Move move,
    PieceColor pieceColor,
  ) {
    final newRights = Map<PieceColor, Map<CastlingSide, bool>>.from(
      currentRights,
    )..update(pieceColor, (value) => Map.from(value));

    // If King moves, lose all castling rights for that color
    if (pieceColor == PieceColor.white) {
      if (move.start == const Cell(row: 7, col: 4)) {
        newRights[PieceColor.white]![CastlingSide.kingSide] = false;
        newRights[PieceColor.white]![CastlingSide.queenSide] = false;
      }
    } else {
      // Black King
      // If Black King moves, lose all castling rights for that color
      if (move.start == const Cell(row: 0, col: 4)) {
        newRights[PieceColor.black]![CastlingSide.kingSide] = false;
        newRights[PieceColor.black]![CastlingSide.queenSide] = false;
      }
    }

    // If Rook moves from its original square or is captured, lose that side's castling right for that color
    if (move.start == const Cell(row: 7, col: 7) ||
        move.end == const Cell(row: 7, col: 7)) {
      newRights[PieceColor.white]![CastlingSide.kingSide] = false;
    }
    if (move.start == const Cell(row: 7, col: 0) ||
        move.end == const Cell(row: 7, col: 0)) {
      newRights[PieceColor.white]![CastlingSide.queenSide] = false;
    }
    if (move.start == const Cell(row: 0, col: 7) ||
        move.end == const Cell(row: 0, col: 7)) {
      newRights[PieceColor.black]![CastlingSide.kingSide] = false;
    }
    if (move.start == const Cell(row: 0, col: 0) ||
        move.end == const Cell(row: 0, col: 0)) {
      newRights[PieceColor.black]![CastlingSide.queenSide] = false;
    }

    return newRights;
  }

  /// Checks the overall game status (check, checkmate, stalemate, draw).
  Future<GameResult> _checkGameStatus(Board board) async {
    final currentPlayerColor = board.currentPlayer;
    final opponentPlayerColor =
        currentPlayerColor == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    // Determine if current player has any legal moves
    bool hasLegalMoves = false;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final cell = Cell(row: r, col: c);
        final piece = board.getPieceAt(cell);
        if (piece != null && piece.color == currentPlayerColor) {
          final result = await getLegalMovesForPiece(board, cell);
          if (result.isRight() && result.getOrElse(() => []).isNotEmpty) {
            hasLegalMoves = true;
            break;
          }
        }
      }
      if (hasLegalMoves) break;
    }

    final isKingInCheck = aiEngine.isKingInCheck(board, currentPlayerColor);

    if (isKingInCheck) {
      if (!hasLegalMoves) {
        return GameResult.checkmate(
          opponentPlayerColor,
        ); // The player whose turn it is is checkmated
      }
    } else {
      if (!hasLegalMoves) {
        return GameResult.stalemate();
      }
    }

    // Check for other draw conditions
    if (aiEngine.isDrawByInsufficientMaterial(board)) {
      return GameResult.draw(DrawReason.insufficientMaterial);
    }
    if (board.halfMoveClock >= 100) {
      // 50 full moves = 100 half moves
      return GameResult.draw(DrawReason.fiftyMoveRule);
    }
    // For threefold repetition, you'd need to store FEN strings or board hashes in history
    // and check for repetition here.
    // if (aiEngine.isDrawByThreefoldRepetition(board.moveHistory)) {
    //   return GameResult.draw(DrawReason.threefoldRepetition);
    // }

    return GameResult.playing();
  }

  @override
  Future<Either<Failure, Move>> getBestAIMove(Board board, int depth) async {
    // try {
    final bestMove = await aiEngine.findBestMove(board, depth);
    if (bestMove != null) {
      return Right(bestMove);
    } else {
      return Left(GameFailure(message: 'AI could not find a move.'));
    }
    // } catch (e) {
    //   return Left(GameFailure(message: 'AI error: $e'));
    // }
  }

  @override
  Future<Either<Failure, Board>> loadGame() async {
    // try {
    final savedBoardJson = await localStorageService.loadGame();
    if (savedBoardJson == null) {
      return Left(CacheFailure(message: 'No saved game found.'));
    }
    // Implement deserialization from JSON to Board object
    final loadedBoard = _deserializeBoard(savedBoardJson);
    return Right(loadedBoard);
    // } catch (e) {
    //   return Left(CacheFailure(message: 'Failed to load game: $e'));
    // }
  }

  @override
  Future<Either<Failure, Unit>> saveGame(Board board) async {
    // try {
    // Implement serialization from Board object to JSON
    final boardJson = _serializeBoard(board);
    await localStorageService.saveGame(boardJson);
    return const Right(unit);
    // } catch (e) {
    //   return Left(CacheFailure(message: 'Failed to save game: $e'));
    // }
  }

  // Helper for serialization (Board to JSON)
  Map<String, dynamic> _serializeBoard(Board board) {
    return {
      'squares':
          board.squares
              .map((row) => row.map((piece) => piece?.toJson()).toList())
              .toList(),
      'currentPlayer': board.currentPlayer.name,
      'moveHistory':
          board.moveHistory
              .map((m) => m.toJson())
              .toList(), // Assuming Move has toJson
      'kingPositions': board.kingPositions.map(
        (k, v) => MapEntry(k.name, {'row': v.row, 'col': v.col}),
      ),
      'castlingRights': board.castlingRights.map(
        (k, v) => MapEntry(k.name, v.map((k2, v2) => MapEntry(k2.name, v2))),
      ),
      'enPassantTarget':
          board.enPassantTarget != null
              ? {
                'row': board.enPassantTarget!.row,
                'col': board.enPassantTarget!.col,
              }
              : null,
      'halfMoveClock': board.halfMoveClock,
      'fullMoveNumber': board.fullMoveNumber,
    };
  }

  // Helper for deserialization (JSON to Board)
  Board _deserializeBoard(Map<String, dynamic> json) {
    final List<List<Piece?>> squares =
        (json['squares'] as List<dynamic>)
            .map(
              (row) =>
                  (row as List<dynamic>)
                      .map<Piece?>(
                        (pJson) =>
                            pJson != null
                                ? Piece.fromJson(pJson as Map<String, dynamic>)
                                : null,
                      )
                      .toList(),
            )
            .toList();

    final currentPlayer =
        (json['currentPlayer'] as String) == 'white'
            ? PieceColor.white
            : PieceColor.black;
    final moveHistory =
        (json['moveHistory'] as List<dynamic>)
            .map((mJson) => Move.fromJson(mJson as Map<String, dynamic>))
            .toList(); // Assuming Move has fromJson

    final kingPositions = (json['kingPositions'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k == 'white' ? PieceColor.white : PieceColor.black,
        Cell(
          row: (v as Map<String, dynamic>)['row'] as int,
          col: v['col'] as int,
        ),
      ),
    );

    final castlingRights = (json['castlingRights'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k == 'white' ? PieceColor.white : PieceColor.black,
        (v as Map<String, dynamic>).map(
          (k2, v2) => MapEntry(
            k2 == 'kingSide' ? CastlingSide.kingSide : CastlingSide.queenSide,
            v2 as bool,
          ),
        ),
      ),
    );

    final enPassantTargetJson =
        json['enPassantTarget'] as Map<String, dynamic>?;
    final enPassantTarget =
        enPassantTargetJson != null
            ? Cell(
              row: enPassantTargetJson['row'] as int,
              col: enPassantTargetJson['col'] as int,
            )
            : null;

    final halfMoveClock = json['halfMoveClock'] as int;
    final fullMoveNumber = json['fullMoveNumber'] as int;

    return Board(
      squares: squares,
      currentPlayer: currentPlayer,
      moveHistory: moveHistory,
      kingPositions: kingPositions,
      castlingRights: castlingRights,
      enPassantTarget: enPassantTarget,
      halfMoveClock: halfMoveClock,
      fullMoveNumber: fullMoveNumber,
    );
  }
}

extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}// 672 lines 
