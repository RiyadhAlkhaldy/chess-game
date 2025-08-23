// // === Additions & Implementations for Board.makeMove / Board.unMakeMove ===
// // This snippet assumes it lives in the same compilation unit where Board, Move, Piece, Cell, etc. are defined.
// // If your project splits them into separate files, adjust imports accordingly.

// // ---------------------------------------------------------------------------
// // 1) Extend `Move` to carry reversible metadata (for fast unMake in alpha–beta)
// // ---------------------------------------------------------------------------

// // lib/domain/entities/move.dart (augment your existing Move with the fields below)
// @freezed
// class Move with _$Move {
//   const factory Move({
//     required Cell start,
//     required Cell end,

//     // Flags
//     @Default(false) bool isCapture,
//     @Default(false) bool isCastling,
//     @Default(false) bool isEnPassant,
//     @Default(false) bool isPromotion,
//     PieceType? promotedPieceType,
//     @Default(false) bool isTwoStepPawnMove,

//     // === Reversibility payload (ignored by JSON) ===
//     @JsonKey(ignore: true)
//     Piece? capturedPiece, // the piece that got captured (if any)
//     @JsonKey(ignore: true)
//     Cell?
//     capturedCell, // where the capture actually occurred (end for normal, special square for EP)
//     @JsonKey(ignore: true)
//     Piece?
//     movedPieceBefore, // original moving piece (to restore hasMoved / type on unmake)
//     // Castling rook data
//     @JsonKey(ignore: true) Cell? rookFrom,
//     @JsonKey(ignore: true) Cell? rookTo,
//     @JsonKey(ignore: true)
//     Piece? rookBefore, // rook piece before moving (to restore hasMoved flag)
//     // Prior board state (to restore)
//     @JsonKey(ignore: true)
//     Map<PieceColor, Map<CastlingSide, bool>>? previousCastlingRights,
//     @JsonKey(ignore: true) Cell? previousEnPassantTarget,
//     @JsonKey(ignore: true) int? previousHalfMoveClock,
//     @JsonKey(ignore: true) int? previousFullMoveNumber,
//     @JsonKey(ignore: true) Map<PieceColor, Cell>? previousKingPositions,
//     @JsonKey(ignore: true) int? previousZobristKey,
//   }) = _Move;

//   factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
// }

// // ---------------------------------------------------------------------------
// // 2) Board helpers (deep copies and utility)
// // ---------------------------------------------------------------------------
// extension _BoardHelpers on Board {
//   Map<PieceColor, Map<CastlingSide, bool>> _cloneCastlingRights(
//     Map<PieceColor, Map<CastlingSide, bool>> rights,
//   ) {
//     return rights.map(
//       (pc, inner) => MapEntry(pc, Map<CastlingSide, bool>.from(inner)),
//     );
//   }

//   Map<PieceColor, Cell> _cloneKingPositions(Map<PieceColor, Cell> kp) {
//     return kp.map(
//       (pc, cell) => MapEntry(pc, Cell(row: cell.row, col: cell.col)),
//     );
//   }

//   List<List<Piece?>> _cloneSquares() {
//     return squares.map((row) => List<Piece?>.from(row)).toList();
//   }

//   PieceColor _opponent(PieceColor c) =>
//       c == PieceColor.white ? PieceColor.black : PieceColor.white;

//   bool _isRookStartSquare(PieceColor color, Cell cell) {
//     if (color == PieceColor.white) {
//       return (cell.row == 7 && (cell.col == 0 || cell.col == 7));
//     } else {
//       return (cell.row == 0 && (cell.col == 0 || cell.col == 7));
//     }
//   }

//   void _disableRightForRookStart(
//     Map<PieceColor, Map<CastlingSide, bool>> rights,
//     PieceColor color,
//     Cell rookCell,
//   ) {
//     if (color == PieceColor.white) {
//       if (rookCell.row == 7 && rookCell.col == 0)
//         rights[color]![CastlingSide.queenSide] = false;
//       if (rookCell.row == 7 && rookCell.col == 7)
//         rights[color]![CastlingSide.kingSide] = false;
//     } else {
//       if (rookCell.row == 0 && rookCell.col == 0)
//         rights[color]![CastlingSide.queenSide] = false;
//       if (rookCell.row == 0 && rookCell.col == 7)
//         rights[color]![CastlingSide.kingSide] = false;
//     }
//   }
// }

// // ---------------------------------------------------------------------------
// // 3) The actual makeMove / unMakeMove
// // ---------------------------------------------------------------------------
// extension MakeUnmake on Board {
//   /// Applies `move` and returns the resulting board.
//   /// - Handles: normal moves, captures, en passant, castling, promotion, clocks, rights, EP square, king positions.
//   /// - Stores all info required to **unMakeMove** inside the **same Move** (pushed to moveHistory).
//   Board makeMove(Move move, {PieceType defaultPromotion = PieceType.queen}) {
//     // Defensive checks (can be turned into asserts in release)
//     final movingPiece = getPieceAt(move.start);
//     if (movingPiece == null) {
//       throw StateError('makeMove: No piece at ${move.start}');
//     }
//     if (movingPiece.color != currentPlayer) {
//       throw StateError(
//         'makeMove: It is $currentPlayer to move, but piece is ${movingPiece.color}',
//       );
//     }

//     // Clone mutable parts
//     final newSquares = _cloneSquares();
//     final newCastlingRights = _cloneCastlingRights(castlingRights);
//     final newKingPositions = _cloneKingPositions(kingPositions);
//     final nextPlayer = _opponent(currentPlayer);

//     // Snapshot prior-state for unmake
//     Move enriched = move.copyWith(
//       previousCastlingRights: newCastlingRights.map(
//         (pc, inner) => MapEntry(pc, Map<CastlingSide, bool>.from(inner)),
//       ),
//       previousEnPassantTarget:
//           enPassantTarget == null
//               ? null
//               : Cell(row: enPassantTarget!.row, col: enPassantTarget!.col),
//       previousHalfMoveClock: halfMoveClock,
//       previousFullMoveNumber: fullMoveNumber,
//       previousKingPositions: _cloneKingPositions(kingPositions),
//       previousZobristKey: zobristKey,
//       movedPieceBefore: movingPiece,
//     );

//     // Determine capture (normal vs en passant)
//     Piece? capturedPiece;
//     Cell? capturedCell;
//     if (move.isEnPassant) {
//       capturedCell = Cell(row: move.start.row, col: move.end.col);
//       capturedPiece = newSquares[capturedCell.row][capturedCell.col];
//       if (capturedPiece == null || capturedPiece.type != PieceType.pawn) {
//         // EP must capture a pawn sitting adjacent to start
//         throw StateError(
//           'makeMove: Invalid en passant. No pawn at $capturedCell',
//         );
//       }
//     } else {
//       capturedCell = move.end;
//       capturedPiece = newSquares[move.end.row][move.end.col];
//     }

//     // Remove captured piece if any
//     if (capturedPiece != null) {
//       newSquares[capturedCell.row][capturedCell.col] = null;
//     }

//     // Move the moving piece (and handle promotion / hasMoved)
//     Piece resultingPiece;
//     if (move.isPromotion) {
//       final promoteTo = move.promotedPieceType ?? defaultPromotion;
//       resultingPiece = Piece.create(
//         color: movingPiece.color,
//         type: promoteTo,
//         hasMoved: true,
//       );
//     } else {
//       // Ensure we keep the concrete subclass type
//       resultingPiece = Piece.create(
//         color: movingPiece.color,
//         type: movingPiece.type,
//         hasMoved: true,
//       );
//     }

//     // Clear source square
//     newSquares[move.start.row][move.start.col] = null;

//     // Castling rook movement (if any)
//     Cell? rookFrom;
//     Cell? rookTo;
//     Piece? rookBefore;
//     if (move.isCastling && movingPiece.type == PieceType.king) {
//       final kingRow = movingPiece.color == PieceColor.white ? 7 : 0;
//       if (move.end.col == 6) {
//         // king-side: rook h -> f
//         rookFrom = Cell(row: kingRow, col: 7);
//         rookTo = Cell(row: kingRow, col: 5);
//       } else if (move.end.col == 2) {
//         // queen-side: rook a -> d
//         rookFrom = Cell(row: kingRow, col: 0);
//         rookTo = Cell(row: kingRow, col: 3);
//       } else {
//         throw StateError('makeMove: invalid castling end square ${move.end}');
//       }

//       rookBefore = newSquares[rookFrom.row][rookFrom.col];
//       if (rookBefore == null ||
//           rookBefore.type != PieceType.rook ||
//           rookBefore.color != movingPiece.color) {
//         throw StateError('makeMove: rook not found at $rookFrom for castling');
//       }
//       // Move rook and set hasMoved=true
//       newSquares[rookFrom.row][rookFrom.col] = null;
//       newSquares[rookTo.row][rookTo.col] = Piece.create(
//         color: rookBefore.color,
//         type: PieceType.rook,
//         hasMoved: true,
//       );
//       // King has moved -> both rights gone
//       newCastlingRights[movingPiece.color]![CastlingSide.kingSide] = false;
//       newCastlingRights[movingPiece.color]![CastlingSide.queenSide] = false;
//     }

//     // Place the moving piece on destination
//     newSquares[move.end.row][move.end.col] = resultingPiece;

//     // Update king position if king moved
//     if (movingPiece.type == PieceType.king) {
//       newKingPositions[movingPiece.color] = Cell(
//         row: move.end.row,
//         col: move.end.col,
//       );
//       // Also ensure castling rights off even if not flagged as castling
//       newCastlingRights[movingPiece.color]![CastlingSide.kingSide] = false;
//       newCastlingRights[movingPiece.color]![CastlingSide.queenSide] = false;
//     }

//     // If a rook moved from its original square, turn off that side castling right
//     if (movingPiece.type == PieceType.rook) {
//       _disableRightForRookStart(
//         newCastlingRights,
//         movingPiece.color,
//         move.start,
//       );
//     }

//     // If we captured opponent rook on its original square, disable opponent right
//     if (capturedPiece != null &&
//         capturedPiece.type == PieceType.rook &&
//         capturedPiece.color != movingPiece.color) {
//       _disableRightForRookStart(
//         newCastlingRights,
//         capturedPiece.color,
//         capturedCell!,
//       );
//     }

//     // En-passant target square
//     Cell? newEnPassant;
//     if (move.isTwoStepPawnMove && movingPiece.type == PieceType.pawn) {
//       final midRow =
//           (move.start.row + move.end.row) ~/ 2; // the square jumped over
//       newEnPassant = Cell(row: midRow, col: move.start.col);
//     }

//     // Half-move clock
//     final didResetHalfMove =
//         (movingPiece.type == PieceType.pawn) || (capturedPiece != null);
//     final newHalfMoveClock = didResetHalfMove ? 0 : (halfMoveClock + 1);

//     // Full move number increments *after* Black moves
//     final newFullMoveNumber =
//         currentPlayer == PieceColor.black
//             ? (fullMoveNumber + 1)
//             : fullMoveNumber;

//     // Prepare enriched move for history (for unmake)
//     enriched = enriched.copyWith(
//       capturedPiece: capturedPiece,
//       capturedCell: capturedCell,
//       rookFrom: rookFrom,
//       rookTo: rookTo,
//       rookBefore: rookBefore,
//     );

//     // Build the new board instance
//     final newBoard = copyWith(
//       squares: newSquares,
//       currentPlayer: nextPlayer,
//       kingPositions: newKingPositions,
//       castlingRights: newCastlingRights,
//       enPassantTarget: newEnPassant,
//       halfMoveClock: newHalfMoveClock,
//       fullMoveNumber: newFullMoveNumber,
//       moveHistory: List<Move>.from(moveHistory)..add(enriched),
//       redoStack: <Move>[], // clear redo on new move
//     );

//     // Update Zobrist (if your hashing utility is available); otherwise keep existing
//     try {
//       if (ZobristHashing.zobristKeysInitialized) {
//         final newKey = ZobristHashing.calculateZobristKey(newBoard);
//         return newBoard.copyWith(
//           positionHistory: List<String>.from(newBoard.positionHistory)..add(
//             _boardToFen(
//               newSquares,
//               nextPlayer,
//               newKingPositions,
//               newCastlingRights,
//               newEnPassant,
//               newHalfMoveClock,
//               newFullMoveNumber,
//             ),
//           ),
//           zobristKey: newKey,
//         );
//       }
//     } catch (_) {
//       // Fallback: still append FEN without touching zobristKey
//     }

//     return newBoard.copyWith(
//       positionHistory: List<String>.from(newBoard.positionHistory)..add(
//         _boardToFen(
//           newSquares,
//           nextPlayer,
//           newKingPositions,
//           newCastlingRights,
//           newEnPassant,
//           newHalfMoveClock,
//           newFullMoveNumber,
//         ),
//       ),
//     );
//   }

//   /// Reverts the last move (or a provided move that is the last in history) and returns the previous board.
//   Board unMakeMove({Move? move}) {
//     if (moveHistory.isEmpty) {
//       throw StateError('unMakeMove: moveHistory is empty');
//     }
//     final last = move ?? moveHistory.last;
//     if (!identical(last, moveHistory.last)) {
//       // For safety: we only support unmaking the very last move in history.
//       throw StateError(
//         'unMakeMove: can only unmake the last move in moveHistory',
//       );
//     }

//     // Clone current squares and restore
//     final newSquares = _cloneSquares();

//     // Remove the piece from destination
//     final pieceOnEnd = newSquares[last.end.row][last.end.col];
//     if (pieceOnEnd == null && !(last.isEnPassant && last.isCapture)) {
//       throw StateError('unMakeMove: no piece to remove on ${last.end}');
//     }
//     newSquares[last.end.row][last.end.col] = null;

//     // Restore captured piece (normal capture or EP)
//     if (last.isCapture) {
//       if (last.isEnPassant) {
//         final cCell = last.capturedCell!; // must exist
//         newSquares[cCell.row][cCell.col] = last.capturedPiece;
//       } else {
//         newSquares[last.end.row][last.end.col] = last.capturedPiece;
//       }
//     }

//     // Undo castling rook move if needed
//     if (last.isCastling && last.rookFrom != null && last.rookTo != null) {
//       // Remove rook from rookTo and put back rookBefore at rookFrom
//       newSquares[last.rookTo!.row][last.rookTo!.col] = null;
//       newSquares[last.rookFrom!.row][last.rookFrom!.col] = last.rookBefore;
//     }

//     // Restore the moving piece on start (handle promotion by restoring the original pawn, etc.)
//     final restorePiece = last.movedPieceBefore;
//     if (restorePiece == null) {
//       throw StateError('unMakeMove: movedPieceBefore is missing');
//     }
//     newSquares[last.start.row][last.start.col] = restorePiece;

//     // Restore clocks, rights, EP, king positions, player-to-move
//     final prevRights = last.previousCastlingRights ?? castlingRights;
//     final prevKp = last.previousKingPositions ?? kingPositions;
//     final prevEp = last.previousEnPassantTarget;
//     final prevHmc = last.previousHalfMoveClock ?? 0;
//     final prevFmn = last.previousFullMoveNumber ?? 1;
//     final prevPlayer =
//         restorePiece
//             .color; // the player who moved becomes the side to move again

//     // Pop moveHistory and push to redoStack
//     final newHistory = List<Move>.from(moveHistory)..removeLast();
//     final newRedo = List<Move>.from(redoStack)..add(last);

//     final restoredBoard = copyWith(
//       squares: newSquares,
//       currentPlayer: prevPlayer,
//       castlingRights: prevRights.map(
//         (pc, inner) => MapEntry(pc, Map<CastlingSide, bool>.from(inner)),
//       ),
//       kingPositions: _cloneKingPositions(prevKp),
//       enPassantTarget:
//           prevEp == null ? null : Cell(row: prevEp.row, col: prevEp.col),
//       halfMoveClock: prevHmc,
//       fullMoveNumber: prevFmn,
//       moveHistory: newHistory,
//       redoStack: newRedo,
//     );

//     // Restore Zobrist / Position history if we have the previous key
//     try {
//       final prevKey = last.previousZobristKey;
//       final newPositionHistory = List<String>.from(
//         restoredBoard.positionHistory,
//       );
//       if (newPositionHistory.isNotEmpty) newPositionHistory.removeLast();

//       if (prevKey != null) {
//         return restoredBoard.copyWith(
//           zobristKey: prevKey,
//           positionHistory: newPositionHistory,
//         );
//       } else {
//         return restoredBoard.copyWith(positionHistory: newPositionHistory);
//       }
//     } catch (_) {
//       return restoredBoard; // minimal fallback
//     }
//   }
// }
