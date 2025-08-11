import 'move.dart';

/// يمثل مدخلًا في جدول التحويل.
/// يخزن المعلومات الضرورية لتسريع البحث في المواقف المتكررة.
class TranspositionEntry {
  // النتيجة التي تم العثور عليها في البحث
  final int score;

  // العمق المتبقي في البحث الذي تم عنده تخزين النتيجة
  final int depth;

  // نوع العقدة التي تحدد ما إذا كانت النتيجة دقيقة أو مجرد حد
  final NodeType type;

  // أفضل حركة تم العثور عليها من هذا الموقف
  final Move? bestMove;

  TranspositionEntry({
    required this.score,
    required this.depth,
    required this.type,
    this.bestMove,
  });

  @override
  String toString() {
    return 'TranspositionEntry(score: $score, depth: $depth, type: $type, bestMove: $bestMove)';
  }
}

// تعريف أنواع العقد
// يستخدم لتحديد ما إذا كانت القيمة المخزنة هي نتيجة دقيقة أو مجرد حدود
enum NodeType {
  /// قيمة دقيقة للموقف.
  exact,

  /// القيمة هي حد أدنى (lower bound).
  /// أي أن النتيجة الحقيقية أكبر من أو تساوي هذه القيمة.
  alpha,

  /// القيمة هي حد أقصى (upper bound).
  /// أي أن النتيجة الحقيقية أقل من أو تساوي هذه القيمة.
  beta,
}
