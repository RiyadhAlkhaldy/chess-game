// lib/domain/usecases/get_legal_moves.dart
import '../entities/cell.dart';
import '../entities/move.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام للحصول على الحركات القانونية لقطعة معينة.
/// تعتمد على [GameRepository] لجلب الحركات.
class GetLegalMoves {
  final GameRepository repository;

  GetLegalMoves(this.repository);

  /// تنفذ حالة الاستخدام.
  /// [cell] هي الخلية التي تحتوي على القطعة المراد التحقق من حركاتها.
  /// تعيد قائمة بـ [Move] للحركات القانونية.
  List<Move> execute(Cell cell) {
    return repository.getLegalMoves(cell);
  }
}
