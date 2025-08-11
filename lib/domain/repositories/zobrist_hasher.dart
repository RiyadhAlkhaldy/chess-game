import 'dart:math';

import '../entities/board.dart';
import '../entities/piece.dart'; // تأكد أن لديك enum PieceType و PieceColor

class ZobristHasher {
  static const int boardSize = 8;

  /// قائمة عشوائية تمثل [اللون][نوع القطعة][الصف][العمود]
  static late List<List<List<List<int>>>> zobristTable;
  // final Map<CastlingSide, Map<PieceColor, int>> _zobristCastlingKeys = {};
  // final Map<int, int> _zobristEnPassantKeys = {}; // 8 قيم لـ a-h
  // final Map<PieceColor, int> _zobristSideToMoveKeys = {};
  // final Map<PieceType, Map<PieceColor, List<List<int>>>> _zobristPieceKeys = {};

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
  int computeHash(Board board, bool isWhiteToMove) {
    final List<List<Piece?>> squares = board.squares;
    int hash = 0;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        Piece? piece = squares[row][col];
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
    // int hash = 0;

    // // 1. القطع في المربعات
    // for (int r = 0; r < 8; r++) {
    //   for (int c = 0; c < 8; c++) {
    //     final piece = board.squares[r][c];
    //     if (piece != null) {
    //       hash ^= _zobristPieceKeys[piece.type]![piece.color]![r][c];
    //     }
    //   }
    // }

    // // 2. الدور
    // hash ^= _zobristSideToMoveKeys[board.currentPlayer]!;

    // // 3. حقوق التبييت
    // if (board.castlingRights[PieceColor.white]![CastlingSide.kingSide]!) {
    //   hash ^= _zobristCastlingKeys[CastlingSide.kingSide]![PieceColor.white]!;
    // }
    // if (board.castlingRights[PieceColor.white]![CastlingSide.queenSide]!) {
    //   hash ^= _zobristCastlingKeys[CastlingSide.queenSide]![PieceColor.white]!;
    // }
    // if (board.castlingRights[PieceColor.black]![CastlingSide.kingSide]!) {
    //   hash ^= _zobristCastlingKeys[CastlingSide.kingSide]![PieceColor.black]!;
    // }
    // if (board.castlingRights[PieceColor.black]![CastlingSide.queenSide]!) {
    //   hash ^= _zobristCastlingKeys[CastlingSide.queenSide]![PieceColor.black]!;
    // }

    // ///
    // // 4. هدف الأسر بالمرور
    // if (board.enPassantTarget != null) {
    //   hash ^= _zobristEnPassantKeys[board.enPassantTarget!.col]!;
    // }

    return hash;
  }

  /// تحويل نوع القطعة إلى index داخل الجدول

  int _pieceToIndex(Piece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return 0;
      case PieceType.knight:
        return 1;
      case PieceType.bishop:
        return 2;
      case PieceType.rook:
        return 3;
      case PieceType.queen:
        return 4;
      case PieceType.king:
        return 5;
    }
  }
}
