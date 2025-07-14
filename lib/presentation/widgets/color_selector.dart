import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/piece.dart';
import '../controllers/get_options_controller.dart';

class ColorSelector extends StatelessWidget {
  final GameOptionsController controller;

  const ColorSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            PieceColor.values.map((color) {
              Widget widget;
              String label;
              switch (color) {
                case PieceColor.white:
                  label = 'White';
                  widget = WhitePawn(size: 50);
                  break;
                case PieceColor.random:
                  label = 'Random';
                  widget = Row(
                    children: [BlackPawn(size: 30), WhitePawn(size: 30)],
                  );
                  break;
                case PieceColor.black:
                  label = 'Black';
                  widget = BlackPawn(size: 50);
                  break;
              }
              return GestureDetector(
                onTap: () => controller.choseColor.value = color,
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          controller.choseColor.value == color
                              ? Colors.blue.shade100
                              : Colors.grey,
                      radius: 30,
                      child: widget,
                    ),
                    SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color:
                            controller.choseColor.value == color
                                ? Colors.blue.shade200
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
