// lib/presentation/pages/game_page.dart

import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/piece.dart';
import '../controllers/game_controller.dart';

/// صفحة عرض لعبة الشطرنج.
/// تستخدم [GameController] لإدارة حالة اللعبة والتفاعل معها.
class GamePage extends StatelessWidget {
  GamePage({super.key});

  final GameController controller = Get.find<GameController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لعبة الشطرنج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.resetGame(),
            tooltip: 'إعادة تعيين اللعبة',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض حالة اللعبة
            GetX<GameController>(
              builder: (controller) {
                String statusText = '';
                Color statusColor = Colors.black;

                switch (controller.gameResult.value.outcome) {
                  case GameOutcome.playing:
                    statusText =
                        'الدور للّاعب: ${controller.board.value.currentPlayer == PieceColor.white ? 'الأبيض' : 'الأسود'}';
                    if (controller.isCurrentKingInCheck()) {
                      statusText += ' (كش!)';
                      statusColor = Colors.red;
                    }
                    break;
                  case GameOutcome.checkmate:
                    statusText =
                        'كش ملك! الفائز: ${controller.gameResult.value.winner == PieceColor.white ? 'الأبيض' : 'الأسود'}';
                    statusColor = Colors.green;
                    break;
                  case GameOutcome.stalemate:
                    statusText = 'طريق مسدود! (تعادل)';
                    statusColor = Colors.orange;
                    break;
                  case GameOutcome.draw:
                    statusText =
                        'تعادل! السبب: ${controller.gameResult.value.drawReason == DrawReason.fiftyMoveRule ? 'قاعدة الخمسين حركة' : 'مواد غير كافية'}';
                    statusColor = Colors.blue;
                    break;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        final row = index ~/ 8;
                        final col = index % 8;
                        final cell = Cell(row: row, col: col);
                        final piece = controller.board.value.getPieceAt(cell);

                        final bool isSelected =
                            controller.selectedCell.value == cell;
                        final bool isLegalMoveTarget = controller.legalMoves
                            .any((move) => move.end == cell);

                        Color cellColor =
                            (row + col) % 2 == 0
                                ? Colors.brown.shade200
                                : Colors.brown.shade700;

                        if (isSelected) {
                          cellColor =
                              Colors.yellow.shade300; // لون الخلية المختارة
                        } else if (isLegalMoveTarget) {
                          cellColor =
                              Colors
                                  .green
                                  .shade300; // لون الخلايا المستهدفة للحركات القانونية
                        }

                        // لون مربع الملك إذا كان في كش
                        if (piece is King &&
                            controller.isCurrentKingInCheck()) {
                          if (piece.color ==
                              controller.board.value.currentPlayer) {
                            cellColor =
                                Colors
                                    .red
                                    .shade300; // لون أحمر لمربع الملك المهدد
                          }
                        }

                        return GestureDetector(
                          onTap: () => controller.onCellTap(cell),
                          child: Container(
                            color: cellColor,
                            child: Center(
                              child: Text(
                                _getPieceSymbol(
                                  piece,
                                ), // دالة مساعدة للحصول على رمز القطعة
                                style: TextStyle(
                                  fontSize: 32,
                                  color:
                                      piece?.color == PieceColor.white
                                          ? Colors.white
                                          : Colors.black,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// دالة مساعدة لتحويل قطعة الشطرنج إلى رمز يونيكود.
  String _getPieceSymbol(Piece? piece) {
    if (piece == null) return '';
    switch (piece.type) {
      case PieceType.king:
        return piece.color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:
        return piece.color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:
        return piece.color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop:
        return piece.color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight:
        return piece.color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:
        return piece.color == PieceColor.white ? '♙' : '♟';
    }
  }
}
