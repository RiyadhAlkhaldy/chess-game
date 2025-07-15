// lib/domain/usecases/has_any_legal_moves.dart

import '../entities/piece.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام للتحقق مما إذا كان اللاعب الحالي لديه أي حركات قانونية.
/// تستخدم لتحديد حالات الطريق المسدود أو كش الملك.
class HasAnyLegalMoves {
  final GameRepository repository;

  HasAnyLegalMoves(this.repository);

  /// تنفذ حالة الاستخدام.
  /// [playerColor] هو لون اللاعب المراد التحقق من حركاته.
  /// تعيد [bool]، صحيح إذا كان هناك أي حركات قانونية.
  bool execute(PieceColor playerColor) {
    return repository.hasAnyLegalMoves(playerColor);
  }
}
