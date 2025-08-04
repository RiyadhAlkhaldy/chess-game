import 'dart:math';

import '../entities/piece.dart'; // تأكد أن لديك enum PieceType و PieceColor

class ZobristHasher {
  static const int boardSize = 8;

  /// قائمة عشوائية تمثل [اللون][نوع القطعة][الصف][العمود]
  late List<List<List<List<int>>>> zobristTable;

  /// مفتاح للون اللاعب الذي يلعب الآن
  late int sideToMoveKey;

  final Random random;

  ZobristHasher({int? seed}) : random = Random(seed) {
    // تهيئة جدول zobrist بـ أرقام عشوائية
    zobristTable = List.generate(
      2,
      (color) => // white / black
          List.generate(
        6,
        (pieceType) => // pawn, knight, bishop, rook, queen, king
            List.generate(
          boardSize,
          (row) => List.generate(boardSize, (col) => _random64Bit()),
        ),
      ),
    );

    sideToMoveKey = _random64Bit();
  }

  /// توليد رقم عشوائي مكون من 64 بت
  int _random64Bit() {
    return random.nextInt(1 << 32) ^ random.nextInt(1 << 32);
  }

  /// حساب zobrist key لأي لوحة
  int computeHash(List<List<Piece?>> board, bool isWhiteToMove) {
    int hash = 0;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        Piece? piece = board[row][col];
        if (piece != null) {
          int colorIndex = piece.color == PieceColor.white ? 0 : 1;
          int typeIndex = _pieceToIndex(piece);
          hash ^= zobristTable[colorIndex][typeIndex][row][col];
        }
      }
    }

    if (!isWhiteToMove) {
      hash ^= sideToMoveKey;
    }

    return hash;
  }

  /// تحويل نوع القطعة إلى index داخل الجدول

  int _pieceToIndex(Piece piece) {
    // String type = piece.type.toLowerCase(); // king, queen, rook...
    PieceColor color = piece.color; // white or black

    switch (piece.type) {
      case PieceType.pawn:
        return color == PieceColor.white ? 0 : 1;
      case PieceType.knight:
        return color == PieceColor.white ? 2 : 3;
      case PieceType.bishop:
        return color == PieceColor.white ? 4 : 5;
      case PieceType.rook:
        return color == PieceColor.white ? 6 : 7;
      case PieceType.queen:
        return color == PieceColor.white ? 8 : 9;
      case PieceType.king:
        return color == PieceColor.white ? 10 : 11;
    }
  }
}
