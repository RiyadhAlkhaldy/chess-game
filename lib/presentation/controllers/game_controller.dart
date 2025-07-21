// lib/presentation/controllers/game_controller.dart

import 'package:flutter/material.dart'; // لتصحيح الأخطاء (debugPrint)
import 'package:get/get.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/usecases/get_ai_move.dart'; // استيراد حالة استخدام الذكاء الاصطناعي
import '../../domain/usecases/get_board_state.dart';
import '../../domain/usecases/get_game_result.dart';
import '../../domain/usecases/get_legal_moves.dart';
import '../../domain/usecases/is_king_in_check.dart';
import '../../domain/usecases/make_move.dart';
import '../../domain/usecases/reset_game.dart';
import 'get_options_controller.dart';

/// المتحكم (Controller) الرئيسي للعبة الشطرنج.
/// يدير حالة اللعبة ويتفاعل مع الـ Use Cases.
class GameController extends GetxController {
  final GetBoardState _getBoardState;
  final GetLegalMoves _getLegalMoves;
  final MakeMove _makeMove;
  final ResetGame _resetGame;
  final GetGameResult _getGameResult;
  final IsKingInCheck _isKingInCheck;
  final GetAiMove _getAiMove; // إضافة حالة استخدام الذكاء الاصطناعي

  /// حالة اللوحة الحالية التي يتم ملاحظتها بواسطة واجهة المستخدم.
  final Rx<Board> board = Board.initial().obs;

  /// الخلية المختارة حاليًا من قبل اللاعب.
  final Rx<Cell?> selectedCell = Rx<Cell?>(null);

  /// قائمة بالحركات القانونية للقطعة المختارة حاليًا.
  final RxList<Move> legalMoves = <Move>[].obs;

  /// نتيجة اللعبة الحالية.
  final Rx<GameResult> gameResult = GameResult.playing().obs;

  /// لون اللاعب البشري (يمكن أن يكون أبيض أو أسود).
  /// يمكن تغيير هذا من خلال إعدادات اللعبة.
  PieceColor humanPlayerColor = PieceColor.white;

  /// لون لاعب الذكاء الاصطناعي.
  PieceColor aiPlayerColor = PieceColor.black;

  final gameOptionsController = Get.find<GameOptionsController>();
  int aiDepth = 3;

  /// مُنشئ المتحكم. يتم حقن الـ Use Cases هنا.
  GameController({
    required GetBoardState getBoardState,
    required GetLegalMoves getLegalMoves,
    required MakeMove makeMove,
    required ResetGame resetGame,
    required GetGameResult getGameResult,
    required IsKingInCheck isKingInCheck,
    required GetAiMove getAiMove, // حقن حالة استخدام الذكاء الاصطناعي
  }) : _getBoardState = getBoardState,
       _getLegalMoves = getLegalMoves,
       _makeMove = makeMove,
       _resetGame = resetGame,
       _getGameResult = getGameResult,
       _isKingInCheck = isKingInCheck,
       _getAiMove = getAiMove;

  @override
  void onInit() {
    super.onInit();

    _initialColorsAndAIdepth();
    // مراقبة تغيير اللاعب الحالي لتشغيل دور الذكاء الاصطناعي.
    // ever(board, (_) {
    _checkGameStatus();
    // _handleAiTurn();
    // });
    _updateBoardState();
  }

  /// initial colors for player and AI
  _initialColorsAndAIdepth() {
    /// ai depth
    aiDepth = gameOptionsController.aiDepth.value;

    /// human color
    final humanColor = gameOptionsController.meColor.value;

    print("gameOptionsController 11 ${gameOptionsController.aiDepth}");
    humanPlayerColor = humanColor;
    aiPlayerColor =
        humanColor == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  /// تحديث حالة اللوحة من الـ Repository وتحديث [board].
  void _updateBoardState() {
    board.value = _getBoardState.execute();
  }

  /// يتحقق من حالة نهاية اللعبة (كش ملك، طريق مسدود، تعادل) ويحدث [gameResult].
  void _checkGameStatus() {
    gameResult.value = _getGameResult.execute();
  }

  /// يعالج النقر على خلية في لوحة الشطرنج.
  /// يحدد ما إذا كانت القطعة قد تم اختيارها، أو يتم تحديد حركة، أو إلغاء التحديد.
  void onCellTap(Cell cell) {
    if (gameResult.value.outcome != GameOutcome.playing) {
      return; // لا تسمح بالحركات إذا انتهت اللعبة
    }

    // السماح بالحركة فقط إذا كان الدور للاعب البشري.
    if (board.value.currentPlayer != humanPlayerColor) {
      debugPrint('ليس دورك يا لاعب! انتظر الذكاء الاصطناعي.');
      // return;
    }

    final Piece? pieceAtCell = board.value.getPieceAt(cell);
    debugPrint(cell.toString());
    debugPrint(pieceAtCell.toString());

    if (selectedCell.value == null) {
      // لم يتم تحديد أي قطعة بعد.
      if (pieceAtCell != null &&
          pieceAtCell.color == board.value.currentPlayer) {
        // تم تحديد قطعة اللاعب الحالي.
        selectedCell.value = cell;
        legalMoves.value = _getLegalMoves.execute(cell);
      }
    } else {
      // توجد قطعة محددة بالفعل.
      if (selectedCell.value == cell) {
        // تم النقر على نفس الخلية مرة أخرى، إلغاء التحديد.
        _clearSelection();
      } else if (pieceAtCell != null &&
          pieceAtCell.color == board.value.currentPlayer) {
        // تم تحديد قطعة أخرى للّاعب الحالي.
        selectedCell.value = cell;
        legalMoves.value = _getLegalMoves.execute(cell);
      } else {
        // محاولة التحرك إلى خلية أخرى (أو أسر قطعة الخصم).
        _tryMove(selectedCell.value!, cell);
      }
    }
  }

  /// يحاول تنفيذ حركة من الخلية [startCell] إلى الخلية [endCell].
  void _tryMove(Cell startCell, Cell endCell) {
    final move = legalMoves.firstWhereOrNull(
      (m) => m.start == startCell && m.end == endCell,
    );

    if (move != null) {
      _makeMove.execute(move);
      _updateBoardState();
      _clearSelection();
      // _handleAiTurn();
    } else {
      debugPrint('الحركة غير قانونية!');
      _clearSelection();
    }
  }

  /// يمسح اختيار الخلية والحركات القانونية.
  void _clearSelection() {
    selectedCell.value = null;
    legalMoves.clear();
  }

  /// إعادة تعيين اللعبة إلى حالتها الأولية.
  void resetGame() {
    _resetGame.execute();
    _initialColorsAndAIdepth();
    _updateBoardState();
    _checkGameStatus();
    _clearSelection();
  }

  /// التحقق مما إذا كان الملك الحالي في حالة كش.
  bool isCurrentKingInCheck() {
    return _isKingInCheck.execute(board.value.currentPlayer);
  }

  /// يتعامل مع دور الذكاء الاصطناعي.
  Future<void> _handleAiTurn() async {
    if (board.value.currentPlayer == aiPlayerColor &&
        gameResult.value.outcome == GameOutcome.playing) {
      debugPrint(
        'دور الذكاء الاصطناعي (${aiPlayerColor == PieceColor.white ? 'الأبيض' : 'الأسود'})',
      );
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // تأخير بسيط لمحاكاة التفكير

      final aiMove = await _getAiMove.execute(
        board.value,
        aiPlayerColor,
        aiDepth,
      );

      if (aiMove != null) {
        debugPrint(
          'الذكاء الاصطناعي يقوم بالحركة: ${aiMove.start} -> ${aiMove.end}',
        );
        _makeMove.execute(aiMove);
        _updateBoardState();
      } else {
        debugPrint(
          'الذكاء الاصطناعي ليس لديه حركات قانونية. (طريق مسدود أو كش ملك)',
        );
        _checkGameStatus(); // تحقق من حالة اللعبة النهائية
      }
    }
  }
}
