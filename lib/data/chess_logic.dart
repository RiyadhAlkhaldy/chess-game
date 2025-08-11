import '../domain/entities/board.dart';
import '../domain/entities/cell.dart';
import '../domain/entities/move.dart';
import '../domain/entities/piece.dart';
import '../domain/repositories/simulate_move.dart';

class ChessLogic {
  static bool isMoveResultingInCheck(Board board, Move move) {
    final simulatedBoard = SimulateMove.simulateMove(board, move);
    return simulatedBoard.isKingInCheck(board.currentPlayer);
  }

  static List<Move> getAllLegalMovesForCurrentPlayer([Board? boardParameter]) {
    final board = boardParameter;
    // debugPrint("getAllLegalMovesForCurrentPlayer");

    final List<Move> allLegalMoves = [];
    final currentPlayerColor = board!.currentPlayer;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == currentPlayerColor) {
          final legalmoves = getLegalMoves(currentCell, board);
          if (legalmoves.isNotEmpty) {
            allLegalMoves.addAll(legalmoves);
          }
        }
      }
    }
    return allLegalMoves;
  }

  static List<Move> getLegalMoves(Cell cell, [Board? boardParameter]) {
    final boardToUse = boardParameter;
    final piece = boardToUse!.getPieceAt(cell);
    if (piece == null || piece.color != boardToUse.currentPlayer) {
      return []; // لا توجد قطعة أو ليست قطعة اللاعب الحالي
    }

    // الحصول على الحركات الأولية للقطعة (بغض النظر عن الكش)
    final rawMoves = piece.getRawMoves(boardToUse, cell);

    // تصفية الحركات لإزالة تلك التي تضع الملك في كش
    final legalMoves =
        rawMoves.where((move) {
          return !isMoveResultingInCheck(boardToUse, move);
        }).toList();

    // إضافة حركات الكاستلينج القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.king) {
      _addCastlingMoves(legalMoves, cell, piece.color, boardToUse);
    }
    // إضافة حركات En Passant القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.pawn) {
      _addEnPassantMoves(legalMoves, cell, piece.color, boardToUse);
    }

    return legalMoves;
  }

  /// دالة مساعدة خاصة لإضافة حركات الكاستلينج بعد التحقق من شرعيتها.
  /// الكاستلينج له قواعد خاصة لا يمكن التحقق منها فقط من خلال getRawMoves.
  static void _addCastlingMoves(
    List<Move> moves,
    Cell kingCell,
    PieceColor kingColor, [
    Board? boardParameter,
  ]) {
    final board = boardParameter;
    if (kingColor != board!.currentPlayer) return;
    if (board.isKingInCheck(kingColor)) {
      return; // لا يمكن الكاستلينج إذا كان الملك في كش
    }

    final int kingRow = kingColor == PieceColor.white ? 7 : 0;

    // الكاستلينج لجهة الملك (King-side Castling)
    if (board.castlingRights[kingColor]![CastlingSide.kingSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 7);
      final Piece? rook = board.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          board.getPieceAt(Cell(row: kingRow, col: 5)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 6)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 5)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 6))) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 6),
              isCastling: true,
              movedPiece: King(
                color: kingColor,
                type: PieceType.king,
                hasMoved: true,
              ),
              castlingRookFrom: rookCell,
              castlingRookTo: Cell(row: kingRow, col: 5),
            ),
          );
        }
      }
    }

    // الكاستلينج لجهة الملكة (Queen-side Castling)
    if (board.castlingRights[kingColor]![CastlingSide.queenSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 0);
      final Piece? rook = board.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          board.getPieceAt(Cell(row: kingRow, col: 3)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 2)) == null &&
          board.getPieceAt(Cell(row: kingRow, col: 1)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 3)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 2)) &&
            !board.isCellUnderAttack(kingColor, Cell(row: kingRow, col: 1))) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 2),
              isCastling: true,
              movedPiece: King(
                color: kingColor,
                type: PieceType.king,
                hasMoved: true,
              ),
              castlingRookFrom: rookCell,
              castlingRookTo: Cell(row: kingRow, col: 3),
            ),
          );
        }
      }
    }
  }

  /// دالة مساعدة خاصة لإضافة حركات الـ En Passant بعد التحقق من شرعيتها.
  static void _addEnPassantMoves(
    List<Move> moves,
    Cell pawnCell,
    PieceColor pawnColor, [
    Board? boardParameter,
  ]) {
    final board = boardParameter;
    if (board!.enPassantTarget == null) return;

    final int direction = pawnColor == PieceColor.white ? -1 : 1;
    final int targetRow = pawnCell.row + direction;

    // تحقق من الخلايا المجاورة للبيدق لعملية الـ En Passant
    final List<Cell> adjacentCells = [
      Cell(row: pawnCell.row, col: pawnCell.col - 1),
      Cell(row: pawnCell.row, col: pawnCell.col + 1),
    ];

    for (final adjacentCell in adjacentCells) {
      if (adjacentCell.isValid()) {
        final Piece? adjacentPiece = board.getPieceAt(adjacentCell);
        if (adjacentPiece is Pawn &&
            adjacentPiece.color != pawnColor &&
            board.enPassantTarget ==
                Cell(row: targetRow, col: adjacentCell.col) &&
            board.moveHistory.isNotEmpty) {
          // التحقق مما إذا كانت الحركة الأخيرة هي حركة بيدق مزدوجة للبيدق المستهدف
          final lastMove = board.moveHistory.last;
          if (lastMove.isTwoStepPawnMove && lastMove.end == adjacentCell) {
            moves.add(
              Move(
                start: pawnCell,
                end: board.enPassantTarget!,
                isEnPassant: true,
                isCapture: true, // En Passant هو نوع من أنواع الأسر
                movedPiece: Pawn(
                  color: pawnColor,
                  type: PieceType.pawn,
                  hasMoved: true,
                ),
                capturedPiece: board.getPieceAt(board.enPassantTarget!),
                // enPassantTargetBefore: board.enPassantTarget,
              ),
            );
          }
        }
      }
    }
  }

  ///
  ///
  ///
}
