// lib/domain/usecases/is_king_in_check.dart

import '../entities/piece.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام للتحقق مما إذا كان الملك في حالة كش.
/// تعتمد على [GameRepository] لإجراء التحقق.
class IsKingInCheck {
  final GameRepository repository;

  IsKingInCheck(this.repository);

  /// تنفذ حالة الاستخدام.
  /// [kingColor] هو لون الملك المراد التحقق منه.
  /// تعيد [bool]، صحيح إذا كان الملك في كش.
  bool execute(PieceColor kingColor) {
    return repository.isKingInCheck(kingColor);
  }
}
