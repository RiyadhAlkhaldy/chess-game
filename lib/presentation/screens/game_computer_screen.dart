// lib/presentation/screens/game_computer_screen.dart
// تحسينات: Material 3 + Responsive Layout (هاتف/تابلت/ويب) + أدوات وصول

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/export.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board_widget.dart';

class GameComputerScreen extends StatelessWidget {
  GameComputerScreen({super.key});
  final GameController controller = Get.find<GameController>();

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // منع الخروج إذا اللعبة لم تنته
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) Get.back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chess vs Computer'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900; // تابلت/ويب
              final controls = _ControlsBar(controller: controller);

              final board = const GameBoardWidget();

              return Padding(
                padding: const EdgeInsets.all(12),
                child:
                    isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اللوح
                            Expanded(flex: 3, child: Center(child: board)),
                            const SizedBox(width: 16),
                            // اللوحة الجانبية
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  controls,
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: _SidePanel(controller: controller),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            controls,
                            const SizedBox(height: 12),
                            Expanded(child: Center(child: board)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: _SidePanel(controller: controller),
                            ),
                          ],
                        ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إنهاء اللعبة؟'),
            content: const Text('هل تريد الخروج من المباراة الحالية؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('خروج'),
              ),
            ],
          ),
    );
    return res ?? false;
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      // runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Tooltip(
          message: 'تراجع عن الحركة الأخيرة',
          child: FilledButton(
            onPressed: controller.undoMove,
            child: const Icon(Icons.undo),
            // label: const Text('Undo'),
          ),
        ),
        Tooltip(
          message: 'إعادة الحركة المتراجَع عنها',
          child: FilledButton(
            onPressed: controller.redoMove,
            child: const Icon(Icons.redo),
            // label: const Text('Redo'),
          ),
        ),
        Tooltip(
          message: 'استسلام',
          child: OutlinedButton(
            onPressed: controller.resign,
            child: const Icon(Icons.flag),
            // label: const Text('Resign'),
          ),
        ),
        Tooltip(
          message: 'طلب تعادل',
          child: OutlinedButton(
            onPressed: controller.offerDraw,
            child: const Icon(Icons.handshake),
            // label: const Text('Offer Draw'),
          ),
        ),
        FilledButton(
          onPressed: controller.resetGame,
          child: const Icon(Icons.refresh),
          // label: const Text('بدء مباراة جديدة'),
        ),
      ],
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          final isCheck = controller.isCurrentKingInCheck();
          final status = controller.gameResult;
          // GetX<GameController>(
          //   builder: (controller) {
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
                  'تعادل! السبب: ${controller.gameResult.value.drawReason == DrawReason.fiftyMoveRule
                      ? 'قاعدة الخمسين حركة'
                      : controller.gameResult.value.drawReason == DrawReason.threefoldRepetition
                      ? 'تكرار ثلاثي'
                      : controller.gameResult.value.drawReason == DrawReason.agreement
                      ? 'بالاتفاق'
                      : 'مواد غير كافية'}';
              statusColor = Colors.blue;
              break;
          }

          // return Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     statusText,
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //       color: statusColor,
          //     ),
          //   ),
          //   //   );
          //   // },
          // );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isCheck ? Icons.warning_amber : Icons.circle, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    isCheck ? 'تحذير: كش' : 'الوضع طبيعي',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'الدور الحالي: ${controller.board.value.currentPlayer == PieceColor.white ? 'أبيض' : 'أسود'}',
              ),
              const SizedBox(height: 12),

              Text(
                "نتيجةاللعبة: $statusText",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}


          /*        switch (controller.gameResult.value.outcome) {
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
                          'تعادل! السبب: ${controller.gameResult.value.drawReason == DrawReason.fiftyMoveRule
                              ? 'قاعدة الخمسين حركة'
                              : controller.gameResult.value.drawReason == DrawReason.threefoldRepetition
                              ? 'تكرار ثلاثي'
                              : controller.gameResult.value.drawReason == DrawReason.agreement
                              ? 'بالاتفاق'
                              : 'مواد غير كافية'}';
                      statusColor = Colors.blue;
                      break;
                  } */