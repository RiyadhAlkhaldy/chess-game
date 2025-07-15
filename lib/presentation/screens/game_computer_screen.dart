// ignore_for_file: deprecated_member_use
// lib/presentation/screens/game_board_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/game_result.dart';
import '../../domain/entities/piece.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board_widget.dart'; // Import the new GameBoardWidget

/// The main screen for displaying the chess game board and controls.
class GameComputerScreen extends StatelessWidget {
  GameComputerScreen({super.key});
  final GameController controller = Get.find<GameController>();
  // bool canPop = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // didPop = canPop;
        } else {
          // await showGiveUpDialog(
          //   onPressedYesButton: () {
          //     canPop = true;
          //     print('didpop $didPop $result');
          //     Get.back();
          //   },
          // );
          //
          // Get.dialog(
          //   DrawDialog(
          //     whitePlayerName: "Riyadh771",
          //     blackPlayerName: "eduardo999",
          //     whiteElo: 1482,
          //     blackElo: 1945,
          //     resultReason: "abandoning",
          //     timeWhite: "09:30",
          //     timeBlack: "09:57",
          //     eloLevel: 1482,
          //   ),
          //   barrierDismissible: false,
          // );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.resetGame(),
              tooltip: 'إعادة تعيين اللعبة',
            ),
          ],
        ),

        ///
        ///
        ///
        ///
        body: SafeArea(
          child: Column(
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

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Chess Board centered
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1, // Make the board square
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const GameBoardWidget(), // The actual board UI
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Game controls (e.g., undo, redo - not fully implemented in this example)
              // UndoRedoWidgets(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class UndoRedoWidgets extends StatelessWidget {
  const UndoRedoWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // controller.undoMove(); // Implement undo logic in controller
              Get.snackbar('Undo', 'Undo functionality coming soon!');
            },
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // controller.redoMove(); // Implement redo logic in controller
              Get.snackbar('Redo', 'Redo functionality coming soon!');
            },
            icon: const Icon(Icons.redo),
            label: const Text('Redo'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
