// lib/data/engine/ai_engine.dart
//
// ✅ ملف محرك الذكاء الاصطناعي للشطرنج.
// ✅ يعتمد على خوارزمية Alpha-Beta مع أحدث تحسينات مستخدمة في المحركات الحديثة.
// ✅ مصمّم ليعمل مع واجهات Board غير قابلة للتغيير (Immutable) كما في مشروعك.
// ✅ طريقة الاستدعاء (Clean Architecture):
//    - GameController يستدعي UseCase (مثلاً GetAiMoveUseCase).
//    - UseCase يستدعي GameRepositoryImpl.
//    - GameRepositoryImpl ينادي AiEngine.search(Board) وربما داخل Isolate.
//    - AiEngine يعيد أفضل حركة Move? لتطبيقها على لوحة اللعبة.
//
// المزايا المفعّلة هنا:
// - Iterative Deepening, Transposition Table (Zobrist Key من Board)
// - Move Ordering (PV/Killers/History)
// - PVS, Aspiration Windows, LMR, Null-Move Pruning, Quiescence
// - Extensions بسيطة (كش الملك / ترقية بيدق)

import 'dart:math' as math; // استيراد مكتبة الرياضيات لاستخدام log للحسابات الخاصة بـ LMR

import '../../domain/entities/board.dart'; // استيراد كيان اللوحة Board (مصدر الحقيقة لحالة اللعبة)
import '../../domain/entities/move.dart';  // استيراد كيان الحركة Move (يحتوي معلومات مثل isCapture, isPromotion)
import '../../domain/entities/piece.dart'; // استيراد كيان القطعة Piece (نحتاج اللون لتحديد اللاعب)
import '../../domain/entities/cell.dart';  // استيراد كيان الخلية Cell (لتقييم history heuristic حسب from/to)

/// AiSearchConfig: إعدادات محرك البحث
/// - maxDepth: أقصى عمق للتعاقب (Iterative Deepening سيبدأ من 1 حتى هذا العمق)
/// - timeMs: حد زمني لإيقاف البحث (مفيد عند تشغيله في Isolate)
/// - aspirationDelta: نصف عرض نافذة Aspiration حول قيمة العمق السابق (بالسنتيبون)
/// - enableNullMove / enableLMR / enablePVS: تمكين/تعطيل تحسينات محددة لتسهيل الضبط
class AiSearchConfig {
  final int maxDepth;              // العمق الأقصى للبحث
  final int timeMs;                // الزمن الأقصى للبحث بالميلي ثانية
  final int aspirationDelta;       // عرض نافذة Aspiration (centipawns)
  final bool enableNullMove;       // تفعيل تقليم null-move
  final bool enableLMR;            // تفعيل تقليل العمق للحركات المتأخرة (LMR)
  final bool enablePVS;            // تفعيل مبدأ البحث في خط الـ PV (PVS)

  const AiSearchConfig({
    this.maxDepth = 6,             // قيمة افتراضية مناسبة للمحمول
    this.timeMs = 3000,            // 3 ثوانٍ للبحث
    this.aspirationDelta = 40,     // نافذة ضيّقة حول النتيجة السابقة
    this.enableNullMove = true,    // null move مفعّل
    this.enableLMR = true,         // LMR مفعّل
    this.enablePVS = true,         // PVS مفعّل
  });
}

/// _TTEntry: سجل داخل جدول النقل (Transposition Table)
/// - key: مفتاح زوبريست للوضعية الحالية
/// - depth: العمق الذي حسبنا فيه score
/// - score: نتيجة التقييم المخزنة
/// - flag: نوع النتيجة (EXACT, LOWER, UPPER) لاستخدامها مع حدود alpha/beta
/// - best: أفضل حركة لهذا المفتاح (للاستخدام في ترتيب النقلات لاحقًا)
/// - age: عمر الإدخال لدعم سياسات الاستبدال
class _TTEntry {
  final int key;    // مفتاح zobrist الفريد للوضعية
  final int depth;  // العمق الذي وصلت إليه هذه النتيجة
  final int score;  // قيمة التقييم (بوحدة سنتيبون عادة)
  final int flag;   // 0=EXACT, 1=LOWER, 2=UPPER
  final Move? best; // أفضل حركة معروفة من هذه العقدة
  final int age;    // عمر الإدخال لاختيار الأحدث عند التعارض
  const _TTEntry(this.key, this.depth, this.score, this.flag, this.best, this.age); // مُنشئ بسيط
}

/// _TT: جدول النقل (Transposition Table)
/// - مخزن على شكل مصفوفة ذات حجم قوة 2 لتسريع الفهرسة بالـ bitmask.
/// - age: يزيد مع كل تكرار عمق (iterative deepening) لتفضيل القيم الأحدث.
class _TT {
  final List<_TTEntry?> _tab; // مخزن الإدخالات (قد يحتوي null للمواقع الفارغة)
  int age = 0;                // العمر الحالي لدورة البحث
  _TT(int sizePow2) : _tab = List<_TTEntry?>.filled(sizePow2, null); // تهيئة الجدول بالحجم المطلوب

  _TTEntry? probe(int key) {                  // probe: محاولة قراءة إدخال من الجدول
    final idx = key & (_tab.length - 1);      // استخدام bitmask بدل % لتحسين الأداء
    final e = _tab[idx];                      // جلب الإدخال في هذا الموضع
    if (e != null && e.key == key) return e;  // التحقق من تطابق المفتاح (تجنب الاصطدام)
    return null;                              // عدم وجود إدخال صالح
  }

  void store(int key, int depth, int score, int flag, Move? best) { // store: تخزين إدخال
    final idx = key & (_tab.length - 1);      // فهرسة سريعة
    final cur = _tab[idx];                    // الإدخال الحالي في الموضع
    // سياسة الاستبدال: استبدل إذا كان الموضع فارغًا، أو العمق الجديد أعمق، أو الإدخال الجديد أحدث عمرًا
    if (cur == null || depth > cur.depth || age > cur.age) {
      _tab[idx] = _TTEntry(key, depth, score, flag, best, age); // استبدال الإدخال
    }
  }
}

/// _Killers: مصفوفة تحفّظ "الحركات القاتلة" لكل عمق.
/// - الفكرة: الحركات الهادئة التي سببت قطعًا (beta-cutoff) سابقًا غالبًا ستسبب قطعًا مرة أخرى.
/// - نخزن حركتين لكل عمق (الأكثر فعالية).
class _Killers {
  final List<List<Move?>> k;                              // لكل عمق: قائمتان للحركات القاتلة
  _Killers(int maxDepth): k = List.generate(maxDepth + 4, (_) => [null, null]); // مساحة إضافية احتياطية

  void add(int d, Move m) {        // إضافة حركة قاتلة لعمق d
    if (m.isCapture) return;       // لا نضيف الالتقاطات (هي قوية بذاتها بترتيب آخر)
    if (k[d][0] != m) {            // إن لم تكن الحركة هي الأولى
      k[d][1] = k[d][0];           // ازاحة الأولى للثانية
      k[d][0] = m;                 // وتعيين الحركة الجديدة كأول قاتلة
    }
  }

  bool isKiller(int d, Move m) => !m.isCapture && (k[d][0] == m || k[d][1] == m); // التحقق إن كانت الحركة قاتلة
}

/// _History: مصفوفة النقاط التاريخية للحركات (History Heuristic)
/// - h[side][from][to]: يجمع النقاط عندما تؤدي الحركة لقطع/تحسين.
/// - تساعد في ترتيب النقلات الهادئة (غير الالتقاطات).
class _History {
  final List<List<List<int>>> h = List.generate(2, (_) => List.generate(64, (_) => List.filled(64, 0))); // تهيئة 2*64*64

  int score(PieceColor side, Move m) => h[_sideIdx(side)][_sq(m.start)][_sq(m.end)]; // إرجاع النقاط لحركة ما

  void reward(PieceColor side, Move m, int depth) { // مكافأة الحركة الناجحة (مربوطة بالعمق^2)
    h[_sideIdx(side)][_sq(m.start)][_sq(m.end)] += depth * depth;
  }

  static int _sq(Cell c) => c.row * 8 + c.col;                         // تحويل خلية إلى فهرس [0..63]
  static int _sideIdx(PieceColor s) => (s == PieceColor.white) ? 0 : 1; // الأبيض=0، الأسود=1
}

/// Deadline: مؤقت بسيط لإيقاف البحث بعد timeMs
class Deadline {
  final int _deadlineMs;                    // المدة المسموحة
  final int _startMs;                       // وقت بداية البحث
  Deadline(int timeMs): _deadlineMs = timeMs, _startMs = DateTime.now().millisecondsSinceEpoch; // حفظ البداية
  bool get expired => DateTime.now().millisecondsSinceEpoch - _startMs >= _deadlineMs; // تحقق من الانقضاء
}

/// AiEngine: الكلاس الرئيسي للمحرك
/// - يُنشأ داخل Repository (أو يُحقن عبر DI) ويتم استدعاء search(rootBoard)
class AiEngine {
  final AiSearchConfig cfg; // إعدادات البحث
  final _TT tt;             // جدول النقل

  AiEngine({AiSearchConfig? cfg, int ttSize = 1 << 20}) // ttSize: حجم الجدول (عدد الخانات)
      : cfg = cfg ?? const AiSearchConfig(),            // استخدام الإعدادات الافتراضية إن لم تُمرر
        tt = _TT(ttSize);                               // تهيئة جدول النقل

  Future<Move?> search(Board root) async { // الدالة العامة: تعيد أفضل حركة للوحة المعطاة
    final timer = Deadline(cfg.timeMs);     // مؤقت لإيقاف البحث عند انتهاء الوقت
    Move? best;                             // أفضل حركة حتى الآن
    int lastScore = 0;                      // آخر تقييم (لاستخدام Aspiration Windows)
    List<Move> pv = <Move>[];               // Principal Variation: أفضل خط مكتشف

    for (int depth = 1; depth <= cfg.maxDepth; depth++) { // Iterative Deepening: من العمق 1 للأقصى
      tt.age++;                                           // زيادة عمر الجدول (يُستخدم في سياسة الاستبدال)
      int alpha = lastScore - cfg.aspirationDelta;        // نافذة Aspiration: البداية حول lastScore
      int beta  = lastScore + cfg.aspirationDelta;        // الحد العلوي للنافذة
      int tries = 0;                                      // محاولات توسيع النافذة عند الفشل

      while (true) {                                      // حلقة تكرار لتوسيع النافذة إذا فشلنا
        final ctx = _Ctx(this, timer, depth);             // سياق البحث: يحتوي killers/history/timer
        pv.clear();                                       // تنظيف خط PV السابق
        final score = _alphaBeta(root, depth, alpha, beta, ctx, pvOut: pv); // استدعاء ألفا-بيتا

        if (timer.expired) break;                         // إذا انتهى الوقت نخرج فورًا

        if (score <= alpha && tries < 2) {                // فشل منخفض (Fail-low): وسّع النافذة للأسفل
          alpha -= cfg.aspirationDelta * 2; tries++; continue;
        }
        if (score >= beta  && tries < 2) {                // فشل مرتفع (Fail-high): وسّع النافذة للأعلى
          beta  += cfg.aspirationDelta * 2; tries++; continue;
        }

        lastScore = score;                                // تحديث آخر تقييم
        if (pv.isNotEmpty) best = pv.first;               // حفظ أول حركة من خط PV كأفضل حركة
        break;                                            // خرجنا لأن البحث نجح ضمن النافذة
      }
      if (timer.expired) break;                           // نهاية زمن البحث: إيقاف المزيد من الأعماق
    }
    return best;                                          // إعادة أفضل حركة تم إيجادها
  }

  static const int INF = 1 << 30;                         // قيمة لا نهائية تقريبية للمقارنة
  static const int EXACT = 0, LOWER = 1, UPPER = 2;       // أنواع أعلام TT

  int _alphaBeta(Board b, int depth, int alpha, int beta, _Ctx ctx, {List<Move>? pvOut}) { // الدالة الأساسية للبحث
    if (ctx.timer.expired) return 0;                      // أوقف فورًا إذا انتهى الوقت

    final key = b.zobristKey;                             // مفتاح Zobrist للوضعية الحالية
    final origAlpha = alpha;                              // حفظ alpha الأصلي لتحديد flag لاحقًا

    // --- 1) فحص جدول النقل (TT probe) ---
    final tte = tt.probe(key);                            // محاولة استرجاع إدخال من TT
    Move? pvMove = tte?.best;                             // قد نستخدم أفضل حركة لترتيب النقلات
    if (tte != null && tte.depth >= depth) {              // إذا كان الإدخال أعمق أو مساويًا لعمقنا
      if (tte.flag == EXACT) return tte.score;            // قيمة دقيقة: نعيدها مباشرة
      if (tte.flag == LOWER && tte.score > alpha) alpha = tte.score; // حد سفلي: ارفع alpha
      if (tte.flag == UPPER && tte.score < beta)  beta  = tte.score; // حد علوي: اخفض beta
      if (alpha >= beta) return tte.score;                // قطع مبكر إذا ضاقت النافذة
    }

    // --- 2) شرط الحد الأساسي: عندما ينتهي العمق ننتقل لبحث الهدوء (Quiescence) ---
    if (depth <= 0) {
      return _quiescence(b, alpha, beta, ctx);            // بحث هدوء لمنع Horizon Effect
    }

    // --- 3) Null-move pruning: تقليم سريع بتبديل الدور بدون حركة ---
    if (cfg.enableNullMove && !_inCheck(b) && depth >= 3 && _hasNonPawnMaterial(b)) {
      final nullScore = -_alphaBeta(_makeNull(b), depth - 1 - 2, -beta, -beta + 1, ctx); // تقليم بفجوة R=2
      if (nullScore >= beta) return nullScore;            // إذا تجاوز الحد → قطع (fail-high)
    }

    // --- 4) توليد النقلات القانونية ---
    var moves = b.getAllLegalMovesForCurrentPlayer();     // جميع الحركات القانونية للوضعية الحالية

    // --- 5) ترتيب النقلات: PV أولاً ثم Killers ثم History ثم الالتقاطات ---
    moves = _orderMoves(b, moves, pvMove, ctx);           // ترتيب مهم جدًا لتقليل مساحة البحث

    int bestScore = -INF;                                  // أفضل نتيجة حتى الآن
    Move? bestMove;                                        // أفضل حركة مقابلة

    for (int i = 0; i < moves.length; i++) {               // حلقة على جميع النقلات
      final m = moves[i];                                  // الحركة الحالية
      final ext = _computeExtension(b, m);                 // Extensions بسيطة (كش/ترقية)
      int newDepth = depth - 1 + ext;                      // العمق الجديد بعد الامتداد

      // --- 6) LMR: تقليل العمق للحركات المتأخرة والهادئة ---
      int reduction = 0;                                   // مقدار التقليل
      final isQuiet = !m.isCapture && !_givesCheck(b, m);  // حركة هادئة: لا التقاط ولا كش
      if (cfg.enableLMR && isQuiet && i > 3 && depth >= 3) {
        reduction = _lmrReduction(depth, i);               // حساب التقليل حسب العمق وترتيب الحركة
      }

      final nextBoard = b.simulateMove(m);                 // إنشاء لوحة جديدة بتنفيذ الحركة (Immutable API)

      int score;                                           // نتيجة الفرع
      // --- 7) PVS: بحث ضيق لجميع النقلات بعد الأولى ---
      if (!cfg.enablePVS || i == 0) {                      // النقلات الأولى (PV) نبحث بنافذة كاملة
        score = -_alphaBeta(nextBoard, newDepth, -beta, -alpha, ctx);
      } else {                                             // النقلات اللاحقة نبحث بنافذة ضيقة (α, α+1)
        score = -_alphaBeta(nextBoard, newDepth - reduction, -alpha - 1, -alpha, ctx);
        if (score > alpha && reduction > 0) {              // إذا تخطى العتبة بعد LMR → أعد البحث بعمق كامل
          score = -_alphaBeta(nextBoard, newDepth, -alpha - 1, -alpha, ctx);
        }
        if (score > alpha && score < beta) {               // وإذا بقي ضمن النافذة → بحث كامل (re-search)
          score = -_alphaBeta(nextBoard, newDepth, -beta, -alpha, ctx);
        }
      }

      // --- 8) تحديث أفضل نتيجة وأفضل حركة ---
      if (score > bestScore) {                             // وجدنا نتيجة أفضل
        bestScore = score; bestMove = m;                   // حفظ الأفضل
        if (pvOut != null) {                               // تحديث خط PV (نبقي فقط أول حركة هنا)
          pvOut
            ..clear()
            ..add(m);
          // ملاحظة: تتبع كامل خط الـ PV عبر TT ممكن، لكن مختصر هنا لأن Board غير قابل للتغيير.
        }
        if (bestScore > alpha) {                           // توسيع alpha إذا تحسننا
          alpha = bestScore;
          if (alpha >= beta) {                             // قطع (beta cutoff)
            if (isQuiet) {                                 // مكافأة Killer/History للحركات الهادئة التي قطعت
              ctx.killers.add(ctx.ply, m);
              ctx.history.reward(b.currentPlayer, m, depth);
            }
            break;                                         // الخروج لتقليل الشجرة
          }
        }
      }
    }

    // --- 9) تخزين النتيجة في جدول النقل ---
    final flag = (bestScore <= origAlpha) ? UPPER : (bestScore >= beta) ? LOWER : EXACT; // تحديد نوع العلم
    tt.store(key, depth, bestScore, flag, bestMove);       // تخزين (score/best/flag/depth)

    return bestScore;                                      // إعادة أفضل نتيجة
  }

  int _quiescence(Board b, int alpha, int beta, _Ctx ctx) { // بحث الهدوء: متابعة فقط النقلات "الهادرة"
    final standPat = b.evaluateBoard();                    // تقييم ثابت للوضعية الحالية
    if (standPat >= beta) return standPat;                 // قطع إذا تجاوزنا beta
    if (standPat > alpha) alpha = standPat;                // تحسين alpha إن أمكن

    // توليد نقلات الهجوم (التقاط/كش) فقط لتجنب تقلبات سطحية
    final all = b.getAllLegalMovesForCurrentPlayer();      // كل النقلات القانونية
    final qMoves = <Move>[];                               // قائمة نقلات الهدوء
    for (final m in all) {
      if (m.isCapture || _givesCheck(b, m)) qMoves.add(m); // احتفظ فقط بالالتقاطات/الكش
    }

    // ترتيب بسيط للالتقاطات: MVV-LVA مبسّط (نضع الالتقاطات أولًا)
    qMoves.sort((a, c) {
      final sa = a.isCapture ? 1 : 0;
      final sb = c.isCapture ? 1 : 0;
      return sb - sa;                                      // الالتقاطات قبل غيرها
    });

    for (final m in qMoves) {                              // جرّب كل نقلة هادرة
      final nb = b.simulateMove(m);                        // طبق الحركة على لوحة جديدة
      final score = -_quiescence(nb, -beta, -alpha, ctx);  // بحث递归 مع نوافذ معكوسة
      if (score >= beta) return score;                     // قطع إذا تجاوزنا beta
      if (score > alpha) alpha = score;                    // تحسين alpha
    }
    return alpha;                                          // إعادة alpha كأفضل bound
  }

  // --- Helpers / مساعدات ---

  bool _inCheck(Board b) => b.isKingInCheck(b.currentPlayer); // هل اللاعب الحالي في كش؟

  bool _givesCheck(Board b, Move m) {                          // هل الحركة ستؤدي إلى كش للخصم؟
    final nb = b.simulateMove(m);                              // طبّق الحركة على لوحة جديدة
    final opp = b.currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white; // لون الخصم
    return nb.isKingInCheck(opp);                              // تحقق إن كان ملك الخصم في كش بعد الحركة
  }

  bool _hasNonPawnMaterial(Board b) {                          // هل يوجد قطع غير البيادق؟ (لتفعيل null move)
    // لتبسيط المثال نرجع true دائمًا. يمكن لاحقًا إضافة فحص فعلي عبر Board.
    return true;
  }

  Board _makeNull(Board b) {                                   // تنفيذ "حركة فارغة" (null move)
    // الفكرة: تبديل اللاعب الحالي بدون تحريك أي قطعة، مع إزالة en passant
    // لأن Board غير قابلة للتغيير، نستخدم copyWith لتعديل الحقول المطلوبة.
    return b.copyWith(
      currentPlayer: (b.currentPlayer == PieceColor.white) ? PieceColor.black : PieceColor.white, // تبديل الدور
      enPassantTarget: null,                                                                       // إلغاء حق الأخذ بالتجاوز
    );
  }

  List<Move> _orderMoves(Board b, List<Move> moves, Move? pv, _Ctx ctx) { // ترتيب النقلات لتحسين فعالية ألفا-بيتا
    moves.sort((a, bmv) {
      int sa = 0, sb = 0;                                     // نقاط الترتيب لكل حركة
      if (pv != null && a == pv) sa += 1 << 30;               // حركة PV لها أولوية قصوى
      if (pv != null && bmv == pv) sb += 1 << 30;
      if (ctx.killers.isKiller(ctx.ply, a)) sa += 1 << 20;    // حركات Killer بأولوية عالية
      if (ctx.killers.isKiller(ctx.ply, bmv)) sb += 1 << 20;
      sa += a.isCapture ? (1 << 18) : ctx.history.score(b.currentPlayer, a);     // الالتقاطات ثم history
      sb += bmv.isCapture ? (1 << 18) : ctx.history.score(b.currentPlayer, bmv);
      return sb - sa;                                         // ترتيب تنازلي حسب النقاط
    });
    return moves;                                             // إعادة القائمة مرتبة
  }

  int _lmrReduction(int depth, int moveIdx) {                 // حساب مقدار تقليل العمق (LMR)
    final r = (math.log(depth + 1) * math.log(moveIdx + 1)).floor(); // صيغة لوغاريتمية شائعة
    return r.clamp(1, depth - 1);                             // لا تقلل أكثر من (depth-1) ولا أقل من 1
  }

  int _computeExtension(Board b, Move m) {                    // حساب الامتدادات (Extensions) البسيطة
    int ext = 0;                                              // مبدئياً لا امتداد
    if (_givesCheck(b, m)) ext += 1;                          // امتداد عند إعطاء كش
    if (m.isPromotion) ext += 1;                              // امتداد عند ترقية بيدق
    return ext.clamp(0, 2);                                   // سقف الامتداد إلى 2 لتجنب الانفجار
  }
}

/// _Ctx: سياق البحث لدورة واحدة (depth محدد)
/// - يحتوي على: المؤقت، قائمة الـ Killer، مصفوفة History، عداد ply (عمق حقيقي من الجذر)
class _Ctx {
  final AiEngine eng;      // مرجع للمحرك (لو احتجنا إعداداته)
  final Deadline timer;    // مؤقت البحث
  final _Killers killers;  // مخزن حركات Killer لكل عمق
  final _History history;  // تاريخ الحركات لهيوريستك الترتيب
  int ply = 0;             // عداد الطبقة/المستوى من الجذر (يمكن استغلاله لاحقًا للتوسعات)
  _Ctx(this.eng, this.timer, int maxDepth)
      : killers = _Killers(maxDepth + 8), // مساحة إضافية للحماية
        history = _History();             // تهيئة history
}
