import 'package:chess_gemini_2/domain/entities/cell.dart';
import 'package:chess_gemini_2/domain/repositories/game_repository.dart';
import 'package:chess_gemini_2/presentation/bindings/game_binding.dart';
import 'package:chess_gemini_2/presentation/controllers/game_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('group game_repository_impl', () {
    test('test game_repository_impl', () async {
      GameBinding().dependencies(); // Initialize dependencies
      final GameController gameController = Get.find<GameController>();
      final GameRepository gameRepositoryImpl = gameController.gameRepository;

      final response = await gameRepositoryImpl.getLegalMovesForPiece(
        gameController.board.value,
        Cell(row: 6, col: 1),
      );
      response.fold((l) {}, (r) {
        debugPrint(r.toString());
      });
    });
  });
}
