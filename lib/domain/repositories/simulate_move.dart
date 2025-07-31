// lib/data/repositories/game_repository_impl.dart

import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

// lib/data/repositories/game_repository_impl.dart

// ... تأكد من أن هذه الفئة أو امتداد موجودة في ملفك ...

class SimulateMove {
  static Board simulateMove(Board board, Move move) {
    // 1. إنشاء نسخة عميقة من اللوحة الحالية
    // هذا أمر بالغ الأهمية لضمان أن التغييرات في اللوحة المحاكاة لا تؤثر على اللوحة الأصلية أو أي لوحات أخرى.
    Board simulatedBoard = board.copyWithDeepPieces();

    final Piece? pieceToMove = simulatedBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      // هذا لا ينبغي أن يحدث إذا كانت الحركات تم التحقق منها مسبقًا كحركات قانونية
      // ولكن كإجراء احترازي، نرجع اللوحة بدون تغيير.
      return simulatedBoard;
    }

    // 2. تحديث مواقع القطع
    // قم بتحريك القطعة من خلية البداية إلى خلية النهاية.
    final Piece updatedPieceForSimulation = pieceToMove.copyWith();
    simulatedBoard = simulatedBoard.placePiece(
      move.end,
      updatedPieceForSimulation,
    );
    simulatedBoard = simulatedBoard.placePiece(
      move.start,
      null,
    ); // إزالة القطعة من خلية البداية

    // 3. تحديث موقع الملك (إذا كانت القطعة المتحركة ملكاً)
    if (pieceToMove.type == PieceType.king) {
      final Map<PieceColor, Cell> newKingPositions = Map.from(
        simulatedBoard.kingPositions,
      );
      newKingPositions[pieceToMove.color] = move.end;
      simulatedBoard = simulatedBoard.copyWith(kingPositions: newKingPositions);
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

    // 5. معالجة التبييت (Castling)
    if (move.isCastling && pieceToMove.type == PieceType.king) {
      final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // King-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 7);
        final Cell newRookCell = Cell(row: kingRow, col: 5);
        final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith();
          simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
          simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
        }
      } else if (move.end.col == 2) {
        // Queen-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 0);
        final Cell newRookCell = Cell(row: kingRow, col: 3);
        final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith();
          simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
          simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
        }
      }
    }

    // 6. تحديد اللاعب التالي (هام جداً لـ Minimax)
    final PieceColor nextPlayer =
        board.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    // 7. تحديث هدف الأسر بالمرور الجديد
    Cell? newEnPassantTargetForSimulatedBoard;
    // إذا كانت الحركة الحالية بيدقًا يتقدم خطوتين، فحدد هدف الأسر بالمرور الجديد.
    if (pieceToMove.type == PieceType.pawn &&
        (move.end.row - move.start.row).abs() == 2) {
      final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
      newEnPassantTargetForSimulatedBoard = Cell(
        row: move.end.row + direction,
        col: move.end.col,
      );
    } else {
      // وإلا، لا يوجد هدف للأسر بالمرور في الدور التالي.
      newEnPassantTargetForSimulatedBoard = null;
    }

    // 8. تحديث حقوق التبييت
    Map<PieceColor, Map<CastlingSide, bool>> newCastlingRights = Map.from(
      simulatedBoard.castlingRights,
    );

    // إذا تحرك الملك، يفقد حقوق التبييت.
    if (pieceToMove.type == PieceType.king) {
      newCastlingRights[pieceToMove.color] = {
        CastlingSide.kingSide: false,
        CastlingSide.queenSide: false,
      };
    }
    // إذا تحرك الرخ من موقعه الأصلي، يفقد حقوق التبييت لهذا الجانب.
    if (pieceToMove.type == PieceType.rook) {
      if (pieceToMove.color == PieceColor.white) {
        if (move.start == const Cell(row: 7, col: 0)) {
          // Rook at A1
          newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 7, col: 7)) {
          // Rook at H1
          newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
        }
      } else {
        if (move.start == const Cell(row: 0, col: 0)) {
          // Rook at A8
          newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 0, col: 7)) {
          // Rook at H8
          newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
        }
      }
    }
    // إذا تم أسر رخ العدو في موقعه الأصلي، يفقد العدو حقوق التبييت لذلك الجانب.
    if (move.isCapture) {
      if (move.end == const Cell(row: 0, col: 0)) {
        // Captured at A8
        newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 0, col: 7)) {
        // Captured at H8
        newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
      } else if (move.end == const Cell(row: 7, col: 0)) {
        // Captured at A1
        newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 7, col: 7)) {
        // Captured at H1
        newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
      }
    }

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
    return simulatedBoard
        .copyWith(
          currentPlayer: nextPlayer,
          enPassantTarget: newEnPassantTargetForSimulatedBoard,
          castlingRights: newCastlingRights,
          halfMoveClock: newHalfMoveClock,
          fullMoveNumber: newFullMoveNumber,
          positionHistory: newPositionHistory,
          // لا تقم بتضمين moveHistory هنا ما لم تكن بحاجة لتتبعها داخل Minimax لأسباب خاصة (مثل قاعدة التكرار الثلاثي في العقد الفرعية، وهو أمر معقد وغير شائع).
          // عادةً، يتم فحص التكرار الثلاثي على لوحات اللعبة الفعلية.
        )
        .copyWithDeepPieces();
  }
}

// class SimulateMove {
//   static Board simulateMove(Board board, Move move) {
//     Board simulatedBoard = board.copyWithDeepPieces();
//     final Piece? pieceToMove = simulatedBoard.getPieceAt(move.start);

//     if (pieceToMove == null) {
//       // هذا لا ينبغي أن يحدث إذا كانت الحركة قانونية
//       return simulatedBoard;
//     }

//     // لاحظ: هنا لا نغير hasMoved لأنها محاكاة فقط.
//     // يتم تغييرها في makeMove الفعلية.
//     // إذا كنت بحاجة لتغييرها للمحاكاة (مثلاً لفحص الكاستلينج في محاكاة)، ستحتاج لإنشاء نسخة من القطعة.
//     final Piece updatedPieceForSimulation =
//         pieceToMove.copyWith(); // لا تغير hasMoved هنا
//     simulatedBoard = simulatedBoard.placePiece(
//       move.end,
//       updatedPieceForSimulation,
//     );
//     simulatedBoard = simulatedBoard.placePiece(move.start, null);

//     // تحديث موقع الملك في اللوحة المحاكاة
//     if (pieceToMove.type == PieceType.king) {
//       final Map<PieceColor, Cell> newKingPositions = Map.from(
//         simulatedBoard.kingPositions,
//       );
//       newKingPositions[pieceToMove.color] = move.end;
//       simulatedBoard = simulatedBoard.copyWith(kingPositions: newKingPositions);
//     }

//     // معالجة En Passant في المحاكاة
//     if (move.isEnPassant) {
//       final int capturedPawnRow =
//           pieceToMove.color == PieceColor.white
//               ? move.end.row + 1
//               : move.end.row - 1;
//       final Cell capturedPawnCell = Cell(
//         row: capturedPawnRow,
//         col: move.end.col,
//       );
//       simulatedBoard = simulatedBoard.placePiece(capturedPawnCell, null);
//     }

//     // معالجة Castling في المحاكاة
//     if (move.isCastling && pieceToMove.type == PieceType.king) {
//       final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
//       if (move.end.col == 6) {
//         // King-side castling
//         final Cell oldRookCell = Cell(row: kingRow, col: 7);
//         final Cell newRookCell = Cell(row: kingRow, col: 5);
//         final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
//         if (rook != null) {
//           final Rook updatedRook =
//               rook.copyWith(); // لا تغير hasMoved هنا للمحاكاة
//           simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
//           simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
//         }
//       } else if (move.end.col == 2) {
//         // Queen-side castling
//         final Cell oldRookCell = Cell(row: kingRow, col: 0);
//         final Cell newRookCell = Cell(row: kingRow, col: 3);
//         final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
//         if (rook != null) {
//           final Rook updatedRook =
//               rook.copyWith(); // لا تغير hasMoved هنا للمحاكاة
//           simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
//           simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
//         }
//       }
//     }

//     return simulatedBoard;
//   }
// }
