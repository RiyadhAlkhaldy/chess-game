// lib/data/repositories/game_repository_impl.dart
import 'dart:math';

import 'package:collection/collection.dart'; // لتسهيل مقارنة القوائم
import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/game_repository.dart';

/// تطبيق [GameRepository] الذي يحتوي على منطق لعبة الشطرنج الفعلي.
class GameRepositoryImpl implements GameRepository {
  Board currentBoard;
  List<Board> _boardHistory = []; // لتتبع تكرار اللوحة

  /// مُنشئ لـ [GameRepositoryImpl]. يبدأ اللعبة بلوحة أولية للاعب الأبيض.
  GameRepositoryImpl() : currentBoard = Board.initial() {
    _boardHistory.add(currentBoard);
  }

  @override
  Board getCurrentBoard() {
    return currentBoard;
  }

  @override
  List<Move> getLegalMoves(Cell cell) {
    final piece = currentBoard.getPieceAt(cell);
    if (piece == null || piece.color != currentBoard.currentPlayer) {
      return []; // لا توجد قطعة أو ليست قطعة اللاعب الحالي
    }

    // الحصول على الحركات الأولية للقطعة (بغض النظر عن الكش)
    final rawMoves = piece.getRawMoves(currentBoard, cell);

    // تصفية الحركات لإزالة تلك التي تضع الملك في كش
    final legalMoves =
        rawMoves.where((move) {
          // debugPrint("isMoveResultingInCheck $piece ");

          return !isMoveResultingInCheck(currentBoard, move);
        }).toList();
    // debugPrint("isMoveResultingInCheck 3 $legalMoves");

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
    if (kingColor != currentBoard.currentPlayer) return;
    if (currentBoard.isKingInCheck(kingColor)) {
      return; // لا يمكن الكاستلينج إذا كان الملك في كش
    }

    final int kingRow = kingColor == PieceColor.white ? 7 : 0;

    // الكاستلينج لجهة الملك (King-side Castling)
    if (currentBoard.castlingRights[kingColor]![CastlingSide.kingSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 7);
      final Piece? rook = currentBoard.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          currentBoard.getPieceAt(Cell(row: kingRow, col: 5)) == null &&
          currentBoard.getPieceAt(Cell(row: kingRow, col: 6)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 5),
            ) &&
            !currentBoard.isCellUnderAttack(
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
    if (currentBoard.castlingRights[kingColor]![CastlingSide.queenSide]!) {
      final Cell rookCell = Cell(row: kingRow, col: 0);
      final Piece? rook = currentBoard.getPieceAt(rookCell);

      if (rook is Rook &&
          !rook.hasMoved &&
          currentBoard.getPieceAt(Cell(row: kingRow, col: 3)) == null &&
          currentBoard.getPieceAt(Cell(row: kingRow, col: 2)) == null &&
          currentBoard.getPieceAt(Cell(row: kingRow, col: 1)) == null) {
        // التحقق من أن المربعات التي يمر بها الملك ليست مهددة
        if (!currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 3),
            ) &&
            !currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 2),
            ) &&
            !currentBoard.isCellUnderAttack(
              kingColor,
              Cell(row: kingRow, col: 1),
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
    if (currentBoard.enPassantTarget == null) return;

    final int direction = pawnColor == PieceColor.white ? -1 : 1;
    final int targetRow = pawnCell.row + direction;

    // تحقق من الخلايا المجاورة للبيدق لعملية الـ En Passant
    final List<Cell> adjacentCells = [
      Cell(row: pawnCell.row, col: pawnCell.col - 1),
      Cell(row: pawnCell.row, col: pawnCell.col + 1),
    ];

    for (final adjacentCell in adjacentCells) {
      if (adjacentCell.isValid()) {
        final Piece? adjacentPiece = currentBoard.getPieceAt(adjacentCell);
        if (adjacentPiece is Pawn &&
            adjacentPiece.color != pawnColor &&
            currentBoard.enPassantTarget ==
                Cell(row: targetRow, col: adjacentCell.col) &&
            currentBoard.moveHistory.isNotEmpty) {
          // التحقق مما إذا كانت الحركة الأخيرة هي حركة بيدق مزدوجة للبيدق المستهدف
          final lastMove = currentBoard.moveHistory.last;
          if (lastMove.isTwoStepPawnMove && lastMove.end == adjacentCell) {
            moves.add(
              Move(
                start: pawnCell,
                end: currentBoard.enPassantTarget!,
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
    Board newBoard = currentBoard.copyWithDeepPieces();
    final Piece? pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      debugPrint("خطأ: لا توجد قطعة في خلية البداية.");
      return currentBoard; // لا تفعل شيئًا إذا لم تكن هناك قطعة
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
        currentBoard.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

    newBoard = newBoard.copyWith(
      moveHistory: List.from(currentBoard.moveHistory)..add(move),
      currentPlayer: nextPlayer,
      enPassantTarget: newEnPassantTarget,
      castlingRights: newCastlingRights,
      kingPositions: newKingPositions,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
    );

    currentBoard = newBoard.copyWithDeepPieces();
    _boardHistory.add(currentBoard); // إضافة اللوحة الجديدة إلى سجل التاريخ

    return currentBoard;
  }

  @override
  bool isKingInCheck(PieceColor kingColor) {
    return currentBoard.isKingInCheck(kingColor);
  }

  @override
  GameResult getGameResult() {
    return checkGameEndConditions();
  }

  @override
  void resetGame() {
    currentBoard = Board.initial();
    _boardHistory = [currentBoard]; // إعادة تعيين تاريخ اللوحة أيضًا
  }

  @override
  Board simulateMove(Board board, Move move) {
    return SimulateMove.simulateMove(board, move);
  }

  @override
  bool isMoveResultingInCheck(Board board, Move move) {
    final simulatedBoard = simulateMove(board, move);
    // debugPrint(" is ${simulatedBoard == board}");
    // debugPrint("isMoveResultingInCheck 2 $move");
    // debugPrint(
    //   "isMoveResultingInCheck 2.5 ${simulatedBoard.currentPlayer.toString()} mm ${board.currentPlayer.toString()} mm",
    // )
    // التحقق من أن الملك الخاص باللاعب الذي قام بالحركة ليس في كش بعد الحركة.
    return simulatedBoard.isKingInCheck(board.currentPlayer);
  }

  @override
  List<Move> getAllLegalMovesForCurrentPlayer() {
    final List<Move> allLegalMoves = [];
    final currentPlayerColor = currentBoard.currentPlayer;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = currentBoard.getPieceAt(currentCell);
        if (piece != null && piece.color == currentPlayerColor) {
          final legalmoves = getLegalMoves(currentCell);
          if (legalmoves.isNotEmpty) {
            allLegalMoves.addAll(legalmoves);
          }
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
    final originalCurrentPlayer = currentBoard.currentPlayer;
    currentBoard = currentBoard.copyWith(currentPlayer: playerColor);

    final bool hasMoves = getAllLegalMovesForCurrentPlayer().isNotEmpty;

    // استعادة اللاعب الحالي الأصلي
    currentBoard = currentBoard.copyWith(currentPlayer: originalCurrentPlayer);
    return hasMoves;
  }

  /// التحقق من التعادل بتكرار الوضعية ثلاث مرات.
  /// يحدث عندما تظهر نفس الوضعية ثلاث مرات على الأقل في سجل اللعبة.
  // bool _isThreefoldRepetition() {
  //   if (_boardHistory.length < 5) {
  //     return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (حركتان لكل لاعب + اللوحة الحالية)
  //   }
  //   final currentFen = currentBoard.toFenString();
  //   int count = 0;
  //   for (final fen in currentBoard.positionHistory) {
  //     if (fen == currentFen) {
  //       count++;
  //     }
  //   }
  //   return count >= 3;
  // }

  // @override
  // GameResult checkGameEndConditions() {
  //   final currentPlayerColor = currentBoard.currentPlayer;
  //   // 1. تحقق من التعادل أولاً
  //   final drawOutcome = checkForDrawConditions();

  //   if (drawOutcome != null) {
  //     return drawOutcome;
  //   }

  //   // return GameResult.playing();
  //   // 2. تحقق من كش ملك / طريق مسدود
  //   final bool kingInCheck = isKingInCheck(currentPlayerColor);
  //   final bool hasNoLegalMoves = !hasAnyLegalMoves(currentPlayerColor);
  //   if (!kingInCheck && hasNoLegalMoves) {
  //     // طريق مسدود
  //     return GameResult.stalemate();
  //   }
  //   if (kingInCheck && hasNoLegalMoves) {
  //     // كش ملك
  //     final PieceColor winner =
  //         currentPlayerColor == PieceColor.white
  //             ? PieceColor.black
  //             : PieceColor.white;
  //     return GameResult.checkmate(winner);
  //   }

  //   return GameResult.playing(); // اللعبة ما زالت مستمرة
  // }

  // @override
  // GameResult? checkForDrawConditions() {
  //   // 2. التكرار الثلاثي
  //   if (_isThreefoldRepetition()) {
  //     return GameResult.draw(DrawReason.threefoldRepetition);
  //   }

  //   return CheckDrawUseCaseImpl().execute(currentBoard);

  //   // يمكنك إضافة التعادل بالاتفاق هنا، لكنه يتطلب مدخلات من المستخدم
  //   // return null; // لا يوجد تعادل حاليًا
  // }

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
  ///
  ///
  ///
  ///

  @override
  GameResult checkGameEndConditions() {
    final currentPlayerColor =
        currentBoard.currentPlayer; // استخدام _currentBoard

    // 1. تحقق أولاً من وجود حركات قانونية
    final bool hasNoLegalMoves = !hasAnyLegalMoves(currentPlayerColor);
    final bool kingInCheck = isKingInCheck(currentPlayerColor);
    // return GameResult.stalemate();

    if (hasNoLegalMoves) {
      if (kingInCheck) {
        // كش ملك
        final PieceColor winner =
            currentPlayerColor == PieceColor.white
                ? PieceColor.black
                : PieceColor.white;
        return GameResult.checkmate(winner);
      } else {
        // طريق مسدود (لا يوجد كش ملك ولا حركات قانونية)
        return GameResult.stalemate();
      }
    }

    // 2. إذا كان هناك حركات قانونية، تحقق من شروط التعادل الأخرى
    final DrawReason? drawReason = checkForDrawConditions();
    if (drawReason != null) {
      return GameResult.draw(drawReason);
    }

    // 3. إذا لم يتم تحديد أي نهاية للعبة، فاللعبة مستمرة
    return GameResult.playing();
  }

  // lib/data/repositories/game_repository_impl.dart

  // ... (الاستيرادات وبقية الكود) ...

  @override
  DrawReason? checkForDrawConditions() {
    // 1. التعادل بالمواد غير الكافية
    if (_isInsufficientMaterialDraw()) {
      return DrawReason.insufficientMaterial;
    }

    // 2. قاعدة الخمسين حركة
    if (currentBoard.halfMoveClock >= 100) {
      return DrawReason.fiftyMoveRule;
    }

    // 3. التكرار الثلاثي
    if (_isThreefoldRepetition()) {
      return DrawReason.threefoldRepetition;
    }

    // التعادل بالاتفاق لا يتم التحقق منه هنا لأنه يتطلب تفاعل المستخدم
    return null; // لا يوجد تعادل حاليًا من القواعد
  }

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
  static const int _maxMinimaxDepth = 3; // مثال: 3 حركات للأمام

  @override
  Future<Move?> getAiMove(
    Board board,
    PieceColor aiPlayerColor,
    int aiDepth,
  ) async {
    if (!hasAnyLegalMoves(aiPlayerColor)) {
      return null;
    }

    // تشغيل خوارزمية Minimax مع قيم ألفا وبيتا الأولية
    final result = await _minimax(
      board: board.copyWith(currentPlayer: aiPlayerColor),
      depth: aiDepth,
      maximizingPlayer: true,
      aiPlayerColor: aiPlayerColor,
      alpha: -double.maxFinite.toInt(), // قيمة ألفا الأولية
      beta: double.maxFinite.toInt(), // قيمة بيتا الأولية
    );

    return result.move;
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
          // إضافة قيمة القطعة إذا كانت للذكاء الاصطناعي، وطرحها إذا كانت للخصم
          if (piece.color == aiPlayerColor) {
            score += pieceValue;
          } else {
            score -= pieceValue;
          }
        }
      }
    }

    // إضافة مكافأة بسيطة لأمان الملك إذا لم يكن في كش
    if (!board.isKingInCheck(aiPlayerColor)) {
      score += 50;
    }
    if (!board.isKingInCheck(
      aiPlayerColor == PieceColor.white ? PieceColor.black : PieceColor.white,
    )) {
      score -= 50; // خصم إذا لم يكن ملك الخصم في كش
    }

    // مكافأة للسيطرة على المركز (يمكن أن تكون أكثر تعقيدًا)
    // على سبيل المثال، مربعات d4, e4, d5, e5 تعتبر مربعات مركزية
    final centerCells = [
      const Cell(row: 3, col: 3),
      const Cell(row: 3, col: 4),
      const Cell(row: 4, col: 3),
      const Cell(row: 4, col: 4),
    ];
    for (var cell in centerCells) {
      final piece = board.getPieceAt(cell);
      if (piece != null) {
        if (piece.color == aiPlayerColor) {
          score += 10;
        } else {
          score -= 10;
        }
      }
    }

    return score;
  }

  /// تنفيذ خوارزمية Minimax مع تقليم ألفا-بيتا.
  /// [board]: اللوحة الحالية.
  /// [depth]: العمق المتبقي للبحث.
  /// [maximizingPlayer]: صحيح إذا كان اللاعب الحالي هو لاعب التعظيم (AI).
  /// [aiPlayerColor]: لون قطع الذكاء الاصطناعي.
  /// [alpha]: أفضل قيمة (الحد الأدنى) تم العثور عليها حتى الآن في مسار لاعب التعظيم.
  /// [beta]: أفضل قيمة (الحد الأقصى) تم العثور عليها حتى الآن في مسار لاعب التقليل.
  Future<({int score, Move? move})> _minimax({
    required Board board,
    required int depth,
    required bool maximizingPlayer,
    required PieceColor aiPlayerColor,
    required int alpha,
    required int beta,
  }) async {
    // 1. حالة القاعدة (Base Case):
    // إذا وصلنا إلى أقصى عمق للبحث أو كانت اللعبة قد انتهت.
    if (depth == 0) {
      return (score: _evaluateBoard(board, aiPlayerColor), move: null);
    }

    // تحقق من نهاية اللعبة مبكرًا
    final gameOutcome = _checkGameEndConditionsForBoard(board).outcome;
    if (gameOutcome != GameOutcome.playing) {
      if (gameOutcome == GameOutcome.checkmate) {
        // إذا كان هناك كش ملك، فإن الفائز هو من ليس دوره
        final winnerIsAI =
            (gameOutcome == GameOutcome.checkmate &&
                board.currentPlayer != aiPlayerColor);
        return (
          score:
              winnerIsAI ? double.maxFinite.toInt() : -double.maxFinite.toInt(),
          move: null,
        );
      } else if (gameOutcome == GameOutcome.stalemate ||
          gameOutcome == GameOutcome.draw) {
        return (score: 0, move: null); // التعادل له قيمة 0
      }
    }

    final currentPlayerColor = board.currentPlayer;
    final List<Move> legalMovesForBoard = _getAllLegalMovesForBoard(
      board,
      currentPlayerColor,
    );

    // إذا لم يكن هناك حركات قانونية في هذا العمق، ارجع التقييم الحالي.
    if (legalMovesForBoard.isEmpty) {
      final currentOutcome = _checkGameEndConditionsForBoard(board);
      if (currentOutcome.outcome == GameOutcome.checkmate) {
        final winnerIsAI = (currentOutcome.winner == aiPlayerColor);
        return (
          score:
              winnerIsAI ? double.maxFinite.toInt() : -double.maxFinite.toInt(),
          move: null,
        );
      } else if (currentOutcome.outcome == GameOutcome.stalemate) {
        return (score: 0, move: null);
      }
      return (score: _evaluateBoard(board, aiPlayerColor), move: null);
    }

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
          alpha: alpha,
          beta: beta,
        );

        if (evalResult.score > maxEval) {
          maxEval = evalResult.score;
          bestMove = move;
        }
        alpha = max(alpha, evalResult.score); // تحديث ألفا
        if (beta <= alpha) {
          break; // تقليم بيتا
        }
      }
      return (score: maxEval, move: bestMove);
    } else {
      // لاعب التقليل (الخصم): يحاول تقليل النتيجة إلى أقصى حد
      int minEval = double.maxFinite.toInt();
      Move?
      bestMove; // يتم الاحتفاظ بها لأغراض التتبع إذا لزم الأمر، ولكنها غير مستخدمة لاختيار حركة AI

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
          alpha: alpha,
          beta: beta,
        );

        if (evalResult.score < minEval) {
          minEval = evalResult.score;
          bestMove = move;
        }
        beta = min(beta, evalResult.score); // تحديث بيتا
        if (beta <= alpha) {
          break; // تقليم ألفا
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
    List<Piece?> allPieces = [];
    List<Cell> bishopPositions = []; // لتتبع مواقع الأساقفة

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = boardToSimulate.squares[r][c];
        if (piece != null) {
          allPieces.add(piece);
          if (piece.type == PieceType.bishop) {
            bishopPositions.add(Cell(row: r, col: c));
          }
        }
      }
    }

    // إزالة القطع null لتبسيط العد
    final nonNullPieces = allPieces.whereNotNull().toList();

    // الملك مقابل الملك (فقط ملكان على اللوحة)
    if (nonNullPieces.length == 2 &&
        nonNullPieces.every((p) => p.type == PieceType.king)) {
      return true;
    }

    // الملك والأسقف مقابل الملك
    // الملك والحصان مقابل الملك
    if (nonNullPieces.length == 3) {
      final kings =
          nonNullPieces.where((p) => p.type == PieceType.king).toList();
      final minorPieces =
          nonNullPieces
              .where(
                (p) => p.type == PieceType.bishop || p.type == PieceType.knight,
              )
              .toList();

      if (kings.length == 2 && minorPieces.length == 1) {
        return true; // تعادل تلقائي إذا كان هناك ملكان وقطعة ثانوية واحدة فقط (أسقف أو حصان)
      }
    }

    // الملك والأسقف مقابل الملك والأسقف (على نفس لون المربعات)
    if (nonNullPieces.length == 4 &&
        nonNullPieces.where((p) => p.type == PieceType.king).length == 2 &&
        nonNullPieces.where((p) => p.type == PieceType.bishop).length == 2) {
      // تحقق من أن كلا الأسقفين على نفس لون المربعات
      if (bishopPositions.length == 2) {
        final bishop1 =
            boardToSimulate.getPieceAt(bishopPositions[0]) as Bishop;
        final bishop2 =
            boardToSimulate.getPieceAt(bishopPositions[1]) as Bishop;

        // الأساقفة على نفس لون المربعات إذا كانت (كلاهما فاتح) أو (كلاهما داكن)
        final bool areBothLight =
            bishopPositions[0].isLightSquare() &&
            bishopPositions[1].isLightSquare();
        final bool areBothDark =
            bishopPositions[0].isDarkSquare() &&
            bishopPositions[1].isDarkSquare();

        if (areBothLight || areBothDark) {
          return true;
        }
      }
    }

    // يمكن إضافة المزيد من حالات المواد غير الكافية هنا (مثل ملكين وحصانين).
    // الملك وحصانين ضد الملك: عادة ما تكون تعادلًا، ولكن يمكن أن تكون فوزًا نادرًا
    // لذا من الأفضل عدم تضمينها كتعادل تلقائي إلا إذا كان هناك تحليل أعمق.

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

extension CheckGameConditions on GameRepositoryImpl {
  /// يتحقق مما إذا كانت اللوحة الحالية قد تكررت ثلاث مرات.
  // bool _isThreefoldRepetition() {
  //   if (_boardHistory.length < 5) {
  //     return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (حركتان لكل لاعب + اللوحة الحالية)
  //   }

  //   final currentBoardFEN = _boardToFEN(currentBoard);
  //   int count = 0;
  //   for (int i = 0; i < _boardHistory.length; i++) {
  //     if (_boardToFEN(_boardHistory[i]) == currentBoardFEN) {
  //       count++;
  //     }
  //   }
  //   return count >= 3;
  // }

  /// دالة مساعدة لتحويل حالة اللوحة إلى تمثيل FEN مبسط
  /// يستخدم لمقارنة اللوحات لتحديد التكرار الثلاثي.
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
    fen +=
        ' ${board.enPassantTarget == null ? '-' : String.fromCharCode(97 + board.enPassantTarget!.col) + (8 - board.enPassantTarget!.row).toString()}';
    fen +=
        ' ${board.halfMoveClock}'; // قاعدة الخمسين حركة لا تُعاد تعيينها عند التكرار الثلاثي، ولكنها جزء من FEN
    fen += ' ${board.fullMoveNumber}';

    return fen;
  }

  // lib/data/repositories/game_repository_impl.dart

  // دالة مساعدة لإنشاء "مفتاح موقف" (FEN بدون عدادات الحركة)
  String _boardToPositionKey2(Board board) {
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

    fen +=
        ' ${board.enPassantTarget == null ? '-' : String.fromCharCode(97 + board.enPassantTarget!.col) + (8 - board.enPassantTarget!.row).toString()}';

    return fen;
  }

  // lib/data/repositories/game_repository_impl.dart

  // ... (الاستيرادات وبقية الكود) ...

  /// دالة مساعدة لإنشاء "مفتاح موقف" (FEN بدون عدادات الحركة).
  /// تُستخدم للتحقق من التكرار الثلاثي.
  String _boardToPositionKey(Board board) {
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

    // إضافة معلومات اللاعب الحالي وحقوق الكاستلينج وحركة الـ En Passant
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

    fen +=
        ' ${board.enPassantTarget == null ? '-' : String.fromCharCode(97 + board.enPassantTarget!.col) + (8 - board.enPassantTarget!.row).toString()}';

    return fen;
  }

  /// يتحقق مما إذا كانت اللوحة الحالية قد تكررت ثلاث مرات.
  bool _isThreefoldRepetition() {
    if (_boardHistory.length < 5) {
      return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (3 مواقف متطابقة على الأقل)
    }

    // استخدام _boardToPositionKey للحصول على مفتاح الموقف
    final currentPositionKey = _boardToPositionKey(currentBoard);
    int count = 0;

    // ابحث في سجل اللوحات (باستخدام مفتاح الموقف فقط)
    for (final boardInHistory in _boardHistory) {
      if (_boardToPositionKey(boardInHistory) == currentPositionKey) {
        count++;
      }
    }
    // إذا كان العدد 3 أو أكثر، فإنها تعادل.
    return count >= 4;
  }

  /// يتحقق مما إذا كانت اللوحة الحالية قد تكررت ثلاث مرات.
  // bool _isThreefoldRepetition() {
  //   if (_boardHistory.length < 5) return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (3 مواقف متطابقة على الأقل)

  //   final currentPositionKey = _boardToPositionKey(currentBoard);
  //   int count = 0;

  //   // ابحث في سجل اللوحات (نبدأ من بداية السجل ونقارن مفتاح الموقف فقط)
  //   for (final boardInHistory in _boardHistory) {
  //     if (_boardToPositionKey(boardInHistory) == currentPositionKey) {
  //       count++;
  //     }
  //   }
  //   // إذا كان العدد 3 أو أكثر، فإنها تعادل.
  //   return count >= 3;
  // }
  /// يتحقق مما إذا كانت حالة اللعبة هي تعادل بسبب المواد غير الكافية.
  /// (الملك مقابل الملك، الملك والأسقف مقابل الملك، الملك والحصان مقابل الملك).
  // lib/data/repositories/game_repository_impl.dart

  // ... (الاستيرادات وبقية الكود) ...

  /// يتحقق مما إذا كانت حالة اللعبة هي تعادل بسبب المواد غير الكافية.
  bool _isInsufficientMaterialDraw() {
    List<Piece> allPieces = [];
    Map<Piece, Cell> piecePositions = {}; // لتخزين القطع ومواقعها

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = currentBoard.squares[r][c];
        if (piece != null) {
          allPieces.add(piece);
          piecePositions[piece] = Cell(row: r, col: c);
        }
      }
    }

    // إذا كان هناك ملكان فقط
    if (allPieces.length == 2 &&
        allPieces.every((p) => p.type == PieceType.king)) {
      return true; // ملك مقابل ملك
    }

    // الملك والأسقف مقابل الملك
    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.where((p) => p.type == PieceType.bishop).length == 1) {
      return true;
    }

    // الملك والحصان مقابل الملك
    if (allPieces.length == 3 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.where((p) => p.type == PieceType.knight).length == 1) {
      return true;
    }

    // الملك والأسقف مقابل الملك والأسقف (على نفس لون المربعات)
    if (allPieces.length == 4 &&
        allPieces.where((p) => p.type == PieceType.king).length == 2 &&
        allPieces.where((p) => p.type == PieceType.bishop).length == 2) {
      // الحصول على الأساقفة ومواقعهم
      final List<Piece> bishops =
          allPieces.where((p) => p.type == PieceType.bishop).toList();
      final Cell? bishop1Cell = piecePositions[bishops[0]];
      final Cell? bishop2Cell = piecePositions[bishops[1]];

      if (bishop1Cell != null && bishop2Cell != null) {
        // استخدام الامتداد CellColor للتحقق من لون المربع
        final bool bishop1IsLight = bishop1Cell.isLightSquare();
        final bool bishop2IsLight = bishop2Cell.isLightSquare();

        // تعادل إذا كان كلا الأسقفين على نفس لون المربعات
        return (bishop1IsLight && bishop2IsLight) ||
            (!bishop1IsLight && !bishop2IsLight);
      }
    }

    // يمكن إضافة المزيد من حالات المواد غير الكافية هنا إذا لزم الأمر
    // مثال: ملك وحصانين مقابل ملك (غالباً ما تكون تعادل، لكن يمكن أن تكون فوزًا نادرًا)
    // لا يتم تضمينها كتعادل تلقائي بشكل عام لأنها تتطلب تحليلاً أعمق.

    return false;
  }
}

class SimulateMove {
  static Board simulateMove(Board board, Move move) {
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
}
