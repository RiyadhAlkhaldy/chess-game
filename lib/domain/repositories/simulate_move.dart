import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/move.dart';
import '../entities/piece.dart';
import 'zobrist_hashing.dart';

class SimulateMove {
  static Board simulateMove(Board board, Move move) {
    // 1. إنشاء نسخة عميقة من اللوحة الحالية
    // هذا أمر بالغ الأهمية لضمان أن التغييرات في اللوحة المحاكاة لا تؤثر على اللوحة الأصلية أو أي لوحات أخرى.
    Board simulatedBoard = board.copyWithDeepPieces();
    Piece? pieceToMove = simulatedBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      // هذا لا ينبغي أن يحدث إذا كانت الحركات تم التحقق منها مسبقًا كحركات قانونية
      // ولكن كإجراء احترازي، نرجع اللوحة بدون تغيير.
      return simulatedBoard;
    }

    // 4. معالجة الأسر بالمرور (En Passant)
    if (move.isEnPassant) {
      // إزالة البيدق المأسور
      final int capturedPawnRow =
          pieceToMove.color == PieceColor.white
              ? move.end.row + 1
              : move.end.row - 1;
      final Cell capturedPawnCell = Cell(
        row: capturedPawnRow,
        col: move.end.col,
      );
      simulatedBoard = simulatedBoard.placePiece(capturedPawnCell, null);
    }
    // 7. تحديث هدف الأسر بالمرور الجديد
    Cell? newEnPassantTargetForSimulatedBoard;
    // إذا كانت الحركة الحالية بيدقًا يتقدم خطوتين، فحدد هدف الأسر بالمرور الجديد.
    if (move.isTwoStepPawnMove && pieceToMove.type == PieceType.pawn) {
      final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
      newEnPassantTargetForSimulatedBoard = Cell(
        row: move.end.row + direction,
        col: move.end.col,
      );
    }

    // 5. معالجة التبييت (Castling)
    Map<PieceColor, Map<CastlingSide, bool>> newCastlingRights = Map.from(
      simulatedBoard.castlingRights,
    );
    Map<PieceColor, Cell> newKingPositions = Map.from(
      simulatedBoard.kingPositions,
    );
    // 3. تحديث موقع الملك (إذا كانت القطعة المتحركة ملكاً)
    if (pieceToMove.type == PieceType.king) {
      newKingPositions[pieceToMove.color] = move.end;
      if (!pieceToMove.hasMoved) {
        newCastlingRights =
            newCastlingRights..update(
              pieceToMove.color,
              (value) =>
                  value
                    ..update(CastlingSide.kingSide, (value) => false)
                    ..update(CastlingSide.queenSide, (value) => false),
            );
      }
      //   معالجة التبييت (Castling)
      if (move.isCastling) {
        final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
        if (move.end.col == 6) {
          // King-side castling
          final Cell oldRookCell = Cell(row: kingRow, col: 7);
          final Cell newRookCell = Cell(row: kingRow, col: 5);
          final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
          if (rook != null) {
            final Rook updatedRook = rook.copyWith(hasMoved: true);
            simulatedBoard = simulatedBoard
                .placePiece(newRookCell, updatedRook)
                .placePiece(oldRookCell, null);
          }
        } else if (move.end.col == 2) {
          // Queen-side castling
          final Cell oldRookCell = Cell(row: kingRow, col: 0);
          final Cell newRookCell = Cell(row: kingRow, col: 3);
          final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
          if (rook != null) {
            final Rook updatedRook = rook.copyWith(hasMoved: true);
            simulatedBoard = simulatedBoard
                .placePiece(newRookCell, updatedRook)
                .placePiece(oldRookCell, null);
          }
        }
      }
    } else if (pieceToMove.type == PieceType.rook) {
      // 8. تحديث حقوق التبييت
      // إذا تحرك الرخ من موضعه الأصلي، يفقد حقوق الكاستلينج لتلك الجهة
      if (pieceToMove.color == PieceColor.white) {
        if (move.start == const Cell(row: 7, col: 0)) {
          // رخ أبيض يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.start == const Cell(row: 7, col: 7)) {
          // رخ أبيض يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        }
      } else {
        // Black rook
        if (move.start == const Cell(row: 0, col: 0)) {
          // رخ أسود يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.start == const Cell(row: 0, col: 7)) {
          // رخ أسود يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        }
      }
    }

    // إذا تم أسر الرخ، يفقد حقوق الكاستلينج للخصم لتلك الجهة
    if (move.isCapture) {
      final pieceCaptured = board.getPieceAt(move.end);
      if (pieceCaptured!.type == PieceType.rook) {
        // تحقق من الرخ الذي تم أسره (إذا كان رخ)
        if (move.end == const Cell(row: 0, col: 0)) {
          // رخ أسود يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.end == const Cell(row: 0, col: 7)) {
          // رخ أسود يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.black,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        } else if (move.end == const Cell(row: 7, col: 0)) {
          // رخ أبيض يسار
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.queenSide, (value) => false),
              );
        } else if (move.end == const Cell(row: 7, col: 7)) {
          // رخ أبيض يمين
          newCastlingRights =
              newCastlingRights..update(
                PieceColor.white,
                (value) =>
                    Map.from(value)
                      ..update(CastlingSide.kingSide, (value) => false),
              );
        }
      }
    }
    // 6. تحديد اللاعب التالي (هام جداً لـ Minimax)
    final PieceColor nextPlayer =
        board.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
    if (move.isPromotion && move.movedPiece.type == PieceType.pawn) {
      // افتراض الترقية إلى ملكة إذا لم يحدد نوع آخر (يمكن توسيع هذا لاحقًا)
      pieceToMove = move.promotedTo;
    }
    // 2. تحديث مواقع القطع
    // قم بتحريك القطعة من خلية البداية إلى خلية النهاية.
    simulatedBoard = simulatedBoard
        .placePiece(
          move.end,
          pieceToMove!.hasMoved
              ? pieceToMove
              : pieceToMove.copyWith(hasMoved: true),
        )
        .placePiece(move.start, null); // إزالة القطعة من خلية البداية
    // 9. تحديث عدد الحركات النصفية (Half-move Clock) وقاعدة الخمسين حركة
    // يعاد ضبط العداد إلى صفر إذا تم تحريك بيدق أو حدث أسر.
    int newHalfMoveClock = board.halfMoveClock + 1;
    if (pieceToMove.type == PieceType.pawn || move.isCapture) {
      newHalfMoveClock = 0;
    }

    // 10. تحديث عدد الحركات الكاملة (Full-move Number)
    // يزيد بعد كل حركة للأسود.
    int newFullMoveNumber = board.fullMoveNumber;
    if (board.currentPlayer == PieceColor.black) {
      newFullMoveNumber++;
    }
    // إضافة الوضعية الحالية إلى سجل الوضعيات (للتكرار الثلاثي)
    // Add the current position to the position history (for threefold repetition)
    final newPositionHistory = List<String>.from(simulatedBoard.positionHistory)
      ..add(simulatedBoard.toFenString());
    // 11. إعادة اللوحة المحاكاة مع الخصائص المحدثة
    return simulatedBoard.copyWith(
      currentPlayer: nextPlayer,
      enPassantTarget: newEnPassantTargetForSimulatedBoard,
      castlingRights: newCastlingRights,
      kingPositions: newKingPositions,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      positionHistory: newPositionHistory,
      zobristKey: ZobristHashing.updateZobristKeyAfterMove(board, move),
      // لا تقم بتضمين moveHistory هنا ما لم تكن بحاجة لتتبعها داخل Minimax لأسباب خاصة (مثل قاعدة التكرار الثلاثي في العقد الفرعية، وهو أمر معقد وغير شائع).
      // عادةً، يتم فحص التكرار الثلاثي على لوحات اللعبة الفعلية.
    );
  }

  Map<PieceColor, Map<CastlingSide, bool>> updateCastlingRights(
    Map<PieceColor, Map<CastlingSide, bool>> newCastlingRights,
    PieceColor pieceColor,
    CastlingSide castlingSide,
  ) {
    return newCastlingRights..update(
      pieceColor,
      (value) => Map.from(value)..update(castlingSide, (value) => false),
    );
  }
}
