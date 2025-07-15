// lib/data/repositories/game_repository_impl.dart

import 'package:flutter/material.dart';

// import 'package:collection/collection.dart'; // لتسهيل مقارنة القوائم

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/game_repository.dart';

/// تطبيق [GameRepository] الذي يحتوي على منطق لعبة الشطرنج الفعلي.
class GameRepositoryImpl implements GameRepository {
  Board _currentBoard;
  List<Board> _boardHistory = []; // لتتبع تكرار اللوحة

  /// مُنشئ لـ [GameRepositoryImpl]. يبدأ اللعبة بلوحة أولية للاعب الأبيض.
  GameRepositoryImpl() : _currentBoard = Board.initial() {
    _boardHistory.add(_currentBoard);
  }

  @override
  Board getCurrentBoard() {
    return _currentBoard;
  }

  @override
  List<Move> getLegalMoves(Cell cell) {
    final piece = _currentBoard.getPieceAt(cell);
    if (piece == null || piece.color != _currentBoard.currentPlayer) {
      return []; // لا توجد قطعة أو ليست قطعة اللاعب الحالي
    }

    // الحصول على الحركات الأولية للقطعة (بغض النظر عن الكش)
    final rawMoves = piece.getRawMoves(_currentBoard, cell);

    // تصفية الحركات لإزالة تلك التي تضع الملك في كش
    final legalMoves =
        rawMoves.where((move) {
          return !isMoveResultingInCheck(_currentBoard, move);
        }).toList();

    // إضافة حركات الكاستلينج القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.king) {
      _addCastlingMoves(legalMoves, cell, piece.color);
    }
    // إضافة حركات En Passant القانونية (يتم التحقق منها هنا بشكل كامل)
    if (piece.type == PieceType.pawn) {
      _addEnPassantMoves(legalMoves, cell, piece.color);
    }

    return legalMoves;
  }

  /// دالة مساعدة خاصة لإضافة حركات الكاستلينج بعد التحقق من شرعيتها.
  /// الكاستلينج له قواعد خاصة لا يمكن التحقق منها فقط من خلال getRawMoves.
  void _addCastlingMoves(
    List<Move> moves,
    Cell kingCell,
    PieceColor kingColor,
  ) {
    if (kingColor != _currentBoard.currentPlayer) return;
    if (_currentBoard.isKingInCheck(kingColor)) {
      return; // لا يمكن الكاستلينج إذا كان الملك في كش
    }

    final int kingRow = kingColor == PieceColor.white ? 7 : 0;

    // الكاستلينج لجهة الملك (King-side Castling)
    if (_currentBoard.castlingRights[kingColor]![CastlingSide.kingSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 7);
      final Piece? rook = _currentBoard.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          _currentBoard.getPieceAt(Cell(row: kingRow, col: 5)) == null &&
          _currentBoard.getPieceAt(Cell(row: kingRow, col: 6)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!_currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 5),
            ) &&
            !_currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 6),
            )) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 6),
              isCastling: true,
            ),
          );
        }
      }
    }

    // الكاستلينج لجهة الملكة (Queen-side Castling)
    if (_currentBoard.castlingRights[kingColor]![CastlingSide.queenSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 0);
      final Piece? rook = _currentBoard.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          _currentBoard.getPieceAt(Cell(row: kingRow, col: 3)) == null &&
          _currentBoard.getPieceAt(Cell(row: kingRow, col: 2)) == null &&
          _currentBoard.getPieceAt(Cell(row: kingRow, col: 1)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!_currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 3),
            ) &&
            !_currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 2),
            )) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 2),
              isCastling: true,
            ),
          );
        }
      }
    }
  }

  /// دالة مساعدة خاصة لإضافة حركات الـ En Passant بعد التحقق من شرعيتها.
  void _addEnPassantMoves(
    List<Move> moves,
    Cell pawnCell,
    PieceColor pawnColor,
  ) {
    if (_currentBoard.enPassantTarget == null) return;

    final int direction = pawnColor == PieceColor.white ? -1 : 1;
    final int targetRow = pawnCell.row + direction;

    // تحقق من الخلايا المجاورة للبيدق لعملية الـ En Passant
    final List<Cell> adjacentCells = [
      Cell(row: pawnCell.row, col: pawnCell.col - 1),
      Cell(row: pawnCell.row, col: pawnCell.col + 1),
    ];

    for (final adjacentCell in adjacentCells) {
      if (adjacentCell.isValid()) {
        final Piece? adjacentPiece = _currentBoard.getPieceAt(adjacentCell);
        if (adjacentPiece is Pawn &&
            adjacentPiece.color != pawnColor &&
            _currentBoard.enPassantTarget ==
                Cell(row: targetRow, col: adjacentCell.col) &&
            _currentBoard.moveHistory.isNotEmpty) {
          // التحقق مما إذا كانت الحركة الأخيرة هي حركة بيدق مزدوجة للبيدق المستهدف
          final lastMove = _currentBoard.moveHistory.last;
          if (lastMove.isTwoStepPawnMove && lastMove.end == adjacentCell) {
            moves.add(
              Move(
                start: pawnCell,
                end: _currentBoard.enPassantTarget!,
                isEnPassant: true,
                isCapture: true, // En Passant هو نوع من أنواع الأسر
              ),
            );
          }
        }
      }
    }
  }

  @override
  Board makeMove(Move move) {
    Board newBoard = _currentBoard.copyWithDeepPieces();
    final Piece? pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      debugPrint("خطأ: لا توجد قطعة في خلية البداية.");
      return _currentBoard; // لا تفعل شيئًا إذا لم تكن هناك قطعة
    }

    // تحديث hasMoved للقطعة التي تتحرك
    final Piece updatedPiece = pieceToMove.copyWith(hasMoved: true);
    newBoard = newBoard.placePiece(move.end, updatedPiece);
    newBoard = newBoard.placePiece(
      move.start,
      null,
    ); // إزالة القطعة من الخلية الأصلية

    // منطق الـ En Passant
    Cell? newEnPassantTarget;
    if (move.isTwoStepPawnMove && pieceToMove.type == PieceType.pawn) {
      final int direction = pieceToMove.color == PieceColor.white ? 1 : -1;
      newEnPassantTarget = Cell(
        row: move.end.row + direction,
        col: move.end.col,
      );
    }

    if (move.isEnPassant) {
      final int capturedPawnRow =
          pieceToMove.color == PieceColor.white
              ? move.end.row + 1
              : move.end.row - 1;
      final Cell capturedPawnCell = Cell(
        row: capturedPawnRow,
        col: move.end.col,
      );
      newBoard = newBoard.placePiece(
        capturedPawnCell,
        null,
      ); // إزالة البيدق المأسور
    }

    // منطق الكاستلينج
    if (move.isCastling && pieceToMove.type == PieceType.king) {
      final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // King-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 7);
        final Cell newRookCell = Cell(row: kingRow, col: 5);
        final Rook? rook = newBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith(hasMoved: true);
          newBoard = newBoard.placePiece(newRookCell, updatedRook);
          newBoard = newBoard.placePiece(oldRookCell, null);
        }
      } else if (move.end.col == 2) {
        // Queen-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 0);
        final Cell newRookCell = Cell(row: kingRow, col: 3);
        final Rook? rook = newBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook = rook.copyWith(hasMoved: true);
          newBoard = newBoard.placePiece(newRookCell, updatedRook);
          newBoard = newBoard.placePiece(oldRookCell, null);
        }
      }
    }

    // منطق ترقية البيدق
    if (move.isPromotion && pieceToMove.type == PieceType.pawn) {
      // افتراض الترقية إلى ملكة إذا لم يحدد نوع آخر (يمكن توسيع هذا لاحقًا)
      final promotedPiece = Queen(
        color: pieceToMove.color,
        type: PieceType.queen,
        hasMoved: true,
      );
      newBoard = newBoard.placePiece(move.end, promotedPiece);
    }

    // تحديث حقوق الكاستلينج بعد حركة الملك أو الرخ
    Map<PieceColor, Map<CastlingSide, bool>> newCastlingRights = Map.from(
      newBoard.castlingRights,
    );

    // إذا تحرك الملك، يفقد حقوق الكاستلينج
    if (pieceToMove.type == PieceType.king) {
      newCastlingRights[pieceToMove.color] = {
        CastlingSide.kingSide: false,
        CastlingSide.queenSide: false,
      };
    }

    // إذا تحرك الرخ من موضعه الأصلي، يفقد حقوق الكاستلينج لتلك الجهة
    if (pieceToMove.type == PieceType.rook) {
      if (pieceToMove.color == PieceColor.white) {
        if (move.start == const Cell(row: 7, col: 0)) {
          // رخ أبيض يسار
          newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 7, col: 7)) {
          // رخ أبيض يمين
          newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
        }
      } else {
        // Black rook
        if (move.start == const Cell(row: 0, col: 0)) {
          // رخ أسود يسار
          newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
        } else if (move.start == const Cell(row: 0, col: 7)) {
          // رخ أسود يمين
          newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
        }
      }
    }
    // إذا تم أسر الرخ، يفقد حقوق الكاستلينج للخصم لتلك الجهة
    if (move.isCapture) {
      // تحقق من الرخ الذي تم أسره (إذا كان رخ)
      if (move.end == const Cell(row: 0, col: 0)) {
        // رخ أسود يسار
        newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 0, col: 7)) {
        // رخ أسود يمين
        newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
      } else if (move.end == const Cell(row: 7, col: 0)) {
        // رخ أبيض يسار
        newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
      } else if (move.end == const Cell(row: 7, col: 7)) {
        // رخ أبيض يمين
        newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
      }
    }

    // تحديث مواضع الملك
    Map<PieceColor, Cell> newKingPositions = Map.from(newBoard.kingPositions);
    if (pieceToMove.type == PieceType.king) {
      newKingPositions[pieceToMove.color] = move.end;
    }

    // تحديث HalfMoveClock
    int newHalfMoveClock = newBoard.halfMoveClock + 1;
    if (pieceToMove.type == PieceType.pawn || move.isCapture) {
      newHalfMoveClock = 0; // إعادة تعيين العداد عند حركة بيدق أو أسر
    }

    // تحديث FullMoveNumber
    int newFullMoveNumber = newBoard.fullMoveNumber;
    if (newBoard.currentPlayer == PieceColor.black) {
      newFullMoveNumber++; // يزداد بعد حركة اللاعب الأسود
    }

    // تحديث اللاعب الحالي
    final PieceColor nextPlayer =
        _currentBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    newBoard = newBoard.copyWith(
      moveHistory: List.from(_currentBoard.moveHistory)..add(move),
      currentPlayer: nextPlayer,
      enPassantTarget: newEnPassantTarget,
      castlingRights: newCastlingRights,
      kingPositions: newKingPositions,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
    );

    _currentBoard = newBoard;
    _boardHistory.add(_currentBoard); // إضافة اللوحة الجديدة إلى سجل التاريخ

    return _currentBoard;
  }

  @override
  bool isKingInCheck(PieceColor kingColor) {
    return _currentBoard.isKingInCheck(kingColor);
  }

  @override
  GameResult getGameResult() {
    return checkGameEndConditions();
  }

  @override
  void resetGame() {
    _currentBoard = Board.initial();
    _boardHistory = [_currentBoard]; // إعادة تعيين تاريخ اللوحة أيضًا
  }

  @override
  Board simulateMove(Board board, Move move) {
    Board simulatedBoard = board.copyWithDeepPieces();
    final Piece? pieceToMove = simulatedBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      // هذا لا ينبغي أن يحدث إذا كانت الحركة قانونية
      return simulatedBoard;
    }

    // لاحظ: هنا لا نغير hasMoved لأنها محاكاة فقط.
    // يتم تغييرها في makeMove الفعلية.
    // إذا كنت بحاجة لتغييرها للمحاكاة (مثلاً لفحص الكاستلينج في محاكاة)، ستحتاج لإنشاء نسخة من القطعة.
    final Piece updatedPieceForSimulation =
        pieceToMove.copyWith(); // لا تغير hasMoved هنا
    simulatedBoard = simulatedBoard.placePiece(
      move.end,
      updatedPieceForSimulation,
    );
    simulatedBoard = simulatedBoard.placePiece(move.start, null);

    // تحديث موقع الملك في اللوحة المحاكاة
    if (pieceToMove.type == PieceType.king) {
      final Map<PieceColor, Cell> newKingPositions = Map.from(
        simulatedBoard.kingPositions,
      );
      newKingPositions[pieceToMove.color] = move.end;
      simulatedBoard = simulatedBoard.copyWith(kingPositions: newKingPositions);
    }

    // معالجة En Passant في المحاكاة
    if (move.isEnPassant) {
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

    // معالجة Castling في المحاكاة
    if (move.isCastling && pieceToMove.type == PieceType.king) {
      final int kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // King-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 7);
        final Cell newRookCell = Cell(row: kingRow, col: 5);
        final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook =
              rook.copyWith(); // لا تغير hasMoved هنا للمحاكاة
          simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
          simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
        }
      } else if (move.end.col == 2) {
        // Queen-side castling
        final Cell oldRookCell = Cell(row: kingRow, col: 0);
        final Cell newRookCell = Cell(row: kingRow, col: 3);
        final Rook? rook = simulatedBoard.getPieceAt(oldRookCell) as Rook?;
        if (rook != null) {
          final Rook updatedRook =
              rook.copyWith(); // لا تغير hasMoved هنا للمحاكاة
          simulatedBoard = simulatedBoard.placePiece(newRookCell, updatedRook);
          simulatedBoard = simulatedBoard.placePiece(oldRookCell, null);
        }
      }
    }

    return simulatedBoard;
  }

  @override
  bool isMoveResultingInCheck(Board board, Move move) {
    final simulatedBoard = simulateMove(board, move);
    // التحقق من أن الملك الخاص باللاعب الذي قام بالحركة ليس في كش بعد الحركة.
    return simulatedBoard.isKingInCheck(board.currentPlayer);
  }

  @override
  List<Move> getAllLegalMovesForCurrentPlayer() {
    final List<Move> allLegalMoves = [];
    final currentPlayerColor = _currentBoard.currentPlayer;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = _currentBoard.getPieceAt(currentCell);
        if (piece != null && piece.color == currentPlayerColor) {
          allLegalMoves.addAll(getLegalMoves(currentCell));
        }
      }
    }
    return allLegalMoves;
  }

  @override
  bool hasAnyLegalMoves(PieceColor playerColor) {
    // لحساب الحركات القانونية للاعب، نحتاج إلى التأكد من أن isKingInCheck
    // والمنطق يعتمد على "اللاعب الحالي" في اللوحة.
    // نقوم بتغيير currentPlayer مؤقتًا إذا لم يكن اللون المطلوب.
    final originalCurrentPlayer = _currentBoard.currentPlayer;
    _currentBoard = _currentBoard.copyWith(currentPlayer: playerColor);

    final bool hasMoves = getAllLegalMovesForCurrentPlayer().isNotEmpty;

    // استعادة اللاعب الحالي الأصلي
    _currentBoard = _currentBoard.copyWith(
      currentPlayer: originalCurrentPlayer,
    );
    return hasMoves;
  }

  @override
  GameResult checkGameEndConditions() {
    final currentPlayerColor = _currentBoard.currentPlayer;

    // 1. تحقق من التعادل أولاً
    final drawOutcome = checkForDrawConditions();
    if (drawOutcome != null) {
      if (drawOutcome == GameOutcome.stalemate) {
        return GameResult.stalemate();
      } else if (drawOutcome == GameOutcome.draw) {
        return GameResult.draw(
          DrawReason.insufficientMaterial,
        ); // تحديد سبب التعادل هنا
      }
    }

    // 2. تحقق من كش ملك / طريق مسدود
    final bool kingInCheck = isKingInCheck(currentPlayerColor);
    final bool hasNoLegalMoves = !hasAnyLegalMoves(currentPlayerColor);

    if (kingInCheck && hasNoLegalMoves) {
      // كش ملك
      final PieceColor winner =
          currentPlayerColor == PieceColor.white
              ? PieceColor.black
              : PieceColor.white;
      return GameResult.checkmate(winner);
    } else if (!kingInCheck && hasNoLegalMoves) {
      // طريق مسدود
      return GameResult.stalemate();
    } else if (drawOutcome == GameOutcome.draw) {
      // إذا كان هناك تعادل لأسباب أخرى غير الطريق المسدود (مثل الخمسين حركة أو التكرار الثلاثي)
      // هذا الشرط ضروري لتغطية الحالات التي لا تكون فيها كش ملك أو طريق مسدود ولكنها تعادل.
      return GameResult.draw(
        DrawReason.insufficientMaterial,
      ); // يجب أن يتم تحديده بدقة أكبر
    }

    return GameResult.playing(); // اللعبة ما زالت مستمرة
  }

  @override
  GameOutcome? checkForDrawConditions() {
    // 1. التعادل بالمواد غير الكافية
    if (_isInsufficientMaterialDraw()) {
      return GameOutcome.draw;
    }

    // 2. قاعدة الخمسين حركة
    if (_currentBoard.halfMoveClock >= 100) {
      // 100 نصف حركة = 50 حركة كاملة
      return GameOutcome.draw;
    }

    // 3. التكرار الثلاثي
    if (_isThreefoldRepetition()) {
      return GameOutcome.draw;
    }

    // يمكنك إضافة التعادل بالاتفاق هنا، لكنه يتطلب مدخلات من المستخدم
    return null; // لا يوجد تعادل حاليًا
  }

  /// يتحقق مما إذا كانت اللوحة الحالية قد تكررت ثلاث مرات.
  bool _isThreefoldRepetition() {
    if (_boardHistory.length < 5) {
      return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (حركتان لكل لاعب + اللوحة الحالية)
    }

    final currentBoardFEN = _boardToFEN(_currentBoard);
    int count = 0;
    // ابحث في سجل اللوحات (تجاهل اللوحة الأخيرة التي تمت إضافتها للتو)
    for (int i = 0; i < _boardHistory.length - 1; i++) {
      if (_boardToFEN(_boardHistory[i]) == currentBoardFEN) {
        count++;
      }
    }
    return count >=
        2; // إذا كانت اللوحة الحالية هي التكرار الثالث، يجب أن يكون قد ظهرت مرتين بالفعل في السجل
  }

  /// دالة مساعدة لتحويل حالة اللوحة إلى تمثيل FEN مبسط
  /// يستخدم لمقارنة اللوحات لتحديد التكرار الثلاثي.
  /// (ملاحظة: هذا ليس FEN كاملًا ودقيقًا وفقًا لمعايير الشطرنج، ولكنه كافٍ للمقارنة الداخلية)
  String _boardToFEN(Board board) {
    String fen = '';
    for (int r = 0; r < 8; r++) {
      int emptyCount = 0;
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += '$emptyCount';
            emptyCount = 0;
          }
          String pieceChar = '';
          switch (piece.type) {
            case PieceType.pawn:
              pieceChar = 'p';
              break;
            case PieceType.rook:
              pieceChar = 'r';
              break;
            case PieceType.knight:
              pieceChar = 'n';
              break;
            case PieceType.bishop:
              pieceChar = 'b';
              break;
            case PieceType.queen:
              pieceChar = 'q';
              break;
            case PieceType.king:
              pieceChar = 'k';
              break;
          }
          fen +=
              (piece.color == PieceColor.white
                  ? pieceChar.toUpperCase()
                  : pieceChar);
        }
      }
      if (emptyCount > 0) {
        fen += '$emptyCount';
      }
      if (r < 7) {
        fen += '/';
      }
    }

    // إضافة معلومات اللاعب الحالي وحقوق الكاستلينج وحركة الـ En Passant ونصف الحركة والرقم الكامل للحركة
    fen += ' ${board.currentPlayer == PieceColor.white ? 'w' : 'b'}';

    String castlingRightsStr = '';
    if (board.castlingRights[PieceColor.white]![CastlingSide.kingSide]!) {
      castlingRightsStr += 'K';
    }
    if (board.castlingRights[PieceColor.white]![CastlingSide.queenSide]!) {
      castlingRightsStr += 'Q';
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.kingSide]!) {
      castlingRightsStr += 'k';
    }
    if (board.castlingRights[PieceColor.black]![CastlingSide.queenSide]!) {
      castlingRightsStr += 'q';
    }
    fen += ' ${castlingRightsStr.isEmpty ? '-' : castlingRightsStr}';

    // تمثيل En Passant: يجب أن يكون بتنسيق العمود والصف (a3, e6)
    // هنا نقوم بتمثيله كـ 'rowcol' مؤقتًا، يمكن تحسينه لاحقًا ليتوافق مع FEN القياسي.
    fen +=
        ' ${board.enPassantTarget == null ? '-' : String.fromCharCode(97 + board.enPassantTarget!.col) + (8 - board.enPassantTarget!.row).toString()}';
    fen += ' ${board.halfMoveClock}';
    fen += ' ${board.fullMoveNumber}';

    return fen;
  }

  /// يتحقق مما إذا كانت حالة اللعبة هي تعادل بسبب المواد غير الكافية.
  /// (الملك مقابل الملك، الملك والأسقف مقابل الملك، الملك والحصان مقابل الملك).
  bool _isInsufficientMaterialDraw() {
    List<Piece> allPieces = [];
    for (var row in _currentBoard.squares) {
      for (var piece in row) {
        if (piece != null) {
          allPieces.add(piece);
        }
      }
    }

    // الملك مقابل الملك
    if (allPieces.length == 2 &&
        allPieces.every((p) => p.type == PieceType.king)) {
      return true;
    }

    // الملك والأسقف مقابل الملك
    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.any((p) => p.type == PieceType.bishop)) {
      return true;
    }

    // الملك والحصان مقابل الملك
    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.any((p) => p.type == PieceType.knight)) {
      return true;
    }

    // الملك والأسقف مقابل الملك والأسقف (على نفس لون المربعات)
    // هذا الشرط أكثر تعقيدًا ويتطلب تحديد لون مربع الأسقف.
    // لتبسيط، إذا كان هناك ملكان وأسقفان فقط، فهذا تعادل.
    if (allPieces.length == 4 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.where((p) => p.type == PieceType.bishop).length == 2) {
      // للتحقق من أن الأساقفة على نفس لون المربعات، نحتاج إلى معرفة مواقعهم.
      // هذا المثال لا يتتبع مواقع القطع في قائمة allPieces.
      // سأفترض هنا أن وجود ملكين وأسقفين فقط يؤدي إلى التعادل بشكل عام.
      return true;
    }

    // يمكن إضافة المزيد من حالات المواد غير الكافية هنا (مثل ملكين وحصانين).

    return false;
  }

  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///

  /// قاموس يمثل قيم القطع (لتقييم اللوحة).
  static const Map<PieceType, int> _pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000, // قيمة عالية جدا للملك
  };

  /// العمق الأقصى لـ Minimax.
  /// (يمكن زيادته للحصول على AI أقوى، ولكنه يزيد من وقت المعالجة).
  int maxMinimaxDepth = 3; // مثال: 3 حركات للأمام (1 للـ AI, 1 للخصم, 1 للـ AI)

  @override
  Future<Move?> getAiMove(
    Board board,
    PieceColor aiPlayerColor,
    int aiDepth,
  ) async {
    // إذا لم تكن هناك حركات قانونية، لا يوجد تحرك للذكاء الاصطناعي.
    if (!hasAnyLegalMoves(aiPlayerColor)) {
      return null;
    }

    // تشغيل خوارزمية Minimax
    final result = await _minimax(
      board: board.copyWith(
        currentPlayer: aiPlayerColor,
      ), // تأكد أن اللاعب الحالي هو AI
      depth: aiDepth,
      maximizingPlayer: true, // الذكاء الاصطناعي يحاول تعظيم نتيجته
      aiPlayerColor: aiPlayerColor,
    );

    return result.move; // إرجاع أفضل حركة وجدتها Minimax
  }

  /// دالة تقييم اللوحة.
  /// تُرجع قيمة عددية تمثل مدى جودة اللوحة للاعب المحدد.
  int _evaluateBoard(Board board, PieceColor aiPlayerColor) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          final pieceValue = _pieceValues[piece.type] ?? 0;
          if (piece.color == aiPlayerColor) {
            score += pieceValue;
          } else {
            score -= pieceValue;
          }
        }
      }
    }
    return score;
  }

  /// تنفيذ خوارزمية Minimax.
  /// [board]: اللوحة الحالية.
  /// [depth]: العمق المتبقي للبحث.
  /// [maximizingPlayer]: صحيح إذا كان اللاعب الحالي هو لاعب التعظيم (AI).
  /// [aiPlayerColor]: لون قطع الذكاء الاصطناعي.
  Future<({int score, Move? move})> _minimax({
    required Board board,
    required int depth,
    required bool maximizingPlayer,
    required PieceColor aiPlayerColor,
  }) async {
    // 1. حالة القاعدة (Base Case):
    // إذا وصلنا إلى أقصى عمق للبحث أو كانت اللعبة قد انتهت.
    //TODO
    // if (depth == 0 || board.getGameResult().outcome != GameOutcome.playing) {
    if (depth == 0 || getGameResult().outcome != GameOutcome.playing) {
      return (score: _evaluateBoard(board, aiPlayerColor), move: null);
    }

    final currentPlayerColor = board.currentPlayer;

    // 2. توليد جميع الحركات القانونية للاعب الحالي
    // ملاحظة: نحتاج إلى قائمة بالحركات القانونية للوحة الحالية،
    // وليس اللوحة العالمية _currentBoard.
    final List<Move> legalMovesForBoard = _getAllLegalMovesForBoard(
      board,
      currentPlayerColor,
    );

    if (maximizingPlayer) {
      // لاعب التعظيم (AI): يحاول زيادة النتيجة إلى أقصى حد
      int maxEval = -double.maxFinite.toInt();
      Move? bestMove;

      for (final move in legalMovesForBoard) {
        final simulatedBoard = simulateMove(board, move);
        final evalResult = await _minimax(
          board: simulatedBoard.copyWith(
            currentPlayer:
                currentPlayerColor == PieceColor.white
                    ? PieceColor.black
                    : PieceColor.white,
          ),
          depth: depth - 1,
          maximizingPlayer: false, // الآن دور لاعب التقليل
          aiPlayerColor: aiPlayerColor,
        );

        if (evalResult.score > maxEval) {
          maxEval = evalResult.score;
          bestMove = move;
        }
      }
      return (score: maxEval, move: bestMove);
    } else {
      // لاعب التقليل (الخصم): يحاول تقليل النتيجة إلى أقصى حد
      int minEval = double.maxFinite.toInt();
      Move? bestMove; // لن نحتاج لـ bestMove هنا إذا كنا مهتمين فقط بحركة AI

      for (final move in legalMovesForBoard) {
        final simulatedBoard = simulateMove(board, move);
        final evalResult = await _minimax(
          board: simulatedBoard.copyWith(
            currentPlayer:
                currentPlayerColor == PieceColor.white
                    ? PieceColor.black
                    : PieceColor.white,
          ),
          depth: depth - 1,
          maximizingPlayer: true, // الآن دور لاعب التعظيم (AI)
          aiPlayerColor: aiPlayerColor,
        );

        if (evalResult.score < minEval) {
          minEval = evalResult.score;
          bestMove = move; // نحدثها هنا أيضًا لضمان اختيار حركة ما
        }
      }
      return (score: minEval, move: bestMove);
    }
  }

  /// دالة مساعدة للحصول على جميع الحركات القانونية للوحة معينة ولون لاعب معين.
  /// هذه نسخة من `getAllLegalMovesForCurrentPlayer` ولكنها تعمل على لوحة مُعطاة.
  List<Move> _getAllLegalMovesForBoard(Board board, PieceColor playerColor) {
    final List<Move> allLegalMoves = [];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == playerColor) {
          // نحتاج إلى الحصول على الحركات الأولية وتصفيتها بناءً على اللوحة المُعطاة
          final rawMoves = piece.getRawMoves(board, currentCell);
          final legalMovesForPiece =
              rawMoves.where((move) {
                return !isMoveResultingInCheck(board, move);
              }).toList();

          // إضافة حركات الكاستلينج القانونية
          if (piece.type == PieceType.king) {
            _addCastlingMovesForBoard(
              legalMovesForPiece,
              currentCell,
              piece.color,
              board,
            );
          }
          // إضافة حركات En Passant القانونية
          if (piece.type == PieceType.pawn) {
            _addEnPassantMovesForBoard(
              legalMovesForPiece,
              currentCell,
              piece.color,
              board,
            );
          }
          allLegalMoves.addAll(legalMovesForPiece);
        }
      }
    }
    return allLegalMoves;
  }

  /// نسخة من _addCastlingMoves تعمل على لوحة محددة (للمحاكاة).
  void _addCastlingMovesForBoard(
    List<Move> moves,
    Cell kingCell,
    PieceColor kingColor,
    Board boardToSimulate,
  ) {
    if (boardToSimulate.isKingInCheck(kingColor)) return;

    final int kingRow = kingColor == PieceColor.white ? 7 : 0;

    // King-side castling
    if (boardToSimulate.castlingRights[kingColor]![CastlingSide.kingSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 7);
      final Piece? rook = boardToSimulate.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          boardToSimulate.getPieceAt(Cell(row: kingRow, col: 5)) == null &&
          boardToSimulate.getPieceAt(Cell(row: kingRow, col: 6)) == null) {
        if (!boardToSimulate.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 5),
            ) &&
            !boardToSimulate.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 6),
            )) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 6),
              isCastling: true,
            ),
          );
        }
      }
    }

    // Queen-side castling
    if (boardToSimulate.castlingRights[kingColor]![CastlingSide.queenSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 0);
      final Piece? rook = boardToSimulate.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          boardToSimulate.getPieceAt(Cell(row: kingRow, col: 3)) == null &&
          boardToSimulate.getPieceAt(Cell(row: kingRow, col: 2)) == null &&
          boardToSimulate.getPieceAt(Cell(row: kingRow, col: 1)) == null) {
        if (!boardToSimulate.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 3),
            ) &&
            !boardToSimulate.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 2),
            )) {
          moves.add(
            Move(
              start: kingCell,
              end: Cell(row: kingRow, col: 2),
              isCastling: true,
            ),
          );
        }
      }
    }
  }

  /// نسخة من _addEnPassantMoves تعمل على لوحة محددة (للمحاكاة).
  void _addEnPassantMovesForBoard(
    List<Move> moves,
    Cell pawnCell,
    PieceColor pawnColor,
    Board boardToSimulate,
  ) {
    if (boardToSimulate.enPassantTarget == null) return;

    final int direction = pawnColor == PieceColor.white ? -1 : 1;
    final int targetRow = pawnCell.row + direction;

    final List<Cell> adjacentCells = [
      Cell(row: pawnCell.row, col: pawnCell.col - 1),
      Cell(row: pawnCell.row, col: pawnCell.col + 1),
    ];

    for (final adjacentCell in adjacentCells) {
      if (adjacentCell.isValid()) {
        final Piece? adjacentPiece = boardToSimulate.getPieceAt(adjacentCell);
        if (adjacentPiece is Pawn &&
            adjacentPiece.color != pawnColor &&
            boardToSimulate.enPassantTarget ==
                Cell(row: targetRow, col: adjacentCell.col) &&
            boardToSimulate.moveHistory.isNotEmpty) {
          final lastMove = boardToSimulate.moveHistory.last;
          if (lastMove.isTwoStepPawnMove && lastMove.end == adjacentCell) {
            moves.add(
              Move(
                start: pawnCell,
                end: boardToSimulate.enPassantTarget!,
                isEnPassant: true,
                isCapture: true,
              ),
            );
          }
        }
      }
    }
  }

  /// نسخة من checkGameEndConditions تعمل على لوحة محددة (للمحاكاة).
  GameResult _checkGameEndConditionsForBoard(Board boardToSimulate) {
    final currentPlayerColor = boardToSimulate.currentPlayer;

    final drawOutcome = _checkForDrawConditionsForBoard(boardToSimulate);
    if (drawOutcome != null) {
      if (drawOutcome == GameOutcome.draw) {
        return GameResult.draw(
          DrawReason.insufficientMaterial,
        ); // يجب تحديد السبب بدقة
      }
    }

    final bool kingInCheck = boardToSimulate.isKingInCheck(currentPlayerColor);
    final bool hasNoLegalMoves =
        !_hasAnyLegalMovesForBoard(boardToSimulate, currentPlayerColor);

    if (kingInCheck && hasNoLegalMoves) {
      final PieceColor winner =
          currentPlayerColor == PieceColor.white
              ? PieceColor.black
              : PieceColor.white;
      return GameResult.checkmate(winner);
    } else if (!kingInCheck && hasNoLegalMoves) {
      return GameResult.stalemate();
    } else if (drawOutcome == GameOutcome.draw) {
      return GameResult.draw(DrawReason.insufficientMaterial);
    }

    return GameResult.playing();
  }

  /// نسخة من checkForDrawConditions تعمل على لوحة محددة (للمحاكاة).
  GameOutcome? _checkForDrawConditionsForBoard(Board boardToSimulate) {
    if (_isInsufficientMaterialDrawForBoard(boardToSimulate)) {
      return GameOutcome.draw;
    }
    if (boardToSimulate.halfMoveClock >= 100) {
      return GameOutcome.draw;
    }
    // لا نتحقق من التكرار الثلاثي في Minimax لأنه مكلف جدًا ويحتاج إلى تاريخ اللوحة
    // بأكمله والذي قد لا يكون متاحًا في سياق المحاكاة الفردية.
    return null;
  }

  /// نسخة من _isInsufficientMaterialDraw تعمل على لوحة محددة (للمحاكاة).
  bool _isInsufficientMaterialDrawForBoard(Board boardToSimulate) {
    List<Piece> allPieces = [];
    for (var row in boardToSimulate.squares) {
      for (var piece in row) {
        if (piece != null) {
          allPieces.add(piece);
        }
      }
    }

    if (allPieces.length == 2 &&
        allPieces.every((p) => p.type == PieceType.king)) {
      return true;
    }

    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.any((p) => p.type == PieceType.bishop)) {
      return true;
    }

    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.any((p) => p.type == PieceType.knight)) {
      return true;
    }

    if (allPieces.length == 4 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.where((p) => p.type == PieceType.bishop).length == 2) {
      return true;
    }
    return false;
  }

  /// نسخة من hasAnyLegalMoves تعمل على لوحة محددة (للمحاكاة).
  bool _hasAnyLegalMovesForBoard(
    Board boardToSimulate,
    PieceColor playerColor,
  ) {
    return _getAllLegalMovesForBoard(boardToSimulate, playerColor).isNotEmpty;
  }
}
