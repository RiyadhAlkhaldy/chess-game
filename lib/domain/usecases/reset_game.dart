// lib/domain/usecases/reset_game.dart

import '../repositories/game_repository.dart';

/// حالة استخدام لإعادة تعيين اللعبة إلى حالتها الأولية.
/// تعتمد على [GameRepository] لإدارة إعادة التعيين.
class ResetGame {
  final GameRepository repository;

  ResetGame(this.repository);

  /// تنفذ حالة الاستخدام.
  void execute() {
    repository.resetGame();
  }
}
