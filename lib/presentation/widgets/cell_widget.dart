// lib/presentation/widgets/cell_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../domain/entities/cell.dart';

/// Renders a single cell of the chessboard with appropriate styling.
class CellWidget extends StatelessWidget {
  final Cell cell; // The cell's coordinates
  final bool isWhite; // True if it's a "white" square on the board
  final bool isSelected; // True if this cell is currently selected
  final bool
  isLegalMoveTarget; // True if this cell is a legal move target for the selected piece
  final Widget? child; // The piece widget (if any) on this cell
  final bool kingCellisOnCheck;
  const CellWidget({
    super.key,
    required this.cell,
    required this.isWhite,
    this.isSelected = false,
    this.isLegalMoveTarget = false,
    this.child,
    this.kingCellisOnCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.yellow.shade300;
      //  theme.colorScheme.primary.withOpacity(
      //   0.7,
      // ); // Highlight for selected cell
    } else if (isLegalMoveTarget) {
      backgroundColor = Colors.yellow.shade300;
      // theme.colorScheme.secondary.withOpacity(
      //   0.5,
      // ); // Highlight for legal move targets
    } else if (kingCellisOnCheck) {
      backgroundColor = Colors.red.shade300; // لون أحمر لمربع الملك المهدد
    } else {
      backgroundColor =
          isWhite
              ? Colors
                  .brown
                  .shade200 // White squares background
              : Colors.brown.shade600; // Black squares background
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent, // Border for selected cell
          width: isSelected ? 3.0 : 0.0,
        ),
        // border: Border.all(color: Colors.black12),
      ),
      child: Stack(
        alignment: Alignment.center, // Center the child and dot
        children: [
          if (child != null) child!, // Display the piece if present
          if (isLegalMoveTarget &&
              child == null) // Show a dot for empty legal move targets
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary, // Dot color
                shape: BoxShape.circle, // Circular dot
              ),
            ),
        ],
      ),
    );
  }
}
