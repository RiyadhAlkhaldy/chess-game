import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/presentation/bindings/game_binding.dart';
import 'package:chess_gemini_2/presentation/controllers/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('GameController should be initialized with default values', () {
    GameBinding().dependencies(); // Initialize dependencies
    final GameController gameController = Get.find<GameController>();

    expect(gameController.board.value, Board.initial());

    gameController.gameResult.value.copyWith;
  });
}
