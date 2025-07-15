// lib/presentation/widgets/game_board_widget.dart
import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/piece.dart';
import '../controllers/game_controller.dart';
import 'cell_widget.dart';
import 'piece_widget.dart';

/// Renders the 8x8 chess board and handles piece placement and drag/drop interactions.
class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});
  // final GameController controller = Get.find<GameController>();
  @override
  Widget build(BuildContext context) {
    return GetX<GameController>(
      builder: (controller) {
        final humanPlayerColor =
            controller.humanPlayerColor == PieceColor.white ? true : false;
        final currentBoard =
            controller
                .board
                .value; // Get the current board state from the controller
        final selectedCell =
            controller.selectedCell.value; // Get the currently selected cell
        final legalMoves =
            controller.legalMoves; // Get the legal moves for the selected piece

        return Transform.rotate(
          angle:
              humanPlayerColor
                  ? 0
                  : 3.14159, // Rotate the board for black player
          child: GridView.builder(
            shrinkWrap: true, // Takes only the space it needs
            physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // 8 columns for the chessboard
            ),
            itemCount: 64, // 8 rows * 8 columns = 64 cells
            itemBuilder: (context, index) {
              // Calculate row and column from the index
              final row = index ~/ 8;
              final col = index % 8;

              final cell = Cell(
                row: row,
                col: col,
              ); // Create a Cell object for the current grid item
              final piece = currentBoard.getPieceAt(
                cell,
              ); // Get the piece at this cell

              // Determine if the cell is selected or a legal target for the selected piece
              final isSelected = selectedCell == cell;
              final isLegalMoveTarget = legalMoves.any(
                (move) => move.end == cell,
              );

              return DragTarget<PieceWidget>(
                // Defines what kind of data this DragTarget can accept. Here, it's a PieceWidget.
                // onWillAcceptWithDetails: (details) {
                //   // return true;
                //   // This is called when a draggable object is dragged over this DragTarget.
                //   // We check if the potential move (from dragged piece's origin to this cell) is legal.
                //   final draggedStartCell = details.data.currentCell;
                //   // ignore: unnecessary_null_comparison
                //   if (draggedStartCell == null) return false;

                //   // Create a dummy move to check against the controller's legal moves.
                //   final potentialMove = Move(start: draggedStartCell, end: cell);
                //   return controller.legalMoves.contains(potentialMove);
                // },
                // onAcceptWithDetails: (details) {
                //   // This is called when a draggable object is dropped onto this DragTarget.
                //   // We simulate tapping the start cell and then the end cell to trigger the controller's move logic.
                //   final Cell draggedStartCell = details.data.currentCell;
                //   // // ignore: unnecessary_null_comparison
                //   controller.selectCell(
                //     draggedStartCell,
                //   ); // Simulate selecting the piece
                //   controller.selectCell(cell); // Simulate moving to the target cell
                // },
                builder: (context, candidateData, rejectedData) {
                  // The builder function defines the UI of the DragTarget.
                  return GestureDetector(
                    onTap: () {
                      controller.onCellTap(cell);
                    }, // Handle tap events for piece selection/movement
                    child: CellWidget(
                      cell: cell,
                      isWhite: (row + col) % 2 == 0, // Determine cell color
                      isSelected: isSelected,
                      isLegalMoveTarget: isLegalMoveTarget,
                      child:
                          piece != null
                              ? Transform.rotate(
                                angle: humanPlayerColor ? 0 : 3.14159,
                                child: PieceWidget(
                                  piece: piece,
                                  currentCell: cell,
                                  onDragStarted: () {
                                    // When dragging starts, select the piece in the controller
                                    // so its legal moves can be highlighted.
                                    // controller.selectCell(cell);
                                  },
                                ),
                              )
                              : null, // No piece if cell is empty
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
