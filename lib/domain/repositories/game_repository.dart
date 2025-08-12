// lib/domain/repositories/game_repository.dart

import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/game_result.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

/// [AIGameRepository]
/// واجهة مجردة لتحديد عمليات البحث عن حركة الذكاء الاصطناعي.
/// Abstract interface to define AI move search operations.
abstract class AIGameRepository {
  /// [findBestMove]
  /// تبحث عن أفضل حركة للوحة المعطاة وعمق البحث.
  /// Finds the best move for the given board and search depth.
  Future<Move?> findBestMove(Board board, int depth);
}

/// واجهة توفر طرق التفاعل مع منطق لعبة الشطرنج.
/// هذه الواجهة تحدد العمليات التي يمكن أن يقوم بها نظام إدارة اللعبة.
abstract class GameRepository {
  /// الحصول على حالة اللوحة الحالية.
  Board getCurrentBoard();

  /// الحصول على جميع الحركات القانونية الممكنة للقطعة في الخلية المحددة.
  /// تعيد قائمة بالحركات القانونية.
  List<Move> getLegalMoves(Cell cell);

  /// تنفيذ حركة معينة على اللوحة.
  /// [move] هي الحركة المراد تنفيذها.
  /// تعيد [Board] جديدة بعد تنفيذ الحركة.
  Board makeMove(Move move);

  /// التحقق مما إذا كان الملك في حالة كش (Check) للّاعب الحالي.
  bool isKingInCheck(PieceColor kingColor);

  /// الحصول على نتيجة اللعبة الحالية (مثل كش ملك، تعادل، طريق مسدود).
  GameResult getGameResult();

  /// إعادة تعيين اللعبة إلى حالتها الأولية.
  void resetGame();

  /// محاكاة حركة على لوحة مؤقتة للتحقق من شرعيتها.
  /// [board] اللوحة الحالية للمحاكاة.
  /// [move] الحركة المراد محاكاتها.
  /// تعيد [Board] جديدة بعد المحاكاة.
  Board simulateMove(Board board, Move move);

  /// التحقق مما إذا كانت الحركة تضع الملك في خطر (كش).
  /// [board] اللوحة الحالية.
  /// [move] الحركة المراد التحقق منها.
  // bool isMoveResultingInCheck(Board board, Move move);

  /// الحصول على جميع الحركات القانونية للّاعب الحالي.
  List<Move> getAllLegalMovesForCurrentPlayer(Board baord);

  /// التحقق مما إذا كانت هناك أي حركات قانونية للّاعب الحالي.
  bool hasAnyLegalMoves(PieceColor playerColor);

  /// التحقق من قواعد التعادل مثل قاعدة الخمسين حركة أو التكرار الثلاثي.
  DrawReason? checkForDrawConditions(Board board);

  /// التحقق من حالة الكش ملك أو الطريق المسدود.
  GameResult checkGameEndConditions(Board board);

  /// الحصول على حركة مقترحة من الذكاء الاصطناعي.
  /// [board] هي اللوحة الحالية.
  /// [aiPlayerColor] هو لون اللاعب الذي يلعب به الذكاء الاصطناعي.
  /// تعيد [Move] المقترحة.
  Future<Move?> getAiMove(Board board, PieceColor aiPlayerColor, int aiDepth);

  /// [findBestMove]
  /// تبحث عن أفضل حركة للوحة المعطاة وعمق البحث.
  /// Finds the best move for the given board and search depth.
  // Future<Move?> findBestMove(Board board, int depth);
}
