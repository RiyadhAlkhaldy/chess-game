// lib/data/engine/engine_board.dart
//
// نسخة Mutable من اللوحة مخصصة لمحرك البحث لاستخدام make/unmake.
// - أداء أعلى بكثير من النسخ (copyWith/simulateMove)
// - تدعم: Castling, En Passant, Promotion
// - Zobrist Hashing محدث تفاضلياً (XOR)
// - Stack داخلي لتخزين الحالة وإرجاعها بـ O(1)
//
// طريقة الاستخدام مع المحرك:
//   final eb = EngineBoard.fromBoard(boardImmutable);
//   final best = await AiEngine().search(eb); // المحرك سيستدعي make/unmake
//
// عند انتهاء البحث، يمكنك تحويلها مرة أخرى لـ Board (إن احتجت):
//   final newBoard = eb.toBoard();

import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/cell.dart';
import 'package:chess_gemini_2/domain/entities/move.dart';
import 'package:chess_gemini_2/domain/entities/piece.dart';
import 'package:chess_gemini_2/domain/repositories/zobrist_hashing.dart';

class Undo {
  // الحالة السابقة اللازمة لإرجاع الحركة
  final Move move;
  final Piece? captured;
  final Piece movedBefore; // نسخة القطعة قبل الحركة (للـ hasMoved الخ..)
   Piece? rookBefore; // للـ castling عند تحريك الرخ
   Cell? rookFrom, rookTo; // مسار الرخ في التبييت
  final Map<PieceColor, Map<CastlingSide, bool>> castlingBefore;
  final Map<PieceColor, Cell> kingsBefore;
  final Cell? enPassantBefore;
  final int halfMoveBefore;
  final int fullMoveBefore;
  final int zobristBefore;

  Undo({
    required this.move,
    required this.captured,
    required this.movedBefore,
    required this.rookBefore,
    required this.rookFrom,
    required this.rookTo,
    required this.castlingBefore,
    required this.kingsBefore,
    required this.enPassantBefore,
    required this.halfMoveBefore,
    required this.fullMoveBefore,
    required this.zobristBefore,
  });
}

/// لوحة متحوّلة للمحرّك (لا Freezed هنا).
class EngineBoard {
  // مصفوفة 8x8 قابلة للتعديل
  final List<List<Piece?>> squares;
  // اللاعب على الدور
  PieceColor currentPlayer;
  // مواقع الملوك
  final Map<PieceColor, Cell> kingPositions;
  // حقوق التبييت
  final Map<PieceColor, Map<CastlingSide, bool>> castlingRights;
  // خانة الـ En Passant (إن وجدت)
  Cell? enPassantTarget;
  // عدّاد أنصاف النقلات (قاعدة الـ 50 نقلة)
  int halfMoveClock;
  // رقم النقلة الكاملة (يزيد بعد نقل الأسود)
  int fullMoveNumber;
  // مفتاح زوبريست الحالي
  int zobristKey;

  // مكدّس الاسترجاع
  final List<Undo> stack = [];

  // ---- الإنشاء من Board (Immutable) ----
  EngineBoard._internal({
    required this.squares,
    required this.currentPlayer,
    required this.kingPositions,
    required this.castlingRights,
    required this.enPassantTarget,
    required this.halfMoveClock,
    required this.fullMoveNumber,
    required this.zobristKey,
  });

  factory EngineBoard.fromBoard(Board b) {
    // ننسخ المصفوفة بمراجع جديدة (قطع نفسها تُستخدم كما هي حتى تتغيّر)
    final sq = List<List<Piece?>>.generate(
      8,
      (r) => List<Piece?>.from(b.squares[r]),
      growable: false,
    );
    final kings = {
      PieceColor.white: b.kingPositions[PieceColor.white]!,
      PieceColor.black: b.kingPositions[PieceColor.black]!,
    };
    final cr = {
      PieceColor.white: {
        CastlingSide.kingSide:
            b.castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
        CastlingSide.queenSide:
            b.castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
      },
      PieceColor.black: {
        CastlingSide.kingSide:
            b.castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
        CastlingSide.queenSide:
            b.castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
      },
    };
    final eb = EngineBoard._internal(
      squares: sq,
      currentPlayer: b.currentPlayer,
      kingPositions: kings,
      castlingRights: cr,
      enPassantTarget: b.enPassantTarget,
      halfMoveClock: b.halfMoveClock,
      fullMoveNumber: b.fullMoveNumber,
      zobristKey:
          b.zobristKey != 0
              ? b.zobristKey
              : ZobristHashing.calculateZobristKey(b),
    );
    return eb;
  }

  // تحويل لـ Board (للواجهات/التخزين بعد انتهاء البحث)
  Board toBoard() {
    return Board(
      squares:
          squares
              .map(
                (row) =>
                    row.map((p) => p == null ? null : p.copyWith()).toList(),
              )
              .toList(),
      moveHistory: const [], // المحرك عادة لا يملأ التاريخ
      redoStack: const [],
      currentPlayer: currentPlayer,
      kingPositions: {
        PieceColor.white: kingPositions[PieceColor.white]!,
        PieceColor.black: kingPositions[PieceColor.black]!,
      },
      castlingRights: {
        PieceColor.white: {
          CastlingSide.kingSide:
              castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
        },
        PieceColor.black: {
          CastlingSide.kingSide:
              castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
        },
      },
      enPassantTarget: enPassantTarget,
      halfMoveClock: halfMoveClock,
      fullMoveNumber: fullMoveNumber,
      positionHistory: const [],
      zobristKey: zobristKey,
    );
  }

  // مساعد سريع
  Piece? pieceAt(Cell c) => squares[c.row][c.col];
  void _set(Cell c, Piece? p) => squares[c.row][c.col] = p;

  bool isKingInCheck(PieceColor side) {
    // استدعِ من كودك الحالي لو أردت أدق (هنا أبقيها كما في Board)
    return toBoard().isKingInCheck(side);
  }

  // --- makeMove: ينفّذ الحركة على نفس الكائن ويحدّث Zobrist/الحقوق ---
  void makeMove(Move m) {
    final start = m.start;
    final end = m.end;

    final moving = pieceAt(start);
    if (moving == null) {
      throw StateError('لا توجد قطعة في خانة البداية: $start');
    }

    // خزّن الحالة السابقة (للاسترجاع الفوري)
    final undo = Undo(
      move: m,
      captured:
          m.isEnPassant
              ? squares[start.row][end
                  .col] // البيدق المأسور يكون خلف خانة النهاية
              : pieceAt(end),
      movedBefore: moving,
      rookBefore: null,
      rookFrom: null,
      rookTo: null,
      castlingBefore: {
        PieceColor.white: {
          CastlingSide.kingSide:
              castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
        },
        PieceColor.black: {
          CastlingSide.kingSide:
              castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
          CastlingSide.queenSide:
              castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
        },
      },
      kingsBefore: {
        PieceColor.white: kingPositions[PieceColor.white]!,
        PieceColor.black: kingPositions[PieceColor.black]!,
      },
      enPassantBefore: enPassantTarget,
      halfMoveBefore: halfMoveClock,
      fullMoveBefore: fullMoveNumber,
      zobristBefore: zobristKey,
    );

    // 1) أزِل EP السابق من الهاش (إن وجد)
    zobristKey = ZobristHashing.setEnPassantFile(
      zobristKey,
      prevFile: enPassantTarget?.col,
      newFile: null,
    );
    enPassantTarget = null; // سيتم ضبطه لاحقاً إن كانت نقلة بيدق خطوتين

    // 2) تحديث halfmove/fullmove
    if (moving.type == PieceType.pawn || undo.captured != null) {
      halfMoveClock = 0;
    } else {
      halfMoveClock += 1;
    }
    if (currentPlayer == PieceColor.black) {
      // بعد نقل الأسود نزيد رقم النقلة
      fullMoveNumber += 1;
    }

    // 3) تعامل مع الأسر (بما فيها En Passant) وتحديث Zobrist للقطعة المأسورة
    if (m.isEnPassant) {
      final capCell = Cell(row: start.row, col: end.col);
      final capPiece = squares[capCell.row][capCell.col];
      if (capPiece != null) {
        // XOR للقطعة المأسورة من مربعها
        zobristKey = ZobristHashing.togglePieceSquare(
          zobristKey,
          capPiece.type,
          capPiece.color,
          capCell.row,
          capCell.col,
        );
      }
      _set(capCell, null);
    } else if (undo.captured != null) {
      // XOR للقطعة المأسورة (كانت على end)
      zobristKey = ZobristHashing.togglePieceSquare(
        zobristKey,
        undo.captured!.type,
        undo.captured!.color,
        end.row,
        end.col,
      );
    }

    // 4) انقل القطعة (XOR: ارفع من start ثم ضع على end)
    // ارفع من start
    zobristKey = ZobristHashing.togglePieceSquare(
      zobristKey,
      moving.type,
      moving.color,
      start.row,
      start.col,
    );
    _set(start, null);

    Piece placed = moving;
    // ضع على end (مع hasMoved=true)
    placed = placed.copyWith(hasMoved: true);
    // معالجة الترقية
    if (m.isPromotion) {
      // NOTE: غيّر اسم الحقل إن كان مختلفاً: m.promotionType
      final promoType = m.promotedPieceType ?? PieceType.queen;
      // لا نضيف XOR للـ pawn هنا لأنه رُفع سابقاً من start. سنضيف القطعة الجديدة فقط.
      placed = Piece.create(
        color: moving.color,
        type: promoType,
        hasMoved: true,
      );
    }

    // XOR للقطعة الموضوعة على end
    zobristKey = ZobristHashing.togglePieceSquare(
      zobristKey,
      placed.type,
      placed.color,
      end.row,
      end.col,
    );
    _set(end, placed);

    // 5) تحدّث مواقع الملوك وحقوق التبييت
    if (moving.type == PieceType.king) {
      kingPositions[moving.color] = end;
      // فقدان حقوق التبييت لكلا الجانبين لهذا اللون
      _revokeCastlingIfTrue(moving.color, CastlingSide.kingSide);
      _revokeCastlingIfTrue(moving.color, CastlingSide.queenSide);

      // إذا كانت النقلة تبييت.. حرّك الرخ كذلك
      if (m.isCastling) {
        final isKingSide = end.col == 6; // (E->G) أي 4->6
        final rookFrom =
            isKingSide
                ? Cell(row: end.row, col: 7)
                : Cell(row: end.row, col: 0);
        final rookTo =
            isKingSide
                ? Cell(row: end.row, col: 5)
                : Cell(row: end.row, col: 3);

        final rook = squares[rookFrom.row][rookFrom.col];
        if (rook != null && rook.type == PieceType.rook) {
          // خزّن قبل التغيير
          undo.rookBefore = rook;
          undo.rookFrom = rookFrom;
          undo.rookTo = rookTo;

          // XOR: ارفع الرخ من rookFrom
          zobristKey = ZobristHashing.togglePieceSquare(
            zobristKey,
            rook.type,
            rook.color,
            rookFrom.row,
            rookFrom.col,
          );
          _set(rookFrom, null);

          final rookPlaced = rook.copyWith(hasMoved: true);
          // XOR: ضع الرخ في rookTo
          zobristKey = ZobristHashing.togglePieceSquare(
            zobristKey,
            rookPlaced.type,
            rookPlaced.color,
            rookTo.row,
            rookTo.col,
          );
          _set(rookTo, rookPlaced);
        }
      }
    }

    // فقدان حقوق التبييت عندما يتحرّك الرخ من مواضع البداية
    if (moving.type == PieceType.rook) {
      if (moving.color == PieceColor.white) {
        if (start.row == 7 && start.col == 0) {
          _revokeCastlingIfTrue(PieceColor.white, CastlingSide.queenSide);
        } else if (start.row == 7 && start.col == 7) {
          _revokeCastlingIfTrue(PieceColor.white, CastlingSide.kingSide);
        }
      } else {
        if (start.row == 0 && start.col == 0) {
          _revokeCastlingIfTrue(PieceColor.black, CastlingSide.queenSide);
        } else if (start.row == 0 && start.col == 7) {
          _revokeCastlingIfTrue(PieceColor.black, CastlingSide.kingSide);
        }
      }
    }

    // فقدان حقوق التبييت عندما يُؤسَر رخ من خانة البداية
    if (undo.captured != null && undo.captured!.type == PieceType.rook) {
      final capCell = m.isEnPassant ? Cell(row: start.row, col: end.col) : end;
      if (capCell.row == 7 && capCell.col == 0) {
        _revokeCastlingIfTrue(PieceColor.white, CastlingSide.queenSide);
      } else if (capCell.row == 7 && capCell.col == 7) {
        _revokeCastlingIfTrue(PieceColor.white, CastlingSide.kingSide);
      } else if (capCell.row == 0 && capCell.col == 0) {
        _revokeCastlingIfTrue(PieceColor.black, CastlingSide.queenSide);
      } else if (capCell.row == 0 && capCell.col == 7) {
        _revokeCastlingIfTrue(PieceColor.black, CastlingSide.kingSide);
      }
    }

    // 6) ضبط En Passant الجديد (لو بيدق تحرّك خطوتين)
    if (moving.type == PieceType.pawn && (start.row - end.row).abs() == 2) {
      final epRow = (start.row + end.row) ~/ 2;
      enPassantTarget = Cell(row: epRow, col: start.col);
      // أضف EP الجديد للهاش
      zobristKey = ZobristHashing.setEnPassantFile(
        zobristKey,
        prevFile: null,
        newFile: enPassantTarget!.col,
      );
    }

    // 7) غيّر الدور في الهاش واللعبة
    zobristKey = ZobristHashing.toggleSideToMove(
      zobristKey,
      from: currentPlayer,
    );
    currentPlayer =
        (currentPlayer == PieceColor.white)
            ? PieceColor.black
            : PieceColor.white;

    // ادفع الـ undo
    stack.add(undo);
  }

  // --- unmakeMove: يرجع آخر نقلة ويستعيد كل شيء بما فيها Zobrist ---
  void unmakeMove() {
    if (stack.isEmpty) {
      throw StateError('لا توجد حركة لإرجاعها');
    }
    final u = stack.removeLast();
    final m = u.move;
    final start = m.start;
    final end = m.end;

    // استعد الحقول البسيطة أولاً
    currentPlayer =
        (currentPlayer == PieceColor.white)
            ? PieceColor.black
            : PieceColor.white;
    enPassantTarget = u.enPassantBefore;
    halfMoveClock = u.halfMoveBefore;
    fullMoveNumber = u.fullMoveBefore;

    // استعد حقوق التبييت ومواقع الملوك
    castlingRights[PieceColor.white]![CastlingSide.kingSide] =
        u.castlingBefore[PieceColor.white]![CastlingSide.kingSide]!;
    castlingRights[PieceColor.white]![CastlingSide.queenSide] =
        u.castlingBefore[PieceColor.white]![CastlingSide.queenSide]!;
    castlingRights[PieceColor.black]![CastlingSide.kingSide] =
        u.castlingBefore[PieceColor.black]![CastlingSide.kingSide]!;
    castlingRights[PieceColor.black]![CastlingSide.queenSide] =
        u.castlingBefore[PieceColor.black]![CastlingSide.queenSide]!;
    kingPositions[PieceColor.white] = u.kingsBefore[PieceColor.white]!;
    kingPositions[PieceColor.black] = u.kingsBefore[PieceColor.black]!;

    // أعد Zobrist كما كان مباشرة (أسرع وأضمن)
    zobristKey = u.zobristBefore;

    // استرجع القطع على المربعات (عكوس ما فعلناه)
    // إذا كانت Castling أعد الرخ أولاً
    if (m.isCastling &&
        u.rookFrom != null &&
        u.rookTo != null &&
        u.rookBefore != null) {
      // أزل الرخ من rookTo وأعده إلى rookFrom
      _set(u.rookTo!, null);
      _set(u.rookFrom!, u.rookBefore);
    }

    // نهاية الخانة يجب أن تُفرَّغ
    _set(end, m.isEnPassant ? null : u.captured);
    // أعد القطعة الناقلة إلى start بحالتها السابقة (قد تكون Pawn لو كانت ترقية)
    _set(start, u.movedBefore);
  }

  // ---- أدوات داخلية ----

  // إلغاء حق تبييت معيّن إن كان true (وتحديث Zobrist تبع الحق)
  void _revokeCastlingIfTrue(PieceColor color, CastlingSide side) {
    if (castlingRights[color]![side] == true) {
      // غيّره إلى false مع تحديث Zobrist
      zobristKey = ZobristHashing.setCastlingRight(
        zobristKey,
        color: color,
        side: side,
        prev: true,
        next: false,
      );
      castlingRights[color]![side] = false;
    }
  }
}
