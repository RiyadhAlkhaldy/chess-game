// lib/domain/usecases/check_draw_usecase.dart
import '../entities/board.dart';
import '../entities/game_result.dart';
import 'draw_state.dart';

/// واجهة مجردة لحالة استخدام التحقق من التعادل.
/// يجب أن تنفذ بواسطة فئة تقوم بالمنطق الفعلي للتحقق.
abstract class CheckDrawUseCase {
  GameResult? execute(Board board);
}

/// تنفيذ حالة استخدام التحقق من التعادل.
class CheckDrawUseCaseImpl implements CheckDrawUseCase {
  @override
  GameResult? execute(Board board) {
    // 1. التحقق من التعادل بالردب (Stalemate)
    // if (DrawState.isStalemate(board)) {
    //   return GameResult.stalemate();
    // }

    // // 2. التحقق من التعادل بتكرار الوضعية ثلاث مرات
    // if (DrawState.isThreefoldRepetition(board)) {
    //   return GameResult.draw(DrawReason.threefoldRepetition);
    // }

    // 3. التحقق من التعادل بقاعدة الخمسين نقلة
    if (DrawState.isFiftyMoveRule(board)) {
      return GameResult.draw(DrawReason.fiftyMoveRule);
    }

    // 4. التحقق من التعادل بسبب عدم كفاية المواد
    if (DrawState.isInsufficientMaterialDraw(board)) {
      return GameResult.draw(DrawReason.insufficientMaterial);
    }

    return null;
    // إذا لم يكن هناك تعادل، تستمر اللعبة
    // return GameResult.playing();
  }
}
