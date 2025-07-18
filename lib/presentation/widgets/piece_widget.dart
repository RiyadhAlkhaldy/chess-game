// lib/presentation/widgets/piece_widget.dart
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/cell.dart'; // Import Cell
import '../../domain/entities/piece.dart'; // Import Piece and PieceColor

/// Renders a single chess piece and enables dragging.
class PieceWidget extends StatelessWidget {
  final Piece piece; // The piece data (type, color)
  final Cell currentCell; // The current cell the piece is on
  final VoidCallback? onDragStarted; // Callback when dragging begins

  const PieceWidget({
    super.key,
    required this.piece,
    required this.currentCell,
    this.onDragStarted,
  });

  /// Returns the asset path for the piece image based on its type and color.
  /// Example: 'assets/images/w_P.png' for a white pawn.
  Widget get _pieceWidget {
    final isWhite = piece.color == PieceColor.white ? true : false;
    switch (piece.type) {
      case PieceType.pawn:
        return isWhite ? WhitePawn(size: 60) : BlackPawn(size: 60);
      case PieceType.rook:
        return isWhite ? WhiteRook(size: 60) : BlackRook(size: 60);

      case PieceType.knight:
        return isWhite ? WhiteKnight(size: 60) : BlackKnight(size: 60);

      case PieceType.bishop:
        return isWhite ? WhiteBishop(size: 60) : BlackBishop(size: 60);

      case PieceType.queen:
        return isWhite ? WhiteQueen(size: 60) : BlackQueen(size: 60);

      case PieceType.king:
        return isWhite ? WhiteKing(size: 60) : BlackKing(size: 60);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<PieceWidget>(
      // maxSimultaneousDrags: ,
      onDragCompleted: () {},
      onDragEnd: (details) {},
      onDragUpdate: (details) {},
      onDraggableCanceled: (velocity, offset) {},

      // data:
      //     this, // The data being dragged is this widget itself (contains currentCell)
      feedback: SizedBox(
        width: 46,
        height: 46,
        child: _pieceWidget,
      ), // Visual feedback when dragging
      childWhenDragging:
          Container(), // What remains at the original position when dragging
      onDragStarted:
          onDragStarted, // Callback when drag starts (used to highlight legal moves)
      child: _pieceWidget, // The actual piece image
    );
  }
}
