// lib/presentation/controllers/game_controller.dart

import 'package:flutter/material.dart'; // لتصحيح الأخطاء (debugPrint)
import 'package:get/get.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/zobrist_hashing.dart';
import '../../domain/usecases/get_ai_move.dart';
import '../../domain/usecases/get_board_state.dart';
import '../../domain/usecases/get_game_result.dart';
import '../../domain/usecases/get_legal_moves.dart';
import '../../domain/usecases/is_king_in_check.dart';
import '../../domain/usecases/make_move.dart';
import '../../domain/usecases/play_sound_usecase.dart';
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
  final GetAiMove _getAIMoveUseCase; // تم استبدال GetAiMove بـ GetAIMoveUseCase
  final PlaySoundUseCase _playSoundUseCase;

  /// حالة اللوحة الحالية التي يتم ملاحظتها بواسطة واجهة المستخدم.
  final Rx<Board> board = Board.initial().obs;
  //  = Board.fenToBoard(
  //       'rnbqk2r/pp3ppp/2p2n2/3p2B1/1b1P4/2N2N2/PP2PPPP/R2QKB1R w KQkq - 0 1',
  //     ).obs;

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

  /// لتعقب حالة تحميل حركة الذكاء الاصطناعي
  RxBool isLoadingAIMove = false.obs;

  /// يشير إلى ما إذا كان أحد اللاعبين قد اقترح التعادل.
  final RxBool drawOffered = false.obs;

  /// لون اللاعب الذي قدم عرض التعادل.
  final Rx<PieceColor?> playerOfferedDraw = Rx<PieceColor?>(null);

  /// مُنشئ المتحكم. يتم حقن الـ Use Cases هنا.
  GameController({
    required GetBoardState getBoardState,
    required GetLegalMoves getLegalMoves,
    required MakeMove makeMove,
    required ResetGame resetGame,
    required GetGameResult getGameResult,
    required IsKingInCheck isKingInCheck,
    required GetAiMove getAIMoveUseCase, // حقن حالة استخدام الذكاء الاصطناعي
    required PlaySoundUseCase playSoundUseCase,
  }) : _getBoardState = getBoardState,
       _getLegalMoves = getLegalMoves,
       _makeMove = makeMove,
       _resetGame = resetGame,
       _getGameResult = getGameResult,
       _isKingInCheck = isKingInCheck,
       _getAIMoveUseCase = getAIMoveUseCase,
       _playSoundUseCase = playSoundUseCase;

  @override
  void onInit() {
    super.onInit();
    if (!ZobristHashing.zobristKeysInitialized) {
      ZobristHashing.initializeZobristKeys();
      ZobristHashing.zobristKeysInitialized = true;
    }
    _initialColorsAndAIdepth();
    // مراقبة تغيير اللاعب الحالي لتشغيل دور الذكاء الاصطناعي.
    ever(board, (_) {
      _checkGameStatus();
      // _handleAiTurn();
    });
    _updateBoardState();
  }

  /// [initialColorsAndAIdepth]
  /// تهيئة الألوان للاعب والذكاء الاصطناعي وعمق بحث الذكاء الاصطناعي.
  /// Initializes colors for player and AI and AI search depth.
  _initialColorsAndAIdepth() {
    /// عمق الذكاء الاصطناعي
    /// AI depth
    aiDepth = gameOptionsController.aiDepth.value.toInt();

    /// لون اللاعب البشري
    /// Human player color
    final humanColor = gameOptionsController.meColor.value;

    debugPrint("gameOptionsController 11 ${gameOptionsController.aiDepth}");
    humanPlayerColor = humanColor;
    aiPlayerColor =
        humanColor == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  /// [updateBoardState]
  /// تحديث حالة اللوحة من الـ Repository وتحديث [board].
  /// Updates the board state from the Repository and updates [board].
  void _updateBoardState() {
    board.value = _getBoardState.execute();
  }

  /// [checkGameStatus]
  /// يتحقق من حالة نهاية اللعبة (كش ملك، طريق مسدود، تعادل) ويحدث [gameResult].
  /// Checks for game end conditions (checkmate, stalemate, draw) and updates [gameResult].
  void _checkGameStatus() {
    gameResult.value = _getGameResult.execute();
  }

  /// [onCellTap]
  /// يعالج النقر على خلية في لوحة الشطرنج.
  /// يحدد ما إذا كانت القطعة قد تم اختيارها، أو يتم تحديد حركة، أو إلغاء التحديد.
  /// Handles cell taps on the chessboard.
  /// Determines whether a piece is selected, a move is being made, or a selection is cleared.
  void onCellTap(Cell cell) {
    if (gameResult.value.outcome != GameOutcome.playing) {
      return; // لا تسمح بالحركات إذا انتهت اللعبة
    }

    // السماح بالحركة فقط إذا كان الدور للاعب البشري.
    // Allow moves only if it's the human player's turn.
    // if (board.value.currentPlayer != humanPlayerColor) {
    //   debugPrint('ليس دورك يا لاعب! انتظر الذكاء الاصطناعي.');
    //   return; // منع اللاعب من اللعب في دور الذكاء الاصطناعي
    // }

    final Piece? pieceAtCell = board.value.getPieceAt(cell);
    debugPrint(cell.toString());
    debugPrint(pieceAtCell.toString());

    if (selectedCell.value == null) {
      // لم يتم تحديد أي قطعة بعد.
      // No piece selected yet.
      if (pieceAtCell != null &&
          pieceAtCell.color == board.value.currentPlayer) {
        // تم تحديد قطعة اللاعب الحالي.
        // Current player's piece selected.
        selectedCell.value = cell;
        legalMoves.value = _getLegalMoves.execute(cell);
      }
    } else {
      // توجد قطعة محددة بالفعل.
      // A piece is already selected.
      if (selectedCell.value == cell) {
        // تم النقر على نفس الخلية مرة أخرى، إلغاء التحديد.
        // Tapped on the same cell again, deselect.
        _clearSelection();
      } else if (pieceAtCell != null &&
          pieceAtCell.color == board.value.currentPlayer) {
        // تم تحديد قطعة أخرى للّاعب الحالي.
        // Another piece of the current player is selected.
        selectedCell.value = cell;
        legalMoves.value = _getLegalMoves.execute(cell);
      } else {
        // محاولة التحرك إلى خلية أخرى (أو أسر قطعة الخصم).
        // Attempt to move to another cell (or capture opponent's piece).
        _tryMove(selectedCell.value!, cell);
      }
    }
  }

  /// [tryMove]
  /// يحاول تنفيذ حركة من الخلية [startCell] إلى الخلية [endCell].
  /// Tries to execute a move from [startCell] to [endCell].
  void _tryMove(Cell startCell, Cell endCell) async {
    Move? move = legalMoves.firstWhereOrNull(
      (m) => m.start == startCell && m.end == endCell,
    );

    if (move != null) {
      // منطق ترقية البيدق
      if (move.isPromotion && move.movedPiece.type == PieceType.pawn) {
        // افتراض الترقية إلى ملكة إذا لم يحدد نوع آخر (يمكن توسيع هذا لاحقًا)
        final promotedPiece = Queen(
          color: move.movedPiece.color,
          type: PieceType.queen,
          hasMoved: true,
        );
        move = move.copyWith(
          promotedTo: promotedPiece,
          promotedPieceType: promotedPiece.type,
        );
      }
      _makeMove.execute(move);
      _playSoundUseCase.executeMoveSound();

      _updateBoardState();
      _clearSelection();
    } else {
      debugPrint('الحركة غير قانونية!');
      _clearSelection();
    }
  }

  /// [clearSelection]
  /// يمسح اختيار الخلية والحركات القانونية.
  /// Clears cell selection and legal moves.
  void _clearSelection() {
    selectedCell.value = null;
    legalMoves.clear();
  }

  /// [resetGame]
  /// إعادة تعيين اللعبة إلى حالتها الأولية.
  /// Resets the game to its initial state.
  void resetGame() async {
    _resetGame.execute();
    _initialColorsAndAIdepth();
    _updateBoardState();
    _checkGameStatus();
    _clearSelection();
    drawOffered.value = false; // إعادة تعيين حالة عرض التعادل
    playerOfferedDraw.value = null;
    _playSoundUseCase.executeMoveSound();
  }

  /// [isCurrentKingInCheck]
  /// التحقق مما إذا كان الملك الحالي في حالة كش.
  /// Checks if the current king is in check.
  bool isCurrentKingInCheck() {
    return _isKingInCheck.execute(board.value.currentPlayer);
  }

  /// [handleAiTurn]
  /// يتعامل مع دور الذكاء الاصطناعي.
  /// Handles the AI's turn.
  Future<void> _handleAiTurn() async {
    if (board.value.currentPlayer == aiPlayerColor &&
        gameResult.value.outcome == GameOutcome.playing) {
      isLoadingAIMove.value = true; // بدء مؤشر التحميل
      debugPrint(
        'دور الذكاء الاصطناعي (${aiPlayerColor == PieceColor.white ? 'الأبيض' : 'الأسود'})',
      );
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // تأخير بسيط لمحاكاة التفكير

      try {
        // استدعاء حالة استخدام الذكاء الاصطناعي لحساب أفضل حركة.
        // Passing the current board state and the search depth.
        // The AI logic itself will determine whose turn it is from board.value.currentPlayer.
        final aiMove = await _getAIMoveUseCase.execute(
          board.value,
          aiPlayerColor,
          aiDepth,
        );
        debugPrint("aiMove = $aiMove");
        if (aiMove != null) {
          debugPrint(
            'الذكاء الاصطناعي يقوم بالحركة: ${aiMove.start} -> ${aiMove.end}',
          );
          _makeMove.execute(aiMove); // تنفيذ حركة الذكاء الاصطناعي
          _updateBoardState(); // تحديث حالة اللوحة بعد حركة الذكاء الاصطناعي
        } else {
          debugPrint(
            'الذكاء الاصطناعي ليس لديه حركات قانونية. (طريق مسدود أو كش ملك)',
          );
          _checkGameStatus(); // تحقق من حالة اللعبة النهائية
        }
      } catch (e) {
        debugPrint('خطأ في حساب حركة الذكاء الاصطناعي: $e');
        // يمكن عرض رسالة خطأ للمستخدم هنا
      } finally {
        isLoadingAIMove.value = false; // إنهاء مؤشر التحميل
      }
    }
  }

  /// يقترح التعادل.
  void offerDraw() {
    if (gameResult.value.outcome == GameOutcome.playing) {
      drawOffered.value = true;
      playerOfferedDraw.value = board.value.currentPlayer;
      Get.snackbar(
        'عرض تعادل!',
        '${board.value.currentPlayer == PieceColor.white ? 'اللاعب الأبيض' : 'اللاعب الأسود'} يقترح التعادل.',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            acceptDraw();
            Get.back(); // إغلاق الـ Snackbar
          },
          child: const Text('قبول'),
        ),
        duration: const Duration(seconds: 10), // إعطاء اللاعب الآخر وقتًا للرد
        onTap: (snack) {
          // إذا تم النقر على أي مكان آخر، يتم رفض العرض
          declineDraw();
        },
      );
    }
  }

  /// يقبل عرض التعادل.
  void acceptDraw() {
    if (drawOffered.value) {
      gameResult.value = GameResult.draw(DrawReason.agreement);
      drawOffered.value = false;
      playerOfferedDraw.value = null;
      Get.snackbar('تعادل!', 'تم قبول عرض التعادل. اللعبة انتهت.');
    }
  }

  /// يرفض عرض التعادل.
  void declineDraw() {
    if (drawOffered.value) {
      drawOffered.value = false;
      playerOfferedDraw.value = null;
      Get.snackbar('تم الرفض!', 'تم رفض عرض التعادل. اللعبة مستمرة.');
    }
  }

  void resign() {}
  void undoMove() {}
  void redoMove() {}
}
