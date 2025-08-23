// lib/presentation/widgets/game_board_widget.dart
// تحسينات: Responsiveness + تقليل إعادة البناء + DragTarget فعّال + مفاتيح ثابتة

import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/piece.dart';
import '../controllers/game_controller.dart';
import 'cell_widget.dart';
import 'piece_widget.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // الحفاظ على نسبة 1:1 دائماً
        final boardSize = constraints.biggest.width;
        return Center(
          child: RepaintBoundary(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: Obx(() {
                final controller = Get.find<GameController>();
                final humanIsWhite =
                    controller.humanPlayerColor == PieceColor.white;
                final board = controller.board.value;
                final selected = controller.selectedCell.value;
                final legalMoves = controller.legalMoves;

                return Transform.rotate(
                  angle: humanIsWhite ? 0 : 3.1415926535,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final cell = Cell(row: row, col: col);
                      final piece = board.getPieceAt(cell);

                      final isSelected = selected == cell;
                      final isLegalTarget = legalMoves.any(
                        (m) => m.end == cell,
                      );

                      bool kingCheck = false;
                      if (piece is King && controller.isCurrentKingInCheck()) {
                        if (piece.color == board.currentPlayer) {
                          kingCheck = true;
                        }
                      }

                      // دعم السحب/الإفلات: نقبل Payload من القطع
                      return DragTarget<DragPayload>(
                        onWillAcceptWithDetails: (data) {
                          return legalMoves.any(
                            (m) => m.start == data.data.from && m.end == cell,
                          );
                        },
                        onAcceptWithDetails: (data) {
                          // نحاكي: select(start) ثم select(end)
                          controller.selectedCell(data.data.from);
                          controller.selectedCell(cell);
                        },
                        builder: (context, candidate, rejected) {
                          return CellWidget(
                            key: ValueKey('cell-$row-$col'),
                            cell: cell,
                            isWhite: (row + col) % 2 == 0,
                            isSelected: isSelected,
                            isLegalMoveTarget:
                                isLegalTarget || candidate.isNotEmpty,
                            kingCellisOnCheck: kingCheck,
                            onTap: () => controller.onCellTap(cell),
                            child:
                                piece == null
                                    ? null
                                    : Transform.rotate(
                                      angle: humanIsWhite ? 0 : 3.1415926535,
                                      child: PieceWidget(
                                        key: ValueKey(
                                          'piece-${piece.type.name}-${piece.color.name}-$row-$col',
                                        ),
                                        piece: piece,
                                        currentCell: cell,
                                        isSelected: isSelected,
                                        onDragStarted: () {
                                          // نكتفي بالتحديد البصري عند بدء السحب
                                          controller.selectedCell(cell);
                                        },
                                      ),
                                    ),
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
