// lib/domain/usecases/get_board_state.dart
import '../entities/board.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام للحصول على حالة اللوحة الحالية.
/// تعتمد على [GameRepository] لجلب البيانات.
class GetBoardState {
  final GameRepository repository;

  GetBoardState(this.repository);

  /// تنفذ حالة الاستخدام.
  /// تعيد [Board] الحالية.
  Board execute() {
    return repository.getCurrentBoard();
  }
}
