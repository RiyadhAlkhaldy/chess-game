import '../entities/export.dart';

class AlphaBetaEvaluate {
  final List<Board> _boardHistory = []; // لتتبع تكرار اللوحة
  List<Move> redoStack = []; // لتتبع الحركات التي يمكن التراجع عنها

  /// قاموس يمثل قيم القطع (لتقييم اللوحة).
  static const Map<PieceType, int> _pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000, // قيمة عالية جدا للملك
  };
  // مثال: جزء من جدول مواقع البيادق
  static const List<List<int>> pawnPST = [
    [0, 0, 0, 0, 0, 0, 0, 0], // الصف 8 (ترقية)
    [5, 10, 10, -20, -20, 10, 10, 5], // الصف 7
    [5, -5, -10, 0, 0, -10, -5, 5], // الصف 6
    [0, 0, 0, 20, 20, 0, 0, 0], // الصف 5 (مكافأة على المركز)
    [5, 5, 10, 25, 25, 10, 5, 5], // الصف 4
    [10, 10, 20, 30, 30, 20, 10, 10], // الصف 3
    [50, 50, 50, 50, 50, 50, 50, 50], // الصف 2 (ترقية قريبة)
    [0, 0, 0, 0, 0, 0, 0, 0], // الصف 1 (موقع البداية)
  ];
  // lib/data/repositories/game_repository_impl.dart

  // ... (بقية الكود) ...
  static const Map<PieceType, List<List<int>>> _pieceSquareTables = {
    // جداول مواقع البيادق
    PieceType.pawn: [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [50, 50, 50, 50, 50, 50, 50, 50],
      [10, 10, 20, 30, 30, 20, 10, 10],
      [5, 5, 10, 25, 25, 10, 5, 5],
      [0, 0, 0, 20, 20, 0, 0, 0],
      [5, -5, -10, 0, 0, -10, -5, 5],
      [5, 10, 10, -20, -20, 10, 10, 5],
      [0, 0, 0, 0, 0, 0, 0, 0],
    ],

    // جداول مواقع الأحصنة
    PieceType.knight: [
      [-50, -40, -30, -30, -30, -30, -40, -50],
      [-40, -20, 0, 0, 0, 0, -20, -40],
      [-30, 0, 10, 15, 15, 10, 0, -30],
      [-30, 5, 15, 20, 20, 15, 5, -30],
      [-30, 0, 15, 20, 20, 15, 0, -30],
      [-30, 5, 10, 15, 15, 10, 5, -30],
      [-40, -20, 0, 5, 5, 0, -20, -40],
      [-50, -40, -30, -30, -30, -30, -40, -50],
    ],

    // جداول مواقع الأساقفة
    PieceType.bishop: [
      [-20, -10, -10, -10, -10, -10, -10, -20],
      [-10, 0, 0, 0, 0, 0, 0, -10],
      [-10, 0, 5, 10, 10, 5, 0, -10],
      [-10, 5, 5, 10, 10, 5, 5, -10],
      [-10, 0, 10, 10, 10, 10, 0, -10],
      [-10, 10, 10, 10, 10, 10, 10, -10],
      [-10, 5, 0, 0, 0, 0, 5, -10],
      [-20, -10, -10, -10, -10, -10, -10, -20],
    ],

    // جداول مواقع الأبراج
    PieceType.rook: [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [5, 10, 10, 10, 10, 10, 10, 5],
      [-5, 0, 0, 0, 0, 0, 0, -5],
      [-5, 0, 0, 0, 0, 0, 0, -5],
      [-5, 0, 0, 0, 0, 0, 0, -5],
      [-5, 0, 0, 0, 0, 0, 0, -5],
      [-5, 0, 0, 0, 0, 0, 0, -5],
      [0, 0, 0, 5, 5, 0, 0, 0],
    ],

    // جداول مواقع الملكات
    PieceType.queen: [
      [-20, -10, -10, -5, -5, -10, -10, -20],
      [-10, 0, 0, 0, 0, 0, 0, -10],
      [-10, 0, 5, 5, 5, 5, 0, -10],
      [-5, 0, 5, 5, 5, 5, 0, -5],
      [0, 0, 5, 5, 5, 5, 0, -5],
      [-10, 5, 5, 5, 5, 5, 0, -10],
      [-10, 0, 5, 0, 0, 0, 0, -10],
      [-20, -10, -10, -5, -5, -10, -10, -20],
    ],

    // جداول مواقع الملك في مرحلة الافتتاح والوسط
    PieceType.king: [
      [-30, -40, -40, -50, -50, -40, -40, -30],
      [-30, -40, -40, -50, -50, -40, -40, -30],
      [-30, -40, -40, -50, -50, -40, -40, -30],
      [-30, -40, -40, -50, -50, -40, -40, -30],
      [-20, -30, -30, -40, -40, -30, -30, -20],
      [-10, -20, -20, -20, -20, -20, -20, -10],
      [20, 20, 0, 0, 0, 0, 20, 20],
      [20, 30, 10, 0, 0, 10, 30, 20],
    ],
  };
  // جداول مواقع الملك في نهاية اللعبة (Endgame)
  // يفضل أن يكون جدول الملك مختلفًا في نهاية اللعبة لأن الملك يصبح أكثر نشاطًا.
  // يمكننا تحديد ذلك بناءً على عدد القطع المتبقية على اللوحة.
  List<List<int>> get kingEndgame => [
    [-50, -30, -30, -30, -30, -30, -30, -50],
    [-30, -10, -10, -10, -10, -10, -10, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -20, -10, 0, 0, -10, -20, -30],
    [-50, -40, -30, -20, -20, -30, -40, -50],
  ];
  // مثال بسيط جداً لجداول المواقع (يمكن أن تكون أكثر تفصيلاً)

  double evaluateBoardScore(Board board, PieceColor aiColor) {
    double score = 0.0;

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final piece = board.getPieceAt(Cell(row: y, col: x));
        if (piece != null) {
          double value = _getPieceValue(piece.type);
          score += piece.color == aiColor ? value : -value;
        }
      }
    }

    return score;
  }

  double _getPieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 1.0;
      case PieceType.knight:
        return 3.0;
      case PieceType.bishop:
        return 3.3;
      case PieceType.rook:
        return 5.0;
      case PieceType.queen:
        return 9.0;
      case PieceType.king:
        return 1000.0;
    }
  }

  List<Move> orderMoves(List<Move> moves) {
    moves.sort((a, b) {
      int aScore = _moveScore(a);
      int bScore = _moveScore(b);
      return bScore.compareTo(aScore); // ترتيب تنازلي
    });
    return moves;
  }

  int _moveScore(Move move) {
    int score = 0;
    if (move.isCapture == true) score += 100;
    if (move.isPromotion == true) score += 80;
    // يمكن إضافة المزيد من الشروط لتقييم الحركة
    // على سبيل المثال:
    if (move.isEnPassant == true) score += 50;
    if (move.isCastling == true) score += 30;
    // يمكن إضافة تقييمات للكش أو الشيك ميت
    // مثال:
    // if (move.isCheckmate) score += 200;
    // if (move.isCheck) score += 50;
    return score;
  }

  int evaluateBoard(Board board, PieceColor aiPlayerColor) {
    int score = 0;
    final isEndgame = _isEndgame(board);

    // 1. تقييم قيمة القطع ومكافآت المواقع (PSTs)
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          final pieceValue = _pieceValues[piece.type] ?? 0;
          int positionBonus = 0;

          final pst =
              isEndgame && piece.type == PieceType.king
                  ? kingEndgame
                  : _pieceSquareTables[piece.type];

          if (pst != null) {
            if (piece.color == PieceColor.white) {
              positionBonus = pst[r][c];
            } else {
              positionBonus = pst[7 - r][c];
            }
          }

          if (piece.color == aiPlayerColor) {
            score += pieceValue + positionBonus;
          } else {
            score -= (pieceValue + positionBonus);
          }
        }
      }
    }

    // 2. تقييم هيكل البيادق
    score += _evaluatePawnStructure(board, aiPlayerColor);
    score -= _evaluatePawnStructure(
      board,
      aiPlayerColor == PieceColor.white ? PieceColor.black : PieceColor.white,
    );

    // 3. تقييم أمان الملك
    score += _evaluateKingSafety(board, aiPlayerColor);
    score -= _evaluateKingSafety(
      board,
      aiPlayerColor == PieceColor.white ? PieceColor.black : PieceColor.white,
    );

    // 4. تقييم نشاط القطع
    score += _evaluatePieceActivity(board, aiPlayerColor);
    score -= _evaluatePieceActivity(
      board,
      aiPlayerColor == PieceColor.white ? PieceColor.black : PieceColor.white,
    );

    // return score;

    // إضافة المزيد من العوامل:

    // 2. السيطرة على المركز (يمكن تعزيزها):
    //    * مكافأة إضافية للقطع التي تسيطر على مربعات e4, d4, e5, d5.
    final centerCells = [
      const Cell(row: 3, col: 3),
      const Cell(row: 3, col: 4),
      const Cell(row: 4, col: 3),
      const Cell(row: 4, col: 4),
    ];
    for (var cell in centerCells) {
      // مكافأة للقطع التي تهاجم أو تشغل مربعات المركز
      final piece = board.getPieceAt(cell);
      if (piece != null) {
        if (piece.color == aiPlayerColor) {
          score += 20; // مكافأة أكبر قليلا للتحكم المركزي
        } else {
          score -= 20;
        }
      }
      // يمكنك أيضا التحقق من الحركات المحتملة التي تصل إلى المركز
    }

    // 3. هيكل البيادق:
    //    * خصم على البيادق المعزولة (Isolated Pawns).
    //    * خصم على البيادق المتضاعفة (Doubled Pawns).
    //    * مكافأة على البيادق المتصلة (Connected Pawns).
    // هذا يتطلب دالة مساعدة لتحليل البيادق.
    score += _evaluatePawnStructure(board, aiPlayerColor);

    // 4. نشاط القطع:
    //    * مكافأة على القطع النشطة (التي لديها العديد من الحركات المحتملة).
    //    * مكافأة على القطع التي تهاجم قطع الخصم.

    // 5. مراحل اللعبة (Game Phase):
    //    * تختلف أوزان العوامل المختلفة باختلاف مرحلة اللعبة (افتتاح، وسط، نهاية).
    //    * في نهاية اللعبة، يزداد نشاط الملك وقيمة البيادق المتقدمة.
    //    * يمكن تحديد مرحلة اللعبة بناءً على عدد القطع المتبقية على اللوحة.

    return score;
  }

  // قم بإضافة هذه الدالة المساعدة لتقييم هيكل البيادق
  int _evaluatePawnStructure(Board board, PieceColor playerColor) {
    int pawnStructureScore = 0;
    final int direction = (playerColor == PieceColor.white) ? -1 : 1;

    for (int col = 0; col < 8; col++) {
      int pawnCountInCol = 0;
      List<int> pawnRowsInCol = [];

      // عد البيادق في كل عمود
      for (int row = 0; row < 8; row++) {
        final piece = board.squares[row][col];
        if (piece != null &&
            piece.type == PieceType.pawn &&
            piece.color == playerColor) {
          pawnCountInCol++;
          pawnRowsInCol.add(row);
        }
      }

      // 1. خصم البيادق المتضاعفة (Doubled Pawns)
      if (pawnCountInCol > 1) {
        pawnStructureScore -= 20 * (pawnCountInCol - 1);
      }

      // 2. خصم البيادق المعزولة (Isolated Pawns)
      if (pawnCountInCol > 0) {
        bool hasAdjacentPawn = false;
        // التحقق من العمود الأيسر
        if (col > 0) {
          for (int row = 0; row < 8; row++) {
            final piece = board.squares[row][col - 1];
            if (piece != null &&
                piece.type == PieceType.pawn &&
                piece.color == playerColor) {
              hasAdjacentPawn = true;
              break;
            }
          }
        }
        // التحقق من العمود الأيمن
        if (!hasAdjacentPawn && col < 7) {
          for (int row = 0; row < 8; row++) {
            final piece = board.squares[row][col + 1];
            if (piece != null &&
                piece.type == PieceType.pawn &&
                piece.color == playerColor) {
              hasAdjacentPawn = true;
              break;
            }
          }
        }
        if (!hasAdjacentPawn) {
          pawnStructureScore -= 10;
        }
      }

      // 3. مكافأة البيادق المدعومة (Passed Pawns)
      if (pawnCountInCol == 1) {
        final int pawnRow = pawnRowsInCol.first;
        bool isPassed = true;
        // تحقق مما إذا كانت هناك بيادق للخصم أمام البيدق
        for (
          int enemyRow = pawnRow + direction;
          enemyRow >= 0 && enemyRow < 8;
          enemyRow += direction
        ) {
          if (board.squares[enemyRow][col] != null &&
              board.squares[enemyRow][col]!.color != playerColor &&
              board.squares[enemyRow][col]!.type == PieceType.pawn) {
            isPassed = false;
            break;
          }
        }
        // تحقق من الأعمدة المجاورة
        if (isPassed && col > 0) {
          for (
            int enemyRow = pawnRow + direction;
            enemyRow >= 0 && enemyRow < 8;
            enemyRow += direction
          ) {
            if (board.squares[enemyRow][col - 1] != null &&
                board.squares[enemyRow][col - 1]!.color != playerColor &&
                board.squares[enemyRow][col - 1]!.type == PieceType.pawn) {
              isPassed = false;
              break;
            }
          }
        }
        if (isPassed && col < 7) {
          for (
            int enemyRow = pawnRow + direction;
            enemyRow >= 0 && enemyRow < 8;
            enemyRow += direction
          ) {
            if (board.squares[enemyRow][col + 1] != null &&
                board.squares[enemyRow][col + 1]!.color != playerColor &&
                board.squares[enemyRow][col + 1]!.type == PieceType.pawn) {
              isPassed = false;
              break;
            }
          }
        }
        if (isPassed) {
          pawnStructureScore += 30; // مكافأة كبيرة للبيدق المدعوم
        }
      }
    }
    return pawnStructureScore;
  }

  /// دالة مساعدة لتحديد ما إذا كانت اللعبة في مرحلة النهاية
  bool _isEndgame(Board board) {
    int totalNonPawnPieces = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null &&
            piece.type != PieceType.pawn &&
            piece.type != PieceType.king) {
          totalNonPawnPieces++;
        }
      }
    }

    // يمكن تحديد نهاية اللعبة بناءً على عدد القطع المتبقية (مثال: أقل من 5 قطع غير البيادق)
    return totalNonPawnPieces <= 5;
  }

  // قم بإضافة هذه الدالة المساعدة لتقييم أمان الملك
  int _evaluateKingSafety(Board board, PieceColor playerColor) {
    int kingSafetyScore = 0;
    final kingPosition = board.kingPositions[playerColor];

    if (kingPosition == null) {
      return 0; // لا يوجد ملك، لا يمكن تقييم الأمان
    }

    // خصم كبير إذا كان الملك في كش
    if (board.isKingInCheck(playerColor)) {
      kingSafetyScore -= 90;
    }

    // مكافأة وجود بيادق تحمي الملك
    final int kingRow = kingPosition.row;
    final int kingCol = kingPosition.col;
    final int pawnDirection = (playerColor == PieceColor.white) ? -1 : 1;

    // فحص البيادق أمام الملك
    for (int c = kingCol - 1; c <= kingCol + 1; c++) {
      if (c >= 0 && c < 8) {
        final piece = board.squares[kingRow + pawnDirection][c];
        if (piece != null &&
            piece.type == PieceType.pawn &&
            piece.color == playerColor) {
          kingSafetyScore += 10; // مكافأة على كل بيدق يغطي الملك
        }
      }
    }

    return kingSafetyScore;
  }

  // extension CheckGameConditions on GameRepositoryImpl {}

  // دالة لترتيب الحركات (مثال بسيط: الأسر أولاً)
  void sortMoves(List<Move> moves, Board board) {
    moves.sort((a, b) {
      final bool aIsCapture = board.getPieceAt(a.end) != null;
      final bool bIsCapture = board.getPieceAt(b.end) != null;

      if (aIsCapture && !bIsCapture) {
        return -1; // حركة A (أسر) قبل حركة B (ليست أسر)
      } else if (!aIsCapture && bIsCapture) {
        return 1; // حركة B (أسر) قبل حركة A (ليست أسر)
      }
      // يمكن إضافة المزيد من منطق الترتيب هنا (على سبيل المثال، MVV-LVA)
      return 0; // لا يوجد فرق في الترتيب
    });
  }

  // قم بإضافة هذه الدالة المساعدة لتقييم نشاط القطع
  int _evaluatePieceActivity(Board board, PieceColor playerColor) {
    int activityScore = 0;
    // يمكنك استخدام طريقة board.getAllLegalMovesForCurrentPlayer()
    // لتحديد عدد الحركات المتاحة، ولكن هذا قد يكون مكلفاً حسابياً.
    // بديل أبسط: مكافأة القطع غير البيادق التي لا تزال في الصفوف الخلفية

    // مكافأة للقطع المتقدمة (غير البيادق)
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null &&
            piece.color == playerColor &&
            piece.type != PieceType.pawn &&
            piece.type != PieceType.king) {
          final int rowDifference =
              (playerColor == PieceColor.white) ? (7 - r) : r;
          activityScore += rowDifference; // مكافأة للتقدم في الصفوف
        }
      }
    }

    return activityScore;
  }

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
  bool _isThreefoldRepetition(Board board) {
    if (_boardHistory.length < 5) {
      return false; // تحتاج على الأقل 5 لوحات لتكرار ثلاثي (3 مواقف متطابقة على الأقل)
    }

    // استخدام _boardToPositionKey للحصول على مفتاح الموقف
    final currentPositionKey = _boardToPositionKey(board);
    int count = 0;

    // ابحث في سجل اللوحات (باستخدام مفتاح الموقف فقط)
    for (final boardInHistory in _boardHistory) {
      if (_boardToPositionKey(boardInHistory) == currentPositionKey) {
        count++;
      }
    }
    // إذا كان العدد 3 أو أكثر، فإنها تعادل.
    return count >= 3;
  }

  /// يتحقق مما إذا كانت حالة اللعبة هي تعادل بسبب المواد غير الكافية.
  bool _isInsufficientMaterialDraw(Board board) {
    List<Piece> allPieces = [];
    Map<Piece, Cell> piecePositions = {}; // لتخزين القطع ومواقعها

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
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

// extension CheckGameConditions on GameRepositoryImpl {}
