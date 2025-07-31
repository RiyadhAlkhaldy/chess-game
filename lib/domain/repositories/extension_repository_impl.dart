part of 'game_repository_impl.dart';

extension EvaluateBoardForMinimax on GameRepositoryImpl {
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

  // مثال بسيط جداً لجداول المواقع (يمكن أن تكون أكثر تفصيلاً)
  // هذه الجداول للاعب الأبيض. للاعب الأسود، تعكس الصفوف.
  static const Map<PieceType, List<List<int>>> _pieceSquareTables = {
    PieceType.pawn: [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [50, 50, 50, 50, 50, 50, 50, 50], // الصف 7 (بالنسبة للأبيض)
      [10, 10, 20, 30, 30, 20, 10, 10],
      [5, 5, 10, 25, 25, 10, 5, 5],
      [0, 0, 0, 20, 20, 0, 0, 0],
      [5, -5, -10, 0, 0, -10, -5, 5],
      [5, 10, 10, -20, -20, 10, 10, 5],
      [0, 0, 0, 0, 0, 0, 0, 0],
    ],
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
    // ... أضف جداول للملك، الأسقف، الرخ، والملكة
    // جداول الملك تختلف لمرحلة الافتتاح/الوسط والنهاية
  };
  

  int _evaluateBoard(Board board, PieceColor aiPlayerColor) {
    debugPrint("_evaluateBoard");

    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.squares[r][c];
        if (piece != null) {
          final pieceValue = _pieceValues[piece.type] ?? 0;
          int positionBonus = 0;

          // تطبيق مكافأة/خصم الموقع من جداول PST
          final pst = _pieceSquareTables[piece.type];
          if (pst != null) {
            if (piece.color == PieceColor.white) {
              positionBonus = pst[r][c]; // للقطع البيضاء نستخدم الصفوف كما هي
            } else {
              positionBonus = pst[7 - r][c]; // للقطع السوداء نعكس الصفوف
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

    // إضافة المزيد من العوامل:
    // 1. أمان الملك:
    //    * خصم كبير إذا كان الملك في كش.
    //    * مكافأة صغيرة إذا كان الملك محميًا ببيادق حوله.
    //    * خصم إذا كان الملك مكشوفًا (بدون بيادق أمامه).
    final int kingRow = aiPlayerColor == PieceColor.white ? 7 : 0;
    final Cell kingPos =
        board.kingPositions[aiPlayerColor]!; // افترض أن الملك موجود
    if (board.isKingInCheck(aiPlayerColor)) {
      score -= 900; // خصم كبير إذا كان الملك في كش
    }
    // يمكن إضافة منطق أكثر تعقيداً لأمان الملك (مثل عدد البيادق المحيطة بالملك)

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
    // score += _evaluatePawnStructure(board, aiPlayerColor);

    // 4. نشاط القطع:
    //    * مكافأة على القطع النشطة (التي لديها العديد من الحركات المحتملة).
    //    * مكافأة على القطع التي تهاجم قطع الخصم.

    // 5. مراحل اللعبة (Game Phase):
    //    * تختلف أوزان العوامل المختلفة باختلاف مرحلة اللعبة (افتتاح، وسط، نهاية).
    //    * في نهاية اللعبة، يزداد نشاط الملك وقيمة البيادق المتقدمة.
    //    * يمكن تحديد مرحلة اللعبة بناءً على عدد القطع المتبقية على اللوحة.

    return score;
  }

  // دالة مساعدة لتقييم هيكل البيادق (مثال بسيط)
  int _evaluatePawnStructure(Board board, PieceColor playerColor) {
    int pawnStructureScore = 0;
    // قم بتحليل البيادق المعزولة والمتضاعفة
    for (int col = 0; col < 8; col++) {
      int pawnCountInCol = 0;
      for (int row = 0; row < 8; row++) {
        final piece = board.getPieceAt(Cell(row: row, col: col));
        if (piece is Pawn && piece.color == playerColor) {
          pawnCountInCol++;
        }
      }

      if (pawnCountInCol > 1) {
        pawnStructureScore -=
            15 * (pawnCountInCol - 1); // خصم على البيادق المتضاعفة
      }

      if (pawnCountInCol > 0) {
        bool isIsolated = true;
        if (col > 0) {
          // تحقق من العمود الأيسر
          for (int row = 0; row < 8; row++) {
            final piece = board.getPieceAt(Cell(row: row, col: col - 1));
            if (piece is Pawn && piece.color == playerColor) {
              isIsolated = false;
              break;
            }
          }
        }
        if (col < 7 && isIsolated) {
          // تحقق من العمود الأيمن (إذا لم يكن معزولا بالفعل من اليسار)
          for (int row = 0; row < 8; row++) {
            final piece = board.getPieceAt(Cell(row: row, col: col + 1));
            if (piece is Pawn && piece.color == playerColor) {
              isIsolated = false;
              break;
            }
          }
        }
        if (isIsolated) {
          pawnStructureScore -= 10; // خصم على البيادق المعزولة
        }
      }
    }
    return pawnStructureScore;
  }


}

extension CheckGameConditions on GameRepositoryImpl {
  // دالة لترتيب الحركات (مثال بسيط: الأسر أولاً)
  void _sortMoves(List<Move> moves, Board board) {
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
