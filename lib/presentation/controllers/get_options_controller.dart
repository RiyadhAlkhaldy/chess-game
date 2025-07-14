import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/piece.dart';
import 'game_controller.dart';

class GameOptionsController extends GetxController {
  var difficultyLevel = 0.obs; // 0 = Beginner, up to 9 or more
  var showMoveHints = true.obs;

  int get elo => 200 + difficultyLevel.value * 100;

  // Define any necessary properties and methods for the main menu

  // Player type settings
  Rx<PlayerType> player1Type = PlayerType.human.obs; // Player White type
  Rx<PlayerType> player2Type = PlayerType.ai.obs; // Player Black typeom
  Rx<PieceColor> meColor =
      PieceColor.white.obs; // Reactive variable for the player's color
  Rx<PieceColor> choseColor =
      PieceColor.white.obs; // Reactive variable for the player's color
  // Reactive variable to track the selected game mode

  RxInt aiDepth = 3.obs; // AI depth for AI player

  void changeValuecolorPlayer(PieceColor playerColor) {
    if (playerColor == PieceColor.white) {
      meColor.value = playerColor;
      player1Type.value = PlayerType.human;
      player2Type.value = PlayerType.ai;
    } else if (playerColor == PieceColor.black) {
      meColor.value = playerColor;

      player1Type.value = PlayerType.ai;
      player2Type.value = PlayerType.human;
    } else {
      // make random between PieceColor.white and PieceColor.black
      var x = Random();
      int nextNumber = x.nextInt(13);
      debugPrint('nextNumber $nextNumber');
      if (nextNumber % 2 == 0) {
        changeValuecolorPlayer(PieceColor.white);
      } else {
        changeValuecolorPlayer(PieceColor.black);
      }
    }
  }
}
