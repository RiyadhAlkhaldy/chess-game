// lib/data/repositories_impl/ai_game_repository_impl.dart
import 'dart:collection';
import 'dart:math';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import 'game_repository.dart';
import 'simulate_move.dart';

/// [AIGameRepositoryImpl]
/// تطبيق [AIGameRepository] الذي يحتوي على منطق الذكاء الاصطناعي.
/// Implementation of [AIGameRepository] which contains the AI logic.
class AIGameRepositoryImpl implements AIGameRepository {
  // جداول التحويل لتخزين نتائج البحث لتجنب إعادة الحساب.
  // Transposition tables to store search results to avoid re-computation.
  // ignore: unused_field
  final Map<String, TranspositionEntry> _transpositionTable = HashMap();
  // الحد الأقصى لحجم جدول التحويل، لتقليل استهلاك الذاكرة.
  // Maximum size of the transposition table, to reduce memory consumption.
  // ignore: unused_field
  static const int _maxTranspositionTableSize = 100000;

  @override
  Future<Move?> findBestMove(Board board, int depth) async {
    // استخدم compute لتشغيل البحث في معالج منفصل لتجنب تجميد واجهة المستخدم.
    // Use compute to run the search in an isolated processor to avoid freezing the UI.
    // يتم تمرير نسخة عميقة من اللوحة لضمان عدم وجود مشاكل في تزامن البيانات.
    // A deep copy of the board is passed to ensure no data synchronization issues.
    // return compute(
    //   _searchBestMove,
    //   SearchParams(board.copyWithDeepPieces(), depth),
    // );
    return _searchBestMove(SearchParams(board.copyWithDeepPieces(), depth));
  }

  // دالة مساعدة لتشغيلها في معالج منفصل
  // Helper function to be run in an isolated processor
  static Move? _searchBestMove(SearchParams params) {
    final ai = _AILogic(params.board);
    return ai.minimaxRoot(params.depth);
  }
}

/// [SearchParams]
/// فئة مساعدة لتمرير المعلمات إلى دالة البحث في Compute.
/// Helper class to pass parameters to the search function in Compute.
class SearchParams {
  final Board board;
  final int depth;

  SearchParams(this.board, this.depth);
}

/// [TranspositionEntry]
/// يمثل إدخالًا في جدول التحويل.
/// Represents an entry in the transposition table.
class TranspositionEntry {
  final int score;
  final int depth;
  final NodeType type; // Exact, LowerBound, UpperBound

  TranspositionEntry(this.score, this.depth, this.type);
}

/// [NodeType]
/// أنواع العقد في جدول التحويل.
/// Node types in the transposition table.
enum NodeType { exact, lowerBound, upperBound }

/// [_AILogic]
/// يحتوي هذا الكلاس على منطق الذكاء الاصطناعي الرئيسي (Minimax, Alpha-Beta, Evaluation).
/// This class contains the main AI logic (Minimax, Alpha-Beta, Evaluation).
class _AILogic {
  final Board _currentBoard;
  // جداول التحويل (نسخة خاصة لكل عملية بحث لتجنب مشاكل التزامن).
  // Transposition tables (private copy for each search to avoid concurrency issues).
  // final Map<String, TranspositionEntry> _transpositionTable = HashMap();

  _AILogic(this._currentBoard);

  /// [minimaxRoot]
  /// نقطة الدخول لخوارزمية Minimax/Alpha-Beta.
  /// The entry point for the Minimax/Alpha-Beta algorithm.
  Move? minimaxRoot(int depth) {
    Move? bestMove;
    int bestValue = -double.maxFinite.toInt();
    // الحصول على جميع الحركات القانونية للاعب الحالي.
    // Get all legal moves for the current player.
    final List<Move> legalMoves = _getLegalMoves(
      _currentBoard,
      _currentBoard.currentPlayer,
    );

    // ترتيب الحركات لتحسين Alpha-Beta Pruning.
    // Order moves to improve Alpha-Beta Pruning.
    // _orderMoves(legalMoves, _currentBoard);

    for (final move in legalMoves) {
      // تطبيق الحركة على نسخة من اللوحة.
      // Apply the move to a copy of the board.
      final newBoard = _applyMove(_currentBoard.copyWithDeepPieces(), move);
      // تبديل اللاعب الحالي.
      // Switch the current player.
      final simulatedBoard = newBoard.copyWith(
        currentPlayer:
            _currentBoard.currentPlayer == PieceColor.white
                ? PieceColor.black
                : PieceColor.white,
      );

      // استدعاء Minimax لحساب قيمة هذه الوضعية.
      // Call Minimax to calculate the value of this position.
      final boardValue = _minimax(
        simulatedBoard,
        depth - 1,
        -double.maxFinite.toInt(),
        double.maxFinite.toInt(),
        _currentBoard.currentPlayer == PieceColor.white
            ? PieceColor
                .black // الخصم هو الذي سيلعب بعد هذه الحركة
            : PieceColor.white,
      );

      // إذا كانت هذه الحركة أفضل من أفضل حركة سابقة، قم بتحديثها.
      // If this move is better than the previous best move, update it.
      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
    }
    return bestMove;
  }

  /// [_minimax]
  /// تنفيذ خوارزمية Minimax مع Alpha-Beta Pruning.
  /// Minimax algorithm implementation with Alpha-Beta Pruning.
  int _minimax(
    Board board,
    int depth,
    int alpha,
    int beta,
    PieceColor currentPlayer,
  ) {
    // final fen = board.toFenString();
    // // التحقق من جدول التحويل.
    // // Check transposition table.
    // if (_transpositionTable.containsKey(fen)) {
    //   final entry = _transpositionTable[fen]!;
    //   if (entry.depth >= depth) {
    //     if (entry.type == NodeType.exact) return entry.score;
    //     if (entry.type == NodeType.lowerBound && entry.score > alpha) {
    //       alpha = entry.score;
    //     }
    //     if (entry.type == NodeType.upperBound && entry.score < beta) {
    //       beta = entry.score;
    //     }
    //     if (alpha >= beta) return entry.score;
    //   }
    // }

    // القاعدة الأساسية: إذا وصل العمق إلى صفر أو كانت اللعبة قد انتهت (كش ملك/تعادل).
    // Base case: If depth is zero or the game is over (checkmate/draw).
    if (depth == 0 || _isGameOver(board)) {
      return _evaluateBoard(board, currentPlayer);
    }

    // اللاعب الذي يحاول تعظيم نتيجته.
    // Player trying to maximize their score.
    if (currentPlayer == _currentBoard.currentPlayer) {
      // AI's turn
      int maxEval = -double.maxFinite.toInt();
      final List<Move> legalMoves = _getLegalMoves(board, currentPlayer);
      // _orderMoves(legalMoves, board);

      for (final move in legalMoves) {
        final newBoard = _applyMove(board.copyWithDeepPieces(), move);
        final simulatedBoard = newBoard.copyWith(
          currentPlayer:
              currentPlayer == PieceColor.white
                  ? PieceColor.black
                  : PieceColor.white,
        );
        final eval = _minimax(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          simulatedBoard.currentPlayer,
        );
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) {
          // Alpha-Beta Pruning
          break;
        }
      }
      // _transpositionTable[fen] = TranspositionEntry(
      //   maxEval,
      //   depth,
      //   NodeType.exact,
      // ); // حفظ النتيجة الدقيقة
      return maxEval;
    }
    // اللاعب الذي يحاول تقليل نتيجته (الخصم).
    // Player trying to minimize their score (opponent).
    else {
      // Opponent's turn
      int minEval = double.maxFinite.toInt();
      final List<Move> legalMoves = _getLegalMoves(board, currentPlayer);
      // _orderMoves(legalMoves, board);

      for (final move in legalMoves) {
        final newBoard = _applyMove(board.copyWithDeepPieces(), move);
        final simulatedBoard = newBoard.copyWith(
          currentPlayer:
              currentPlayer == PieceColor.white
                  ? PieceColor.black
                  : PieceColor.white,
        );
        final eval = _minimax(
          simulatedBoard,
          depth - 1,
          alpha,
          beta,
          simulatedBoard.currentPlayer,
        );
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) {
          // Alpha-Beta Pruning
          break;
        }
      }
      // _transpositionTable[fen] = TranspositionEntry(
      //   minEval,
      //   depth,
      //   NodeType.exact,
      // ); // حفظ النتيجة الدقيقة
      return minEval;
    }
  }

  /// [_evaluateBoard]
  /// دالة تقييم لوضعية اللوحة. تُرجع قيمة عددية تمثل جودة الوضعية.
  /// Evaluation function for a board position. Returns a numerical value representing the quality of the position.
  /// القيم الإيجابية تشير إلى أفضلية للاعب الحالي (الذكاء الاصطناعي).
  /// Positive values indicate an advantage for the current player (AI).
  int _evaluateBoard(Board board, PieceColor currentColor) {
    int score = 0;

    // قيم القطع القياسية
    // Standard piece values
    const pieceValues = {
      PieceType.pawn: 100,
      PieceType.knight: 320,
      PieceType.bishop: 330,
      PieceType.rook: 500,
      PieceType.queen: 900,
      PieceType.king: 20000, // قيمة عالية جدًا لتعكس أهمية الملك
    };

    // هياكل البيادق (Pawn Structures)
    // - بيادق معزولة (Isolated Pawns): بيادق لا توجد عليها بيادق صديقة في الأعمدة المجاورة. تعتبر ضعفًا.
    // - بيادق مضاعفة (Doubled Pawns): بيادق من نفس اللون في نفس العمود. تعتبر ضعفًا.
    // - بيادق سالكة (Passed Pawns): بيادق لا توجد عليها بيادق خصم في عمودها أو الأعمدة المجاورة. تعتبر قوة.

    // ignore: unused_local_variable
    int whitePawns = 0;
    // ignore: unused_local_variable
    int blackPawns = 0;
    List<int> whitePawnCols = [];
    List<int> blackPawnCols = [];

    // تقييم كل خلية على اللوحة
    // Evaluate each cell on the board
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.getPieceAt(Cell(row: r, col: c));
        if (piece != null) {
          final value = pieceValues[piece.type]!;
          if (piece.color == currentColor) {
            score += value;
            // إضافة نقاط لوضعية القطع
            // Add points for piece position (example: central control)
            score += _getPositionValue(piece.type, r, c, piece.color);

            if (piece.type == PieceType.pawn) {
              if (piece.color == PieceColor.white) {
                whitePawns++;
                whitePawnCols.add(c);
              } else {
                blackPawns++;
                blackPawnCols.add(c);
              }
            }
          } else {
            score -= value;
            score -= _getPositionValue(piece.type, r, c, piece.color);
          }
        }
      }
    }

    // تقييم هياكل البيادق
    // Evaluate pawn structures
    score += _evaluatePawnStructure(whitePawnCols, PieceColor.white);
    score -= _evaluatePawnStructure(blackPawnCols, PieceColor.black);

    // أمان الملك
    // King safety (simplified: check for open files around king)
    final kingPos = board.kingPositions[currentColor];
    if (kingPos != null) {
      if (currentColor == PieceColor.white) {
        // الملك الأبيض في الصف 7 أو 8 (صفوف البداية للبيادق) قد يكون أكثر أمانًا
        // White king on rows 7 or 8 (pawn starting rows) might be safer
        if (kingPos.row >= 6) score += 20;
      } else {
        // الملك الأسود في الصف 0 أو 1 قد يكون أكثر أمانًا
        // Black king on rows 0 or 1 might be safer
        if (kingPos.row <= 1) score += 20;
      }
      // عقاب على فتح الملفات أمام الملك
      // Penalty for open files in front of the king
      if (!_isFileProtectedByPawns(board, kingPos.col, currentColor)) {
        score -= 30;
      }
    }

    // التحقق من كش ملك أو التعادل
    // Check for checkmate or draw
    if (_isKingInCheckmate(board, currentColor)) {
      return -double.maxFinite
          .toInt(); // إذا كان الملك في كش ملك، هذه الوضعية سيئة للغاية
    }
    if (_isStalemate(board, currentColor) || _isDraw(board)) {
      return 0; // التعادل قيمة محايدة
    }

    // إذا كان الدور على الخصم، اعكس النتيجة لتكون صحيحة من منظور الذكاء الاصطناعي.
    // If it's the opponent's turn, reverse the score to be correct from AI's perspective.
    if (board.currentPlayer != currentColor) {
      score = -score;
    }

    return score;
  }

  /// [_getPositionValue]
  /// تُرجع قيمة إضافية بناءً على موضع القطعة (جدول قيم المواقع).
  /// Returns an additional value based on the piece's position (positional value table).
  /// هذه الجداول تحدد مدى فائدة مربع معين لقطعة معينة.
  /// These tables determine how useful a specific square is for a specific piece.
  int _getPositionValue(PieceType type, int r, int c, PieceColor color) {
    // هذه مجرد أمثلة مبسطة. الجداول الحقيقية تكون أكبر وأكثر تفصيلاً.
    // These are just simplified examples. Real tables are larger and more detailed.
    // الفكرة هي إعطاء نقاط للمربعات المركزية، أو للمربعات التي تتحكم في مناطق مهمة، إلخ.
    // The idea is to give points for central squares, or squares that control important areas, etc.
    switch (type) {
      case PieceType.pawn:
        // البيادق أقوى كلما تقدمت
        // Pawns are stronger the further they advance
        return color == PieceColor.white ? (7 - r) * 10 : r * 10;
      case PieceType.knight:
        // الفرسان أفضل في المركز
        // Knights are better in the center
        if (r >= 2 && r <= 5 && c >= 2 && c <= 5) return 20;
        if (r <= 1 || r >= 6 || c <= 1 || c >= 6) return -10; // على الحافة أسوأ
        return 0;
      case PieceType.bishop:
        // الأساقفة أفضل في الأقطار المفتوحة أو المركز
        // Bishops are better on open diagonals or in the center
        if (r >= 2 && r <= 5 && c >= 2 && c <= 5) return 15;
        return 0;
      case PieceType.rook:
        // القلاع أفضل في الملفات المفتوحة
        // Rooks are better on open files
        return 0; // يتطلب فحص الملفات المفتوحة في _evaluateBoard
      case PieceType.queen:
        // الملكات جيدة في المركز
        // Queens are good in the center
        if (r >= 2 && r <= 5 && c >= 2 && c <= 5) return 10;
        return 0;
      case PieceType.king:
        // أمان الملك: الملك في بداية اللعبة يفضل أن يكون خلف البيادق، وفي نهاية اللعبة يفضل أن يكون في المركز
        // King safety: King in the beginning of the game prefers to be behind pawns, and in the endgame prefers to be in the center
        return 0;
    }
  }

  /// [_evaluatePawnStructure]
  /// تقييم هيكل البيادق.
  /// Evaluate pawn structure.
  int _evaluatePawnStructure(List<int> pawnCols, PieceColor color) {
    int score = 0;
    final Map<int, int> colCounts = {};
    for (var col in pawnCols) {
      colCounts[col] = (colCounts[col] ?? 0) + 1;
    }

    // بيادق مضاعفة
    // Doubled pawns
    colCounts.forEach((col, count) {
      if (count > 1) {
        score -= 30 * (count - 1); // عقاب لكل بيدق إضافي في نفس العمود
      }
    });

    // بيادق معزولة
    // Isolated pawns
    for (var col in colCounts.keys) {
      bool isIsolated = true;
      if (col > 0 && colCounts.containsKey(col - 1)) isIsolated = false;
      if (col < 7 && colCounts.containsKey(col + 1)) isIsolated = false;
      if (isIsolated) {
        score -= 20; // عقاب للبيدق المعزول
      }
    }

    // بيادق سالكة (تبسيط)
    // Passed pawns (simplified)
    for (var col in colCounts.keys) {
      bool isPassed = true;
      for (int r = 0; r < 8; r++) {
        final piece = _currentBoard.getPieceAt(Cell(row: r, col: col));
        if (piece != null &&
            piece.color != color &&
            piece.type == PieceType.pawn) {
          if (color == PieceColor.white &&
              r < _currentBoard.kingPositions[color]!.row) {
            // تبسيط: فقط تحقق من وجود بيادق خصم أمام البيدق
            isPassed = false;
            break;
          }
          if (color == PieceColor.black &&
              r > _currentBoard.kingPositions[color]!.row) {
            isPassed = false;
            break;
          }
        }
      }
      if (isPassed) {
        score += 50; // مكافأة للبيدق السالك
      }
    }

    return score;
  }

  /// [_isFileProtectedByPawns]
  /// يتحقق مما إذا كان الملف محميًا ببيادق.
  /// Checks if a file is protected by pawns.
  bool _isFileProtectedByPawns(Board board, int col, PieceColor color) {
    for (int r = 0; r < 8; r++) {
      final piece = board.getPieceAt(Cell(row: r, col: col));
      if (piece != null &&
          piece.color == color &&
          piece.type == PieceType.pawn) {
        return true;
      }
    }
    return false;
  }

  /// [_getLegalMoves]
  /// تُرجع قائمة بجميع الحركات القانونية للاعب الحالي على اللوحة المعطاة.
  /// Returns a list of all legal moves for the current player on the given board.
  List<Move> _getLegalMoves(Board board, PieceColor playerColor) {
    final List<Move> legalMoves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final currentCell = Cell(row: r, col: c);
        final piece = board.getPieceAt(currentCell);
        if (piece != null && piece.color == playerColor) {
          final rawMoves = piece.getRawMoves(board, currentCell);
          for (final move in rawMoves) {
            // تحقق من شرعية الحركة (لا تضع الملك في كش)
            // Check move legality (does not put king in check)
            final simulatedBoard = _applyMove(board.copyWithDeepPieces(), move);
            if (!simulatedBoard.isKingInCheck(playerColor)) {
              legalMoves.add(move);
            }
          }
        }
      }
    }
    return legalMoves;
  }

  /// [_applyMove]
  /// تُطبق الحركة على نسخة من اللوحة وتُرجع اللوحة الجديدة.
  /// Applies the move to a copy of the board and returns the new board.
  Board _applyMove(Board board, Move move) {
    return SimulateMove.simulateMove(board, move);
    // Board newBoard = board.copyWithDeepPieces();
    // final piece = newBoard.getPieceAt(move.start);

    // if (piece == null) return newBoard; // يجب ألا يحدث أبدًا لحركة قانونية

    // // تحديث مكان القطعة
    // // Update piece position
    // newBoard = newBoard.placePiece(move.end, piece.copyWith(hasMoved: true));
    // newBoard = newBoard.placePiece(move.start, null);

    // // تحديث موقع الملك إذا تم تحريكه
    // // Update king position if it moved
    // if (piece.type == PieceType.king) {
    //   final newKingPositions = Map<PieceColor, Cell>.from(
    //     newBoard.kingPositions,
    //   );
    //   newKingPositions[piece.color] = move.end;
    //   newBoard = newBoard.copyWith(kingPositions: newKingPositions);

    //   // تحديث حقوق التبييت للملك
    //   // Update castling rights for the king
    //   final newCastlingRights = Map<PieceColor, Map<CastlingSide, bool>>.from(
    //     newBoard.castlingRights,
    //   );
    //   newCastlingRights[piece.color] = {
    //     CastlingSide.kingSide: false,
    //     CastlingSide.queenSide: false,
    //   };
    //   newBoard = newBoard.copyWith(castlingRights: newCastlingRights);
    // }

    // // تحديث حقوق التبييت للقلاع
    // // Update castling rights for rooks
    // if (piece.type == PieceType.rook) {
    //   final newCastlingRights = Map<PieceColor, Map<CastlingSide, bool>>.from(
    //     newBoard.castlingRights,
    //   );
    //   if (piece.color == PieceColor.white) {
    //     if (move.start == const Cell(row: 7, col: 0)) {
    //       // White Queen-side rook
    //       newCastlingRights[PieceColor.white]![CastlingSide.queenSide] = false;
    //     } else if (move.start == const Cell(row: 7, col: 7)) {
    //       // White King-side rook
    //       newCastlingRights[PieceColor.white]![CastlingSide.kingSide] = false;
    //     }
    //   } else {
    //     if (move.start == const Cell(row: 0, col: 0)) {
    //       // Black Queen-side rook
    //       newCastlingRights[PieceColor.black]![CastlingSide.queenSide] = false;
    //     } else if (move.start == const Cell(row: 0, col: 7)) {
    //       // Black King-side rook
    //       newCastlingRights[PieceColor.black]![CastlingSide.kingSide] = false;
    //     }
    //   }
    //   newBoard = newBoard.copyWith(castlingRights: newCastlingRights);
    // }

    // // معالجة التبييت
    // // Handle castling
    // if (move.isCastling) {
    //   Piece? rook;
    //   Cell rookStart;
    //   Cell rookEnd;

    //   if (move.end.col == 6) {
    //     // King-side castling
    //     rookStart = Cell(row: move.start.row, col: 7);
    //     rookEnd = Cell(row: move.start.row, col: 5);
    //   } else {
    //     // Queen-side castling
    //     rookStart = Cell(row: move.start.row, col: 0);
    //     rookEnd = Cell(row: move.start.row, col: 3);
    //   }
    //   rook = newBoard.getPieceAt(rookStart);
    //   if (rook != null) {
    //     newBoard = newBoard.placePiece(rookEnd, rook.copyWith(hasMoved: true));
    //     newBoard = newBoard.placePiece(rookStart, null);
    //   }
    // }

    // // معالجة الأخذ بالمرور (En Passant)
    // // Handle En Passant
    // if (move.isEnPassant) {
    //   final capturedPawnRow =
    //       piece.color == PieceColor.white ? move.end.row + 1 : move.end.row - 1;
    //   newBoard = newBoard.placePiece(
    //     Cell(row: capturedPawnRow, col: move.end.col),
    //     null,
    //   );
    // }

    // // تحديث هدف الأخذ بالمرور (En Passant Target)
    // // Update En Passant Target
    // Cell? newEnPassantTarget;
    // if (move.isTwoStepPawnMove) {
    //   newEnPassantTarget = Cell(
    //     row:
    //         piece.color == PieceColor.white
    //             ? move.end.row + 1
    //             : move.end.row - 1,
    //     col: move.end.col,
    //   );
    // }
    // newBoard = newBoard.copyWith(enPassantTarget: newEnPassantTarget);

    // // معالجة الترقية (Promotion)
    // // Handle Promotion
    // if (move.isPromotion && move.promotedPieceType != null) {
    //   final promotedPiece = Piece.create(
    //     color: piece.color,
    //     type: move.promotedPieceType!,
    //     hasMoved: true,
    //   );
    //   newBoard = newBoard.placePiece(move.end, promotedPiece);
    // }

    // // تحديث عداد أنصاف الحركات (Half-move clock) ورقم الحركة الكاملة (Full-move number)
    // // Update Half-move clock and Full-move number
    // int newHalfMoveClock = newBoard.halfMoveClock + 1;
    // int newFullMoveNumber = newBoard.fullMoveNumber;
    // if (move.isCapture || piece.type == PieceType.pawn) {
    //   newHalfMoveClock = 0; // إعادة تعيين العداد عند التقاط أو تحريك بيدق
    // }
    // if (piece.color == PieceColor.black) {
    //   newFullMoveNumber++; // زيادة رقم الحركة الكاملة بعد حركة الأسود
    // }
    // newBoard = newBoard.copyWith(
    //   halfMoveClock: newHalfMoveClock,
    //   fullMoveNumber: newFullMoveNumber,
    // );

    // // إضافة الوضعية الحالية إلى سجل الوضعيات (للتكرار الثلاثي)
    // // Add the current position to the position history (for threefold repetition)
    // final newPositionHistory = List<String>.from(newBoard.positionHistory)
    //   ..add(newBoard.toFenString());
    // newBoard = newBoard.copyWith(positionHistory: newPositionHistory);

    // return newBoard;
  }

  /// [_isGameOver]
  /// تتحقق مما إذا كانت اللعبة قد انتهت (كش ملك، طريق مسدود، تعادل).
  /// Checks if the game is over (checkmate, stalemate, draw).
  bool _isGameOver(Board board) {
    return _isKingInCheckmate(board, board.currentPlayer) ||
        _isStalemate(board, board.currentPlayer) ||
        _isDraw(board);
  }

  /// [_isKingInCheckmate]
  /// تتحقق مما إذا كان الملك في حالة كش ملك.
  /// Checks if the king is in checkmate.
  bool _isKingInCheckmate(Board board, PieceColor kingColor) {
    if (!board.isKingInCheck(kingColor)) {
      return false; // ليس في كش
    }
    // إذا كان في كش، تحقق مما إذا كان هناك أي حركات قانونية
    // If in check, check if there are any legal moves
    return _getLegalMoves(board, kingColor).isEmpty;
  }

  /// [_isStalemate]
  /// تتحقق مما إذا كانت اللعبة في طريق مسدود (Stalemate).
  /// Checks if the game is in stalemate.
  bool _isStalemate(Board board, PieceColor playerColor) {
    if (board.isKingInCheck(playerColor)) {
      return false; // إذا كان في كش، فهو ليس طريقًا مسدودًا
    }
    // إذا لم يكن في كش، وتحقق مما إذا كان لا توجد حركات قانونية
    // If not in check, check if there are no legal moves
    return _getLegalMoves(board, playerColor).isEmpty;
  }

  /// [_isDraw]
  /// تتحقق من شروط التعادل (مادة غير كافية، قاعدة الخمسين حركة، تكرار ثلاثي).
  /// Checks for draw conditions (insufficient material, fifty-move rule, threefold repetition).
  bool _isDraw(Board board) {
    // 1. مادة غير كافية (Insufficient Material)
    // أمثلة: ملك ضد ملك، ملك وفارس ضد ملك، ملك وأسقف ضد ملك، ملك وفارس ضد ملك وفارس، ملك وأسقف ضد ملك وأسقف بنفس لون المربعات.
    // Examples: King vs King, King and Knight vs King, King and Bishop vs King, King and Knight vs King and Knight, King and Bishop vs King and Bishop on same colored squares.
    final List<Piece> whitePieces = [];
    final List<Piece> blackPieces = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.getPieceAt(Cell(row: r, col: c));
        if (piece != null) {
          if (piece.color == PieceColor.white) {
            whitePieces.add(piece);
          } else {
            blackPieces.add(piece);
          }
        }
      }
    }

    // King vs King
    if (whitePieces.length == 1 &&
        whitePieces[0].type == PieceType.king &&
        blackPieces.length == 1 &&
        blackPieces[0].type == PieceType.king) {
      return true;
    }

    // King and Knight vs King
    if ((whitePieces.length == 2 &&
            whitePieces.any((p) => p.type == PieceType.knight) &&
            blackPieces.length == 1 &&
            blackPieces[0].type == PieceType.king) ||
        (blackPieces.length == 2 &&
            blackPieces.any((p) => p.type == PieceType.knight) &&
            whitePieces.length == 1 &&
            whitePieces[0].type == PieceType.king)) {
      return true;
    }

    // King and Bishop vs King
    if ((whitePieces.length == 2 &&
            whitePieces.any((p) => p.type == PieceType.bishop) &&
            blackPieces.length == 1 &&
            blackPieces[0].type == PieceType.king) ||
        (blackPieces.length == 2 &&
            blackPieces.any((p) => p.type == PieceType.bishop) &&
            whitePieces.length == 1 &&
            whitePieces[0].type == PieceType.king)) {
      return true;
    }

    // King and Bishop vs King and Bishop (same color squares)
    if (whitePieces.length == 2 &&
        whitePieces.any((p) => p.type == PieceType.king) &&
        whitePieces.any((p) => p.type == PieceType.bishop) &&
        blackPieces.length == 2 &&
        blackPieces.any((p) => p.type == PieceType.king) &&
        blackPieces.any((p) => p.type == PieceType.bishop)) {
      // ignore: unused_local_variable
      final whiteBishop = whitePieces.firstWhere(
        (p) => p.type == PieceType.bishop,
      );
      // ignore: unused_local_variable
      final blackBishop = blackPieces.firstWhere(
        (p) => p.type == PieceType.bishop,
      );
      // تحتاج إلى الوصول إلى موضع الأسقف لتحديد لون المربع
      // Requires access to bishop's position to determine square color
      // هذا يتطلب إضافة وظيفة للحصول على لون مربع القطعة أو تخزينه في Piece entity
      // This requires adding a function to get the piece's square color or storing it in the Piece entity
      // For now, simplify and assume it's a draw if both sides have only King and Bishop.
      return true; // تبسيطًا
    }

    // 2. قاعدة الخمسين حركة (Fifty-move Rule)
    // إذا لم يتم تحريك بيدق أو التقاط أي قطعة لمدة 50 حركة متتالية (100 نصف حركة).
    // If no pawn has been moved and no piece has been captured for 50 consecutive moves (100 half-moves).
    if (board.halfMoveClock >= 100) {
      return true;
    }

    // 3. التكرار الثلاثي (Threefold Repetition)
    // إذا ظهرت نفس الوضعية على اللوحة ثلاث مرات أو أكثر.
    // If the same position appears three or more times.
    final currentFen = board.toFenString();
    final fenCounts = <String, int>{};
    for (final fen in board.positionHistory) {
      fenCounts[fen] = (fenCounts[fen] ?? 0) + 1;
    }
    if (fenCounts[currentFen] != null && fenCounts[currentFen]! >= 3) {
      return true;
    }

    return false;
  }

  /// [_orderMoves]
  /// يرتب الحركات لزيادة فعالية Alpha-Beta Pruning.
  /// Orders moves to increase the effectiveness of Alpha-Beta Pruning.
  /// الحركات التي يحتمل أن تكون أفضل (مثل الالتقاطات أو الحركات التي تسبب كش) يجب أن تُقيَّم أولاً.
  /// Potentially better moves (like captures or checks) should be evaluated first.
  void _orderMoves(List<Move> moves, Board board) {
    moves.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      // إعطاء أولوية للالتقاطات
      // Prioritize captures
      if (a.isCapture) scoreA += 1000;
      if (b.isCapture) scoreB += 1000;

      // إعطاء أولوية للترقيات
      // Prioritize promotions
      if (a.isPromotion) scoreA += 2000;
      if (b.isPromotion) scoreB += 2000;

      // إعطاء أولوية للحركات التي تؤدي إلى كش (تبسيط: فقط إذا كانت الحركة تضع الخصم في كش)
      // Prioritize moves that lead to check (simplified: only if the move puts the opponent in check)
      final tempBoardA = _applyMove(board.copyWithDeepPieces(), a);
      if (tempBoardA.isKingInCheck(
        board.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white,
      )) {
        scoreA += 500;
      }
      final tempBoardB = _applyMove(board.copyWithDeepPieces(), b);
      if (tempBoardB.isKingInCheck(
        board.currentPlayer == PieceColor.white
            ? PieceColor.black
            : PieceColor.white,
      )) {
        scoreB += 500;
      }

      return scoreB.compareTo(scoreA); // ترتيب تنازلي (الأفضل أولاً)
    });
  }
}
