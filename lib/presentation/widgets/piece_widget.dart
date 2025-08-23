// lib/presentation/widgets/piece_widget.dart
// تحسينات: Semantics + RepaintBoundary + خيار السحب بالضغط المطوّل + Hero اختياري

import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/piece.dart';

/// نموذج بيانات بسيط يتم تمريره أثناء السحب/الإفلات
class DragPayload {
  final Cell from;
  final Piece piece;
  const DragPayload({required this.from, required this.piece});
}

class PieceWidget extends StatelessWidget {
  final Piece piece; // نوع القطعة ولونها
  final Cell currentCell; // موضعها الحالي
  final bool isSelected; // لعمل تأثير بصري بسيط
  final bool useLongPressToDrag; // يفضَّل على الهاتف لمنع سحب غير مقصود
  final VoidCallback? onDragStarted; // لاستدعاء تلوين الحركات القانونية

  const PieceWidget({
    super.key,
    required this.piece,
    required this.currentCell,
    this.isSelected = false,
    this.useLongPressToDrag = true,
    this.onDragStarted,
  });

  Widget get _vectorForPiece {
    final isWhite = piece.color == PieceColor.white;
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

  Widget _buildDraggable({required Widget child}) {
    final payload = DragPayload(from: currentCell, piece: piece);

    final draggable =
        useLongPressToDrag
            ? LongPressDraggable<DragPayload>(
              data: payload,
              feedback: SizedBox(width: 46, height: 46, child: _vectorForPiece),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: onDragStarted,
              child: child,
            )
            : Draggable<DragPayload>(
              data: payload,
              feedback: SizedBox(width: 46, height: 46, child: _vectorForPiece),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: onDragStarted,
              child: child,
            );
    return draggable;
  }

  @override
  Widget build(BuildContext context) {
    final widgetWithEffects = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: isSelected ? 1.06 : 1.0,
      child: _vectorForPiece,
    );

    return Semantics(
      label:
          'قطعة ${piece.type.name} عند ${currentCell.row},${currentCell.col}',
      image: true,
      child: RepaintBoundary(
        child: Hero(
          // مميز لانتقال بسيط عند الالتقاط (اختياري)
          tag:
              'piece-${piece.type.name}-${piece.color.name}-${currentCell.row}-${currentCell.col}',
          // flightShuttleBuilder: (_, __, ___, ____, toHero) => toHero,
          child: _buildDraggable(child: widgetWithEffects),
        ),
      ),
    );
  }
}
