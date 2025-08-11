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

  bool zobristKeysInitialized = false;

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
    Piece? piece = board.getPieceAt(move.start)!;

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
}
