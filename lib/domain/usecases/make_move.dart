// lib/domain/usecases/make_move.dart
import '../entities/board.dart';
import '../entities/move.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام لتنفيذ حركة على اللوحة.
/// تعتمد على [GameRepository] لتعديل حالة اللوحة.
class MakeMove {
  final GameRepository repository;

  MakeMove(this.repository);

  /// تنفذ حالة الاستخدام.
  /// [move] هي الحركة المراد تنفيذها.
  /// تعيد [Board] الجديدة بعد تنفيذ الحركة.
  Board execute(Move move) {
    return repository.makeMove(move);
  }
}
