// lib/domain/usecases/get_game_result.dart

import '../entities/game_result.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام للحصول على نتيجة اللعبة الحالية.
/// تعتمد على [GameRepository] لجلب نتيجة اللعبة.
class GetGameResult {
  final GameRepository repository;

  GetGameResult(this.repository);

  /// تنفذ حالة الاستخدام.
  /// تعيد [GameResult] الحالية.
  GameResult execute() {
    return repository.getGameResult();
  }
}
