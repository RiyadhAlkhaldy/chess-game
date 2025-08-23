import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/get_options_controller.dart';
import '../widgets/color_selector.dart';

class GameOptionsView extends StatelessWidget {
  final controller = Get.find<GameOptionsController>();

  GameOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(title: Text('CHECKMATE!'), centerTitle: true),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Options",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 16),

              // Color selector
              ColorSelector(controller: controller),
              SizedBox(height: 20),

              // ELO info
              Obx(
                () => Column(
                  children: [
                    Text(
                      "Beginner ♟♟",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "ELO Level: ${controller.aiDepth}",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              GetX<GameOptionsController>(
                builder: (con) {
                  int aiDepth = con.aiDepth.value;
                  return Slider(
                    value: aiDepth.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 5,
                    label: 'AI Depth: ${aiDepth.round()}',
                    onChanged: (double value) {
                      debugPrint(value.toString());
                      aiDepth = value.toInt();
                      debugPrint("aiDepth $aiDepth");

                      con.aiDepth.value = aiDepth; // Update reactive variable
                    },
                  );
                },
              ),
              const Text('AI Difficulty (Depth)'),

              // // Difficulty slider
              // Obx(
              //   () => Slider(
              //     value: controller.difficultyLevel.value.toDouble(),
              //     min: 0,
              //     max: 9,
              //     divisions: 9,
              //     label: controller.elo.toString(),
              //     onChanged:
              //         (val) => controller.difficultyLevel.value = val.toInt(),
              //   ),
              // ),

              // Show move hints toggle
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Show move hints",
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: controller.showMoveHints.value,
                      onChanged: (val) => controller.showMoveHints.value = val,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Play button
              ElevatedButton(
                onPressed: () {
                  // navigate to game view
                  controller.changeValuecolorPlayer(
                    controller.choseColor.value,
                  );
                  Get.toNamed('GameComputerScreen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Text("Play", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
