// lib/domain/usecases/get_ai_move.dart

import '../entities/board.dart';
import '../entities/move.dart';
import '../entities/piece.dart';
import '../repositories/game_repository.dart';

/// حالة استخدام لطلب حركة من الذكاء الاصطناعي.
/// تعتمد على [GameRepository] للحصول على الحركات وتحديد الأفضل.
class GetAiMove {
  final GameRepository repository;

  GetAiMove(this.repository);

  /// تنفذ حالة الاستخدام.
  /// [board] هي اللوحة الحالية.
  /// [aiPlayerColor] هو لون القطع التي يلعب بها الذكاء الاصطناعي.
  /// تعيد [Move] المقترحة من الذكاء الاصطناعي، أو null إذا لم تكن هناك حركات ممكنة.
  Future<Move?> execute(
    Board board,
    PieceColor aiPlayerColor,
    int aiDepth,
  ) async {
    return await repository.getAiMove(board, aiPlayerColor, aiDepth);
  }
}
