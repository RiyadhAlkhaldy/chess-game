import 'dart:math';

import '../entities/export.dart';

class ZobristHashing {
  static final Map<int, TranspositionEntry> transpositionTable = {};

  /// قائمة عشوائية تمثل [اللون][نوع القطعة][الصف][العمود]
  //  late List<List<List<List<int>>>> zobristTable;
  // جداول Zobrist Hashing
  // يتم تهيئتها مرة واحدة فقط عند بدء التطبيق أو إنشاء الـ repository.
  static final Map<PieceType, Map<PieceColor, List<List<int>>>>
  _zobristPieceKeys = {};

  static final Map<PieceColor, int> _zobristSideToMoveKeys = {};
  static final Map<PieceColor, Map<CastlingSide, int>> _zobristCastlingKeys =
      {};

  static final Map<int, int> _zobristEnPassantKeys = {}; // 8 قيم لـ a-h

  static bool zobristKeysInitialized = false;

  // initialize zobrist
  static void initializeZobristKeys() {
    Random random = Random(1 << 64); // استخدام seed ثابت لأغراض الاختبار
    // تهيئة جدول zobrist بـ أرقام عشوائية

    // مفاتيح القطع والمربعات
    for (var type in PieceType.values) {
      _zobristPieceKeys[type] = {};
      for (var color in PieceColor.values) {
        _zobristPieceKeys[type]![color] = List.generate(
          8,
          (_) => List.generate(8, (_) => random.nextInt(0xFFFFFFFF)),
        );
      }
    }

    // مفاتيح الدور (للاعب الأبيض والأسود)
    _zobristSideToMoveKeys[PieceColor.white] = random.nextInt(0xFFFFFFFF);
    _zobristSideToMoveKeys[PieceColor.black] = random.nextInt(0xFFFFFFFF);

    // مفاتيح حقوق التبييت
    _zobristCastlingKeys[PieceColor.white] = {
      CastlingSide.kingSide: random.nextInt(0xFFFFFFFF),
      CastlingSide.queenSide: random.nextInt(0xFFFFFFFF),
    };
    _zobristCastlingKeys[PieceColor.black] = {
      CastlingSide.kingSide: random.nextInt(0xFFFFFFFF),
      CastlingSide.queenSide: random.nextInt(0xFFFFFFFF),
    };

    // مفاتيح الأسر بالمرور (لـ 8 أعمدة)
    for (int col = 0; col < 8; col++) {
      _zobristEnPassantKeys[col] = random.nextInt(0xFFFFFFFF);
    }
  }

  /// يحسب مفتاح Zobrist لموقف اللوحة الحالي.
  static int calculateZobristKey(Board board) {
    int hash = 0;

    // 1. القطع في المربعات
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          hash ^= _zobristPieceKeys[piece.type]![piece.color]![r][c];
        }
      }
    }

    // 2. الدور
    hash ^= _zobristSideToMoveKeys[board.currentPlayer]!;

    // 3. حقوق التبييت
    if (board.castlingRights[PieceColor.white]![CastlingSide.kingSide]!) {
      hash ^= _zobristCastlingKeys[PieceColor.white]![CastlingSide.kingSide]!;
    }
    if (board.castlingRights[PieceColor.white]![CastlingSide.queenSide]!) {
      hash ^= _zobristCastlingKeys[PieceColor.white]![CastlingSide.queenSide]!;
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.kingSide]!) {
      hash ^= _zobristCastlingKeys[PieceColor.black]![CastlingSide.kingSide]!;
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.queenSide]!) {
      hash ^= _zobristCastlingKeys[PieceColor.black]![CastlingSide.queenSide]!;
    }

    ///
    // 4. هدف الأسر بالمرور
    if (board.enPassantTarget != null) {
      hash ^= _zobristEnPassantKeys[board.enPassantTarget!.col]!;
    }

    return hash;
  }

  static int updateZobristKeyAfterMove(Board board, Move move) {
    int hash = board.zobristKey;
    Piece? piece = board.getPieceAt(move.start);
    if (piece == null) {
      // return 0; // أو يمكنك التعامل مع الخطأ بطريقة أخرى
      throw ArgumentError('No piece at start position ${move.start}');
    }
    hash ^=
        _zobristPieceKeys[piece.type]![piece.color]![move.start.row][move
            .start
            .col];
    hash ^=
        _zobristPieceKeys[piece.type]![piece.color]![move.end.row][move
            .end
            .col];
    // الدور
    hash ^= _zobristSideToMoveKeys[board.currentPlayer]!;
    // تحديث حقوق التبييت
    if (move.isCastling) {
      if (piece.color == PieceColor.white) {
        if (move.end.col == 6) {
          // تبييت الملكي
          hash ^=
              _zobristCastlingKeys[PieceColor.white]![CastlingSide.kingSide]!;
        } else if (move.end.col == 2) {
          // تبييت الملكي
          hash ^=
              _zobristCastlingKeys[PieceColor.white]![CastlingSide.queenSide]!;
        }
      } else {
        if (move.end.col == 6) {
          // تبييت الملكي
          hash ^=
              _zobristCastlingKeys[PieceColor.black]![CastlingSide.kingSide]!;
        } else if (move.end.col == 2) {
          // تبييت الملكي
          hash ^=
              _zobristCastlingKeys[PieceColor.black]![CastlingSide.queenSide]!;
        }
      }
    }

    // 4. هدف الأسر بالمرور
    if (move.isEnPassant) {
      hash ^= _zobristEnPassantKeys[move.end.col]!;
    }

    return hash;
  }

  void storeTT(int hash, TranspositionEntry entry) {
    transpositionTable[hash] = entry;
  }

  TranspositionEntry? probeTT(int hash, int depth) {
    final entry = transpositionTable[hash];
    if (entry != null && entry.depth >= depth) {
      return entry;
    }
    return null;
  }

  // ==== دوال مساعدة عامة لتحديث Zobrist تفاضلياً ====
  // ملاحظة: هذه الدوال لا تغيّر أي حالة داخلية، فقط تعيد hash جديد بعد XORs.

  /// XOR على خانة قطعة (إضافة/إزالة لنفس المفتاح هي نفسها)
  static int togglePieceSquare(
    int hash,
    PieceType type,
    PieceColor color,
    int row,
    int col,
  ) {
    return hash ^ _zobristPieceKeys[type]![color]![row][col];
  }

  /// تبديل دور اللعب: XOR بمفتاح اللاعب السابق ثم اللاعب اللاحق
  static int toggleSideToMove(int hash, {required PieceColor from}) {
    final to = (from == PieceColor.white) ? PieceColor.black : PieceColor.white;
    hash ^= _zobristSideToMoveKeys[from]!;
    hash ^= _zobristSideToMoveKeys[to]!;
    return hash;
  }

  /// ضبط خانة En Passant: أزل القديم (إن وجد) وأضف الجديد (إن وجد)
  static int setEnPassantFile(int hash, {int? prevFile, int? newFile}) {
    if (prevFile != null) {
      hash ^= _zobristEnPassantKeys[prevFile]!;
    }
    if (newFile != null) {
      hash ^= _zobristEnPassantKeys[newFile]!;
    }
    return hash;
  }

  /// ضبط حق تبييت واحد: إذا تغيّر من prev إلى next نعمل XOR على مفتاح ذلك الحق.
  static int setCastlingRight(
    int hash, {
    required PieceColor color,
    required CastlingSide side,
    required bool prev,
    required bool next,
  }) {
    if (prev != next) {
      hash ^= _zobristCastlingKeys[color]![side]!;
    }
    return hash;
  }
}
