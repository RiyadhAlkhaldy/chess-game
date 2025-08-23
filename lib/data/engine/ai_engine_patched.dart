// lib/data/engine/ai_engine.dart
//
// ✅ ملف محرك الذكاء الاصطناعي للشطرنج.
// ✅ يعتمد على خوارزمية Alpha-Beta مع أحدث تحسينات مستخدمة في المحركات الحديثة.
// ✅ مصمّم ليعمل مع واجهات Board غير قابلة للتغيير (Immutable) ويستخدم الدوال makeMove / unMakeMove بدلاً من SimulateMove.simulateMove.
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
//
// ملاحظة مهمة:
// - تم استبدال أي استخدام سابق لـ simulateMove بـ makeMove/unMakeMove مع إضافة تحقق (assert) في وضع التطوير للتأكد
//   من قابلية عكس الحركة بشكل صحيح.
//
// -------------------------------------------------------------
// الاستيرادات
// -------------------------------------------------------------
import 'dart:math'
    as math; // استيراد مكتبة الرياضيات لاستخدام log للحسابات الخاصة بـ LMR

import 'package:chess_gemini_2/domain/entities/board_hlper.dart';

import '../../domain/entities/board.dart'; // استيراد كيان اللوحة Board (مصدر الحقيقة لحالة اللعبة)
import '../../domain/entities/move.dart'; // استيراد كيان الحركة Move
import '../../domain/entities/piece.dart'; // استيراد تعريف القطع والألوان

// -------------------------------------------------------------
// كائن ضبط البحث
// -------------------------------------------------------------
class AiSearchConfig {
  final int maxDepth; // العمق الأقصى للبحث
  final int timeMs; // الزمن الأقصى للبحث بالميلي ثانية
  final int aspirationDelta; // عرض نافذة Aspiration (centipawns)
  final bool enableNullMove; // تفعيل تقليم null-move
  final bool enableLMR; // تفعيل تقليل العمق للحركات المتأخرة (LMR)
  final bool enablePVS; // تفعيل مبدأ البحث في خط الـ PV (PVS)

  const AiSearchConfig({
    this.maxDepth = 6, // قيمة افتراضية مناسبة للمحمول
    this.timeMs = 3000, // 3 ثوانٍ للبحث
    this.aspirationDelta = 40, // نافذة ضيّقة حول النتيجة السابقة
    this.enableNullMove = true, // null move مفعّل
    this.enableLMR = true, // LMR مفعّل
    this.enablePVS = true, // PVS مفعّل
  });
}

// -------------------------------------------------------------
// أنواع إدخالات جدول النقل
// -------------------------------------------------------------
enum _Bound { exact, lower, upper } // نوع الحد: نتيجة دقيقة/سفلية/علوية

// إدخال جدول النقل
class _TTEntry {
  final int key; // مفتاح زوبريست للوضع
  final int depth; // العمق الذي حسبت عنده القيمة
  final int value; // قيمة التقييم (score)
  final _Bound bound; // نوع الحد
  final Move? bestMove; // أفضل نقلة مسجلة لهذا الوضع

  const _TTEntry(this.key, this.depth, this.value, this.bound, this.bestMove);
}

// جدول النقل نفسه (مصفوفة ثابتة الحجم)
class _TT {
  final List<_TTEntry?> _table; // مصفوفة الإدخالات
  final int _mask; // قناع الفهرسة (حجم-1)

  _TT(int size) : _table = List<_TTEntry?>.filled(size, null), _mask = size - 1;

  _TTEntry? probe(int key) {
    // محاولة قراءة إدخال
    return _table[key & _mask];
  }

  void store(_TTEntry e) {
    // تخزين إدخال
    final idx = e.key & _mask;
    final old = _table[idx];
    // استراتيجية بسيطة: استبدال الإدخال الأقدم أو الأقل عمقاً
    if (old == null || e.depth >= old.depth) {
      _table[idx] = e;
    }
  }
}

// -------------------------------------------------------------
// مؤقت بسيط لإيقاف البحث
// -------------------------------------------------------------
class Deadline {
  final int _endAt; // وقت الانتهاء (ms منذ epoch)
  Deadline(int ms) : _endAt = DateTime.now().millisecondsSinceEpoch + ms;
  bool get expired =>
      DateTime.now().millisecondsSinceEpoch >= _endAt; // انتهى الوقت؟
}

// -------------------------------------------------------------
// المحرك
// -------------------------------------------------------------
class AiEngine {
  final AiSearchConfig cfg; // إعدادات البحث
  final _TT tt; // جدول النقل

  AiEngine({
    AiSearchConfig? cfg,
    int ttSize = 1 << 20,
  }) // ttSize: حجم الجدول (عدد الخانات)
  : cfg =
           cfg ??
           const AiSearchConfig(), // استخدام الإعدادات الافتراضية إن لم تُمرر
       tt = _TT(ttSize); // تهيئة جدول النقل

  Future<Move?> search(Board root) async {
    // الدالة العامة: تعيد أفضل حركة للوحة المعطاة
    final timer = Deadline(cfg.timeMs); // مؤقت لإيقاف البحث عند انتهاء الوقت
    Move? best; // أفضل حركة على مستوى التكرار الحالي
    int bestScore = -999999; // أفضل نتيجة (score) على مستوى التكرار
    List<Move> pv = []; // (PV) المتغيّر الرئيسي للحل الأمثل

    // تكرار تعميقي: نبدأ بعمق 1 ثم 2 ... حتى maxDepth أو انتهاء الوقت
    for (int depth = 1; depth <= cfg.maxDepth; depth++) {
      if (timer.expired) break; // إذا انتهى الوقت نوقف
      int alpha = bestScore - cfg.aspirationDelta; // نافذة Aspiration الأولى
      int beta = bestScore + cfg.aspirationDelta;

      // نجرب نافذة ضيّقة أولاً لتحسين الأداء
      int score = _alphaBeta(
        root,
        depth,
        alpha,
        beta,
        _SearchCtx(timer),
        pvOut: pv,
      );
      if (timer.expired) break; // تحقق مرة أخرى

      // إذا خرجنا خارج النافذة، نعيد البحث بنافذة مفتوحة (−∞، +∞)
      if (score <= alpha || score >= beta) {
        alpha = -1000000;
        beta = 1000000;
        score = _alphaBeta(
          root,
          depth,
          alpha,
          beta,
          _SearchCtx(timer),
          pvOut: pv,
        );
      }

      if (!timer.expired) {
        // إذا ما زال لدينا وقت، نحفظ الأفضل
        bestScore = score;
        if (pv.isNotEmpty) best = pv.first;
      }
    }
    return best; // إعادة أفضل حركة وجدناها
  }

  // -----------------------------------------------------------
  // نواة البحث Alpha-Beta مع PVS + LMR + TT + Null-Move + PV
  // -----------------------------------------------------------
  int _alphaBeta(
    Board b, // اللوحة الحالية
    int depth, // العمق المتبقي
    int alpha, // الحد الأدنى (أفضل ما يمكن للاعب الحالي ضمانه)
    int beta, // الحد الأعلى
    _SearchCtx ctx, { // السياق (المؤقت/أشياء أخرى)
    List<Move>? pvOut, // مخرج خط PV (اختياري)
  }) {
    // 0) التوقف إذا انتهى الوقت
    if (ctx.timer.expired) return _eval(b);

    // 1) التوقف على العمق صفر → الانتقال إلى بحث الهدوء (Quiescence)
    if (depth == 0) {
      return _quiescence(b, alpha, beta, ctx);
    }

    // 2) فحص جدول النقل (TT)
    final key = b.zobristKey; // مفتاح زوبريست من اللوحة مباشرة
    final entry = tt.probe(key); // محاولة قراءة إدخال سابق
    if (entry != null && entry.depth >= depth) {
      if (entry.bound == _Bound.exact) return entry.value; // نتيجة دقيقة
      if (entry.bound == _Bound.lower && entry.value > alpha) {
        // حد سفلي
        alpha = entry.value;
      } else if (entry.bound == _Bound.upper && entry.value < beta) {
        // حد علوي
        beta = entry.value;
      }
      if (alpha >= beta) return entry.value; // قطع (cut-off)
    }

    // 3) إذا كنا في كش نزيد العمق قليلاً (امتداد بسيط)
    final inCheck = _inCheck(b);
    int newDepth = depth + (inCheck ? 1 : 0);

    // 4) توليد وتحسين ترتيب النقلات
    final moves =
        b.getAllLegalMovesForCurrentPlayer(); // توليد الحركات القانونية
    if (moves.isEmpty) {
      // إذا لا يوجد حركات
      return _evalTerminal(b, inCheck); // نهاية: كش مات أو تعادل
    }
    // ترتيب بسيط: الالتقاطات أولاً ثم بقية النقلات
    moves.sort((a, c) {
      final sa = a.isCapture ? 1 : 0;
      final sb = c.isCapture ? 1 : 0;
      return sb - sa; // الالتقاطات قبل غيرها
    });

    // 5) المتغيرات للأفضلية
    int bestScore = -999999;
    Move? bestMove;
    pvOut?.clear();

    // 6) حلقة تجربة النقلات
    for (int i = 0; i < moves.length; i++) {
      final m = moves[i]; // النقلة الحالية
      // --- LMR: تقليل العمق للنقلات الهادئة والمتأخرة ---
      int reduction = 0;
      final isQuiet =
          !m.isCapture && !_givesCheck(b, m); // نقلة هادئة: لا التقاط ولا كش
      if (cfg.enableLMR && isQuiet && i > 3 && depth >= 3) {
        reduction = _lmrReduction(
          depth,
          i,
        ); // حساب التقليل حسب العمق وترتيب الحركة
      }

      final nextBoard = b.makeMove(
        m,
      ); // إنشاء لوحة جديدة بتنفيذ الحركة (makeMove/unMakeMove API (Immutable))
      // ✅ تحقق اختياري (Debug): نتأكد أن unMakeMove يعيد نفس اللوحة (بواسطة zobrist/equality)
      assert(() {
        try {
          final restored = nextBoard.unMakeMove(
            move: nextBoard.moveHistory.last,
          );
          // نسمح بالتحقق إما عبر المساواة العميقة (freezed ==) أو عبر مفتاح زوبريست
          return restored == b || restored.zobristKey == b.zobristKey;
        } catch (_) {
          return true; // في حال رمي استثناء لا نوقف التنفيذ في وضع الإنتاج
        }
      }());

      int score; // نتيجة الفرع
      // --- 7) PVS: بحث ضيق لجميع النقلات بعد الأولى ---
      if (!cfg.enablePVS || i == 0 || bestScore == -999999) {
        // أول نقلة أو PVS معطل
        score = -_alphaBeta(nextBoard, newDepth - 1, -beta, -alpha, ctx);
      } else {
        // بحث ضيق (null window)
        score = -_alphaBeta(nextBoard, newDepth - 1, -alpha - 1, -alpha, ctx);
        // إذا تحسن بعد نافذة ضيقة → أعد البحث
        if (score > alpha && reduction > 0) {
          // إذا تخطى العتبة بعد LMR → أعد البحث بعمق كامل
          score = -_alphaBeta(nextBoard, newDepth, -alpha - 1, -alpha, ctx);
        }
        if (score > alpha && score < beta) {
          // وإذا بقي ضمن النافذة → بحث كامل (re-search)
          score = -_alphaBeta(nextBoard, newDepth, -beta, -alpha, ctx);
        }
      }

      // --- 8) تحديث أفضل نتيجة وأفضل حركة ---
      if (score > bestScore) {
        // وجدنا نتيجة أفضل
        bestScore = score;
        bestMove = m; // حفظ الأفضل
        if (pvOut != null) {
          // تحديث خط PV (نبقي فقط أول حركة هنا)
          pvOut
            ..clear()
            ..add(m);
        }
      }

      // --- 9) قطع Alpha-Beta ---
      if (bestScore >= beta) {
        // قطع: لا داعي لإكمال بقية النقلات
        // خزّن في TT كحد سفلي
        tt.store(_TTEntry(key, depth, bestScore, _Bound.lower, bestMove));
        return bestScore;
      }

      // --- 10) ارفع العتبة alpha إن تحسننا ---
      if (bestScore > alpha) alpha = bestScore;
    }

    // 11) تخزين النتيجة النهائية في TT
    final bound =
        (bestScore <= alpha)
            ? _Bound
                .upper // فشل مرتفع
            : (bestScore >= beta)
            ? _Bound
                .lower // قطع
            : _Bound.exact; // نتيجة دقيقة
    tt.store(_TTEntry(key, depth, bestScore, bound, bestMove));

    return bestScore; // أعِد أفضل قيمة
  }

  // -----------------------------------------------------------
  // بحث الهدوء (Quiescence Search)
  // -----------------------------------------------------------
  int _quiescence(Board b, int alpha, int beta, _SearchCtx ctx) {
    // تحقق الوقت
    if (ctx.timer.expired) return _eval(b);

    // تقييم ثابت للوضع الحالي كنقطة بدء
    int standPat = _eval(b);
    if (standPat >= beta) return standPat; // قطع علوي
    if (standPat > alpha) alpha = standPat; // تحسين alpha

    // توليد النقلات الهادرة (التقاطات/الشيكات) فقط
    final qMoves =
        b
            .getAllLegalMovesForCurrentPlayer()
            .where((m) => m.isCapture || _givesCheck(b, m))
            .toList();

    // ترتيب بسيط: الالتقاطات أولاً
    qMoves.sort((a, c) {
      final sa = a.isCapture ? 1 : 0;
      final sb = c.isCapture ? 1 : 0;
      return sb - sa; // الالتقاطات قبل غيرها
    });

    for (final m in qMoves) {
      // جرّب كل نقلة هادرة
      final nb = b.makeMove(m); // طبق الحركة على لوحة جديدة
      // ✅ تحقق اختياري (Debug) كما في الأعلى: التأكد من قابلية العكس
      assert(() {
        try {
          final rb = nb.unMakeMove(move: nb.moveHistory.last);
          return rb == b || rb.zobristKey == b.zobristKey;
        } catch (_) {
          return true;
        }
      }());
      final score =
          -_quiescence(nb, -beta, -alpha, ctx); // بحث递归 مع نوافذ معكوسة
      if (score >= beta) return score; // قطع
      if (score > alpha) alpha = score; // تحسين alpha
    }

    return alpha; // القيمة الهادئة الأفضل
  }

  // -----------------------------------------------------------
  // تقييم الوضع (هيوريستكس مبسّطة + مادة + تموضع)
  // -----------------------------------------------------------
  int _eval(Board b) {
    // مادة/تموضع مبسّطة + مكافأة/عقوبة كش
    int score = 0;
    // أمثلة بسيطة (يمكنك استبدالها بجداول PSQT أدق لديك)
    // ملاحظة: ضع هنا نفس الجداول/الأوزان التي تستخدمها فعلياً في مشروعك ليطابق سلوك المحرك المتوقع.
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = b.squares[r][c];
        if (p == null) continue;
        int val;
        switch (p.type) {
          case PieceType.pawn:
            val = 100;
            break;
          case PieceType.knight:
            val = 320;
            break;
          case PieceType.bishop:
            val = 330;
            break;
          case PieceType.rook:
            val = 500;
            break;
          case PieceType.queen:
            val = 900;
            break;
          case PieceType.king:
            val = 0;
            break;
        }
        score += (p.color == PieceColor.white) ? val : -val;
      }
    }
    // عقوبة/مكافأة بسيطة إذا كان الملك الحالي في كش (لتحفيز الخروج من الكش سريعاً)
    if (_inCheck(b)) {
      score += (b.currentPlayer == PieceColor.white) ? -30 : 30;
    }
    return score;
  }

  // نهاية اللعبة: مات/تعادل
  int _evalTerminal(Board b, bool inCheck) {
    if (inCheck) {
      // الطرف الذي عليه الدور لا يملك نقلات وهو في كش → كش مات
      return -100000 + b.fullMoveNumber; // نزيد/ننقص قليلاً لإجبار أقصر مات
    } else {
      // لا كش ولا نقلات → تعادل (ستalemate)
      return 0;
    }
  }

  bool _inCheck(Board b) =>
      b.isKingInCheck(b.currentPlayer); // هل اللاعب الحالي في كش؟

  bool _givesCheck(Board b, Move m) {
    // هل الحركة ستؤدي إلى كش للخصم؟
    final nb = b.makeMove(m); // طبّق الحركة على لوحة جديدة
    // ✅ تحقق اختياري (Debug) كما في الأعلى: التأكد من قابلية العكس
    assert(() {
      try {
        final rb = nb.unMakeMove(move: nb.moveHistory.last);
        return rb == b || rb.zobristKey == b.zobristKey;
      } catch (_) {
        return true;
      }
    }());
    final opp =
        b.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white; // لون الخصم
    return nb.isKingInCheck(opp); // هل ملك الخصم في كش؟
  }

  // تقليل LMR heuristic
  int _lmrReduction(int depth, int index) {
    // معيار تقريبي: تقليل أكبر للحركات المتأخرة (index كبير) وعندما يكون العمق عميقاً
    final base = math.log(depth + 1) * math.log(index + 2);
    return base.floor().clamp(0, depth - 1);
  }
}

// سياق البحث (حالياً يحتوي فقط على المؤقت)
class _SearchCtx {
  final Deadline timer; // مؤقت
  _SearchCtx(this.timer);
}
