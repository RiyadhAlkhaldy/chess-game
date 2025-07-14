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
          title: GameBoardTitle(controller: controller),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New Game',
              onPressed: () {
                controller.newGame();
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Game',
              onPressed: () {
                controller.saveGame();
              },
            ),
            IconButton(
              icon: const Icon(Icons.light_mode),
              tooltip: 'Toggle Theme',
              onPressed: () {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ],
        ),

        ///
        ///
        ///
        ///
        ///
        ///
        body: SafeArea(
          child: Column(
            children: [
              // Display error messages
              Obx(
                () =>
                    controller.errorMessage.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              // Loading indicator
              Obx(
                () =>
                    controller.isLoading.value
                        ? const LinearProgressIndicator()
                        : const SizedBox.shrink(),
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

class GameBoardTitle extends StatelessWidget {
  const GameBoardTitle({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Display current player and game status in the app bar
      String status = '';
      final gameOutcome = controller.gameResult.value.outcome;
      final currentPlayer = controller.board.value.currentPlayer;

      if (gameOutcome == GameOutcome.playing) {
        status =
            '${currentPlayer == PieceColor.white ? 'White' : 'Black'}'
            ' to move';
        if (controller.aiEngine.isKingInCheck(
          controller.board.value,
          currentPlayer,
        )) {
          status += ' (Check!)'; // Indicate check
        }
      } else if (gameOutcome == GameOutcome.checkmate) {
        status =
            'Checkmate! ${controller.gameResult.value.winner == PieceColor.white ? 'White' : 'Black'} wins.';
      } else if (gameOutcome == GameOutcome.stalemate) {
        status = 'Stalemate! It\'s a Draw.';
      } else if (gameOutcome == GameOutcome.draw) {
        status =
            'Draw! (${controller.gameResult.value.drawReason?.name ?? 'Unknown'})';
      }

      return Text(status, style: Theme.of(context).textTheme.titleSmall);
    });
  }
}
