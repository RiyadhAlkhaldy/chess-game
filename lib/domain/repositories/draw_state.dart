import '../entities/board.dart';
import '../entities/cell.dart';
import '../entities/move.dart';
import '../entities/piece.dart';

class DrawState {
  static isInsufficientMaterialDraw(Board board) {
    final whitePieces = <Piece>[];
    final blackPieces = <Piece>[];

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

    // حالات عدم كفاية المواد الشائعة:
    // 1. ملك ضد ملك (K vs K)
    if (whitePieces.length == 1 &&
        whitePieces[0].type == PieceType.king &&
        blackPieces.length == 1 &&
        blackPieces[0].type == PieceType.king) {
      return true;
    }

    // 2. ملك وفيل ضد ملك (K + B vs K)
    if (whitePieces.length == 2 &&
        whitePieces.any((p) => p.type == PieceType.king) &&
        whitePieces.any((p) => p.type == PieceType.bishop) &&
        blackPieces.length == 1 &&
        blackPieces[0].type == PieceType.king) {
      return true;
    }
    if (blackPieces.length == 2 &&
        blackPieces.any((p) => p.type == PieceType.king) &&
        blackPieces.any((p) => p.type == PieceType.bishop) &&
        whitePieces.length == 1 &&
        whitePieces[0].type == PieceType.king) {
      return true;
    }

    // 3. ملك وحصان ضد ملك (K + N vs K)
    if (whitePieces.length == 2 &&
        whitePieces.any((p) => p.type == PieceType.king) &&
        whitePieces.any((p) => p.type == PieceType.knight) &&
        blackPieces.length == 1 &&
        blackPieces[0].type == PieceType.king) {
      return true;
    }
    if (blackPieces.length == 2 &&
        blackPieces.any((p) => p.type == PieceType.king) &&
        blackPieces.any((p) => p.type == PieceType.knight) &&
        whitePieces.length == 1 &&
        whitePieces[0].type == PieceType.king) {
      return true;
    }

    // 4. ملك وفيل ضد ملك وفيل، إذا كان الفيلان على نفس لون المربعات (K + B vs K + B on same color squares)
    if (whitePieces.length == 2 &&
        whitePieces.any((p) => p.type == PieceType.king) &&
        whitePieces.any((p) => p.type == PieceType.bishop) &&
        blackPieces.length == 2 &&
        blackPieces.any((p) => p.type == PieceType.king) &&
        blackPieces.any((p) => p.type == PieceType.bishop)) {
      final whiteBishop = whitePieces.firstWhere(
        (p) => p.type == PieceType.bishop,
      );
      final blackBishop = blackPieces.firstWhere(
        (p) => p.type == PieceType.bishop,
      );

      // للتحقق من لون مربع الفيل، نحتاج إلى معرفة مكان الفيل على اللوحة
      // هذا يتطلب تمرير اللوحة أو البحث عن مكان الفيل.
      // هنا سنفترض أننا يمكننا العثور على الخلايا الخاصة بالأساقفة.
      // هذا الجزء معقد قليلاً لأن الـ `whitePieces` لا تحتوي على معلومات الخلية.
      // ************************************************************************
      // هذا يتطلب تعديلًا في كيفية جمع القطع أو طريقة للعثور على موقعها.
      // ************************************************************************

      // حل مؤقت: البحث عن الفيل على اللوحة لتحديد لون مربعه
      Cell? whiteBishopCell;
      Cell? blackBishopCell;

      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          final cell = Cell(row: r, col: c);
          final piece = board.getPieceAt(cell);
          if (piece != null) {
            if (piece.color == PieceColor.white &&
                piece.type == PieceType.bishop) {
              whiteBishopCell = cell;
            } else if (piece.color == PieceColor.black &&
                piece.type == PieceType.bishop) {
              blackBishopCell = cell;
            }
          }
        }
      }

      if (whiteBishopCell != null && blackBishopCell != null) {
        final isWhiteBishopOnDarkSquare =
            (whiteBishopCell.row + whiteBishopCell.col) % 2 == 1;
        final isBlackBishopOnDarkSquare =
            (blackBishopCell.row + blackBishopCell.col) % 2 == 1;

        if (isWhiteBishopOnDarkSquare == isBlackBishopOnDarkSquare) {
          return true; // الفيلان على نفس لون المربعات
        }
      }
    }

    return false; // مواد كافية (أو حالات أخرى غير مغطاة هنا)
  }

  /// التحقق من التعادل بالردب (Stalemate)
  /// يحدث عندما لا يكون اللاعب الحالي في كش، ولكن ليس لديه أي نقلات قانونية.
  static bool isStalemate(Board board) {
    // إذا كان الملك في كش، فليست حالة ردب، بل كش ملك محتمل أو يجب إيقافه
    if (board.isKingInCheck(board.currentPlayer)) {
      return false;
    }

    // تحقق مما إذا كان هناك أي نقلات قانونية للاعب الحالي
    // يتطلب هذا محاكاة جميع النقلات المحتملة لكل قطعة للاعب الحالي
    // ويجب أن يتم تنفيذ منطق getLegalMoves في طبقة أعلى (مثل GameRepositoryImpl)
    // هنا، سنفترض أن هذه الوظيفة ستتلقى جميع النقلات القانونية الممكنة للاعب الحالي
    // وتتحقق مما إذا كان هناك أي منها.
    // بما أننا في طبقة Domain، لن نتمكن من الوصول مباشرة إلى GameRepositoryImpl
    // لذلك، سنحتاج إلى تمرير طريقة للحصول على النقلات القانونية أو افتراض وجودها.
    // للأغراض التجريبية، سنفترض أن board يمكنها تزويدنا بالنقلات القانونية.
    // ************************************************************************
    // هذا الجزء يتطلب دمجًا مع منطق اللعبة العام (GameRepositoryImpl)
    // حيث أن حساب "النقلات القانونية" يتضمن التحقق من عدم وضع الملك في كش.
    // الحل الأبسط هنا هو أن تتحقق طبقة الـ "Application/Presentation"
    // من هذا الشرط بعد الحصول على جميع النقلات المحتملة للوحة.
    // لكن لكي نتبع Clean Architecture، سنحتاج إلى طريقة لتمرير هذه الوظيفة.
    // ************************************************************************

    // حل مؤقت: سنفترض أن هناك طريقة ما لحساب جميع "النقلات القانونية"
    // وهذا سيتطلب الوصول إلى جميع قطع اللاعب الحالي وحساب نقلاتها.
    // في التطبيق الفعلي، هذه العملية تكون مكلفة وقد تحتاج إلى تحسين.
    // لن نقوم بحساب جميع النقلات هنا في الـ `UseCase` لعدم كسر مبدأ فصل الاهتمامات.
    // بدلاً من ذلك، سنفترض أن الـ `GameController` سيزود الـ `UseCase`
    // بمعلومة إذا كان هناك أي نقلات قانونية.

    // **ملاحظة:** للتبسيط، سأفترض أن هذا المنطق سيتم استدعاؤه بعد حساب
    // جميع النقلات القانونية الممكنة للاعب الحالي.
    // إذا لم تكن هناك نقلات قانونية، فهو ردب.
    // هذا المنطق يجب أن يكون في `GameController` أو `GameRepositoryImpl`
    // الذي يستدعي `CheckDrawUseCase`.

    // لغرض العرض، سنضع منطقًا مبسطًا هنا، ولكن يجب أن يتم التعامل معه بشكل أفضل:
    final currentPlayersPieces = <Cell, Piece>{};
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final cell = Cell(row: r, col: c);
        final piece = board.getPieceAt(cell);
        if (piece != null && piece.color == board.currentPlayer) {
          currentPlayersPieces[cell] = piece;
        }
      }
    }

    // إذا لم يتمكن أي من قطع اللاعب الحالي من القيام بأي نقلة قانونية
    // (بمعنى أن جميع النقلات المحتملة تضع الملك في كش أو لا توجد نقلات)
    // فهذه الحالة هي "ردب".
    // هذا الفحص يجب أن يتم بعد التحقق من شرعية جميع النقلات المحتملة.
    // سأضع هنا منطقًا "غير دقيق" لأغراض التوضيح، لأنه يتطلب منطق الـ GameRepositoryImpl.
    // **الحل الصحيح سيكون أن الـ GameRepositoryImpl تحسب جميع النقلات القانونية
    // وتمرر العدد أو وجودها إلى CheckDrawUseCase.**

    // مؤقتًا، للوضوح في هذا السياق:
    // إذا لم يكن الملك في كش، وليس هناك أي نقلة قانونية، فهو ردب.
    // هذه الوظيفة (_hasAnyLegalMoves) ستكون معقدة وتتطلب الوصول إلى منطق اللعبة بالكامل
    // (محاكاة كل نقلة والتحقق من الكش). لذا، هي مسؤولية `GameRepositoryImpl`.
    // اعتبر هذا كـ "مكان مؤقت" يتم فيه التحقق الفعلي لاحقًا.
    bool hasAnyLegalMoves = false;
    for (final entry in currentPlayersPieces.entries) {
      final pieceCell = entry.key;
      final piece = entry.value;
      final rawMoves = piece.getRawMoves(board, pieceCell);
      for (final move in rawMoves) {
        // هنا يجب أن يتم التحقق مما إذا كانت هذه النقلة قانونية (لا تضع الملك في كش)
        // ولكن هذا المنطق موجود في GameRepositoryImpl.
        // لذا، هذا التحقق سيُستكمل في طبقة الـ GameRepositoryImpl
        // عن طريق حساب isKingInCheck بعد كل حركة محتملة
        final simulatedBoard = simulateMove(board, move);
        if (!simulatedBoard.isKingInCheck(board.currentPlayer)) {
          hasAnyLegalMoves = true;
          break;
        }
      }
      if (hasAnyLegalMoves) break;
    }

    return !hasAnyLegalMoves;
  }

  /// دالة مساعدة لمحاكاة حركة على لوحة (لغرض التحقق من الكش).
  static Board simulateMove(Board board, Move move) {
    final newBoard = board.copyWithDeepPieces();
    final pieceToMove = newBoard.getPieceAt(move.start);

    if (pieceToMove == null) {
      return newBoard; // Should not happen for legal moves
    }

    // Update piece's hasMoved status
    final updatedPiece = Piece.create(
      color: pieceToMove.color,
      type: pieceToMove.type,
      hasMoved: true,
    ); // Assume it has moved

    // Place the piece at the end cell
    newBoard.squares[move.end.row][move.end.col] = updatedPiece;
    // Clear the start cell
    newBoard.squares[move.start.row][move.start.col] = null;

    // If it's a king move, update its position in kingPositions map
    if (pieceToMove.type == PieceType.king) {
      newBoard.kingPositions[pieceToMove.color] = move.end;
    }

    // Handle castling rook move in simulation
    if (move.isCastling) {
      final kingRow = pieceToMove.color == PieceColor.white ? 7 : 0;
      if (move.end.col == 6) {
        // King-side castling
        final rook = newBoard.getPieceAt(Cell(row: kingRow, col: 7));
        newBoard.squares[kingRow][5] = rook?.copyWith(
          hasMoved: true,
        ); // Move rook
        newBoard.squares[kingRow][7] = null; // Clear old rook position
      } else if (move.end.col == 2) {
        // Queen-side castling
        final rook = newBoard.getPieceAt(Cell(row: kingRow, col: 0));
        newBoard.squares[kingRow][3] = rook?.copyWith(
          hasMoved: true,
        ); // Move rook
        newBoard.squares[kingRow][0] = null; // Clear old rook position
      }
    }
    // Handle en passant capture in simulation
    if (move.isEnPassant) {
      final capturedPawnRow =
          pieceToMove.color == PieceColor.white
              ? move.end.row + 1
              : move.end.row - 1;
      newBoard.squares[capturedPawnRow][move.end.col] = null;
    }

    return newBoard;
  }

  /// التحقق من التعادل بتكرار الوضعية ثلاث مرات.
  /// يحدث عندما تظهر نفس الوضعية ثلاث مرات على الأقل في سجل اللعبة.
  static bool isThreefoldRepetition(Board board) {
    final currentFen = board.toFenString();
    int count = 0;
    for (final fen in board.positionHistory) {
      if (fen == currentFen) {
        count++;
      }
    }
    return count >= 3;
  }

  /// التحقق من التعادل بقاعدة الخمسين نقلة.
  /// يحدث عندما يتم لعب 50 نقلة متتالية (100 نصف نقلة) دون تحريك بيدق أو أسر أي قطعة.
  static bool isFiftyMoveRule(Board board) {
    return board.halfMoveClock >= 100; // 100 نصف نقلة = 50 نقلة كاملة
  }
}
