// ---------------------------------------------------------------------------
// 2) Board helpers (cloners + utilities)
// ---------------------------------------------------------------------------
import '../repositories/zobrist_hashing.dart';
import 'export.dart';

extension _BoardHelpers on Board {
  List<List<Piece?>> _cloneSquares() =>
      squares.map((r) => List<Piece?>.from(r)).toList();

  Map<PieceColor, Map<CastlingSide, bool>> _cloneCastling(
    Map<PieceColor, Map<CastlingSide, bool>> rights,
  ) => rights.map(
    (c, inner) => MapEntry(c, Map<CastlingSide, bool>.from(inner)),
  );

  Map<PieceColor, Cell> _cloneKings(Map<PieceColor, Cell> kp) =>
      kp.map((c, cell) => MapEntry(c, Cell(row: cell.row, col: cell.col)));

  PieceColor _opp(PieceColor c) =>
      c == PieceColor.white ? PieceColor.black : PieceColor.white;

  void _disableRightForRookSquare(
    Map<PieceColor, Map<CastlingSide, bool>> rights,
    PieceColor color,
    Cell cell,
  ) {
    if (color == PieceColor.white) {
      if (cell.row == 7 && cell.col == 0) {
        rights[color]![CastlingSide.queenSide] = false;
      }
      if (cell.row == 7 && cell.col == 7) {
        rights[color]![CastlingSide.kingSide] = false;
      }
    } else {
      if (cell.row == 0 && cell.col == 0) {
        rights[color]![CastlingSide.queenSide] = false;
      }
      if (cell.row == 0 && cell.col == 7) {
        rights[color]![CastlingSide.kingSide] = false;
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 3) The actual makeMove / unMakeMove (immutable, Alpha-Beta friendly)
// ---------------------------------------------------------------------------
extension MakeUnmake on Board {
  /// Apply a move and return the new board. Fully handles: capture, en passant,
  /// castling, promotion, clocks, castling rights, EP square, king positions.
  Board makeMove(Move move, {PieceType defaultPromotion = PieceType.queen}) {
    final moving = getPieceAt(move.start);
    if (moving == null) {
      throw StateError('makeMove: No piece at ${move.start}');
    }
    if (moving.color != currentPlayer) {
      throw StateError(
        'makeMove: It is $currentPlayer to move, piece is ${moving.color}',
      );
    }

    // Clone mutable state
    final nsq = _cloneSquares();
    final rights = _cloneCastling(castlingRights);
    final kings = _cloneKings(kingPositions);

    // Snapshot
    Move enriched = move.copyWith(
      previousCastlingRights: _cloneCastling(castlingRights),
      previousEnPassantTarget:
          enPassantTarget == null
              ? null
              : Cell(row: enPassantTarget!.row, col: enPassantTarget!.col),
      previousHalfMoveClock: halfMoveClock,
      previousFullMoveNumber: fullMoveNumber,
      previousKingPositions: _cloneKings(kingPositions),
      previousZobristKey: zobristKey,
      movedPieceBefore: moving,
    );

    // Determine capture (normal vs EP)
    Piece? captured;
    Cell? capturedAt;
    if (move.isEnPassant) {
      capturedAt = Cell(row: move.start.row, col: move.end.col);
      captured = nsq[capturedAt.row][capturedAt.col];
      if (captured == null || captured.type != PieceType.pawn) {
        throw StateError(
          'makeMove: invalid en passant, no pawn at $capturedAt',
        );
      }
      nsq[capturedAt.row][capturedAt.col] = null; // remove EP pawn
    } else {
      capturedAt = move.end;
      captured = nsq[move.end.row][move.end.col];
      if (captured != null) {
        nsq[move.end.row][move.end.col] = null; // remove captured
      }
    }

    // Clear source square
    nsq[move.start.row][move.start.col] = null;

    // Move rook in castling if needed
    Cell? rookFrom;
    Cell? rookTo;
    Piece? rookBefore;
    if (move.isCastling && moving.type == PieceType.king) {
      final kRow = moving.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // king side
        rookFrom = Cell(row: kRow, col: 7);
        rookTo = Cell(row: kRow, col: 5);
      } else if (move.end.col == 2) {
        // queen side
        rookFrom = Cell(row: kRow, col: 0);
        rookTo = Cell(row: kRow, col: 3);
      } else {
        throw StateError('makeMove: castling end must be file c or g');
      }
      rookBefore = nsq[rookFrom.row][rookFrom.col];
      if (rookBefore == null ||
          rookBefore.type != PieceType.rook ||
          rookBefore.color != moving.color) {
        throw StateError('makeMove: rook missing at $rookFrom');
      }
      nsq[rookFrom.row][rookFrom.col] = null;
      nsq[rookTo.row][rookTo.col] = Piece.create(
        color: rookBefore.color,
        type: PieceType.rook,
        hasMoved: true,
      );

      // King moved => both rights off
      rights[moving.color]![CastlingSide.kingSide] = false;
      rights[moving.color]![CastlingSide.queenSide] = false;
    }

    // Place moving piece (promotion if requested)
    final placed =
        move.isPromotion
            ? Piece.create(
              color: moving.color,
              type: move.promotedPieceType ?? defaultPromotion,
              hasMoved: true,
            )
            : Piece.create(
              color: moving.color,
              type: moving.type,
              hasMoved: true,
            );
    nsq[move.end.row][move.end.col] = placed;

    // Update king position and rights
    if (moving.type == PieceType.king) {
      kings[moving.color] = Cell(row: move.end.row, col: move.end.col);
      rights[moving.color]![CastlingSide.kingSide] = false;
      rights[moving.color]![CastlingSide.queenSide] = false;
    }
    if (moving.type == PieceType.rook) {
      _disableRightForRookSquare(rights, moving.color, move.start);
    }
    if (captured != null && captured.type == PieceType.rook) {
      _disableRightForRookSquare(rights, captured.color, capturedAt);
    }

    // En passant target for next move
    Cell? newEP;
    if (move.isTwoStepPawnMove && moving.type == PieceType.pawn) {
      final midRow = (move.start.row + move.end.row) ~/ 2;
      newEP = Cell(row: midRow, col: move.start.col);
    }

    // Clocks
    final resetHalf = moving.type == PieceType.pawn || captured != null;
    final newHMC = resetHalf ? 0 : (halfMoveClock + 1);
    final newFMN =
        currentPlayer == PieceColor.black
            ? (fullMoveNumber + 1)
            : fullMoveNumber;

    // Enrich move with capture/castling payload
    enriched = enriched.copyWith(
      capturedPiece: captured,
      capturedCell: capturedAt,
      rookFrom: rookFrom,
      rookTo: rookTo,
      rookBefore: rookBefore,
    );

    // Compute new Zobrist (use your incremental function if available)
    int nextKey;
    try {
      nextKey = ZobristHashing.updateZobristKeyAfterMove(this, enriched);
    } catch (_) {
      nextKey = ZobristHashing.calculateZobristKey(
        copyWith(
          squares: nsq,
          currentPlayer: _opp(currentPlayer),
          kingPositions: kings,
          castlingRights: rights,
          enPassantTarget: newEP,
          halfMoveClock: newHMC,
          fullMoveNumber: newFMN,
          // other fields unchanged for hashing purposes
        ),
      );
    }

    // Build next board
    final next = copyWith(
      squares: nsq,
      currentPlayer: _opp(currentPlayer),
      kingPositions: kings,
      castlingRights: rights,
      enPassantTarget: newEP,
      halfMoveClock: newHMC,
      fullMoveNumber: newFMN,
      moveHistory: List<Move>.from(moveHistory)..add(enriched),
      redoStack: <Move>[],
      zobristKey: nextKey,
    );

    // Append FEN into positionHistory (used for repetition checks)
    final fen = boardToFen(
      next.squares,
      next.currentPlayer,
      next.kingPositions,
      next.castlingRights,
      next.enPassantTarget,
      next.halfMoveClock,
      next.fullMoveNumber,
    );

    return next.copyWith(
      positionHistory: List<String>.from(positionHistory)..add(fen),
    );
  }

  /// Revert the last move and return the previous board.
  Board unMakeMove({Move? move}) {
    if (moveHistory.isEmpty) {
      throw StateError('unMakeMove: moveHistory empty');
    }
    final last = move ?? moveHistory.last;
    if (!identical(last, moveHistory.last)) {
      throw StateError('unMakeMove: only the top-most move can be unmade');
    }

    // Clone squares
    final nsq = _cloneSquares();

    // Remove piece from destination
    final pieceOnEnd = nsq[last.end.row][last.end.col];
    if (pieceOnEnd == null && !(last.isEnPassant && last.isCapture)) {
      throw StateError('unMakeMove: no piece at destination to pull back');
    }
    nsq[last.end.row][last.end.col] = null;

    // Restore captured piece
    if (last.isCapture) {
      if (last.isEnPassant) {
        final cCell = last.capturedCell!;
        nsq[cCell.row][cCell.col] = last.capturedPiece;
      } else {
        nsq[last.end.row][last.end.col] = last.capturedPiece;
      }
    }

    // Undo castling rook move
    if (last.isCastling && last.rookFrom != null && last.rookTo != null) {
      nsq[last.rookTo!.row][last.rookTo!.col] = null;
      nsq[last.rookFrom!.row][last.rookFrom!.col] = last.rookBefore;
    }

    // Restore moving piece on start
    final restore = last.movedPieceBefore;
    if (restore == null) {
      throw StateError('unMakeMove: movedPieceBefore missing');
    }
    nsq[last.start.row][last.start.col] = restore;

    // Restore prior state
    final prevRights = last.previousCastlingRights ?? castlingRights;
    final prevKings = last.previousKingPositions ?? kingPositions;
    final prevEP = last.previousEnPassantTarget;
    final prevHMC = last.previousHalfMoveClock ?? 0;
    final prevFMN = last.previousFullMoveNumber ?? 1;
    final prevKey = last.previousZobristKey;

    // Pop history & push redo
    final hist = List<Move>.from(moveHistory)..removeLast();
    final redo = List<Move>.from(redoStack)..add(last);

    // Trim positionHistory (drop the last FEN)
    final posHist = List<String>.from(positionHistory);
    if (posHist.isNotEmpty) posHist.removeLast();

    return copyWith(
      squares: nsq,
      currentPlayer: restore.color, // side to move becomes the mover again
      kingPositions: _cloneKings(prevKings),
      castlingRights: _cloneCastling(prevRights),
      enPassantTarget:
          prevEP == null ? null : Cell(row: prevEP.row, col: prevEP.col),
      halfMoveClock: prevHMC,
      fullMoveNumber: prevFMN,
      moveHistory: hist,
      redoStack: redo,
      positionHistory: posHist,
      zobristKey:
          prevKey ??
          ZobristHashing.calculateZobristKey(
            copyWith(
              squares: nsq,
              currentPlayer: restore.color,
              kingPositions: _cloneKings(prevKings),
              castlingRights: _cloneCastling(prevRights),
              enPassantTarget:
                  prevEP == null
                      ? null
                      : Cell(row: prevEP.row, col: prevEP.col),
              halfMoveClock: prevHMC,
              fullMoveNumber: prevFMN,
            ),
          ),
    );
  }

  //for test
  Board makeMymove(Move move) {
    final piece = getPieceAt(move.start);
    if (piece == null) {
      throw StateError('makeMymove: No piece at ${move.start}');
    }
    if (piece.color != currentPlayer) {
      throw StateError('makeMymove: Not your turn');
    }
    placePiece(move.end, piece).placePiece(move.start, null);

  

    return this;
  }

  //for test
  Board unMakeMymove(Move move) {
    return this;
  }
}
