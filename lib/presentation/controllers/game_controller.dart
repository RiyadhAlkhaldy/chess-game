// lib/presentation/controllers/game_controller.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/failures.dart';
import '../../data/ai_engine.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/repositories/game_repository.dart'; // For save/load game use cases
import '../../domain/usecases/get_best_move_usecase.dart';
import '../../domain/usecases/get_legel_moves_usecase.dart';
import '../../domain/usecases/make_move_usecase.dart';
import '../widgets/promotion_dialog.dart';
import 'get_options_controller.dart';

/// Enum to define player types (Human or AI).
enum PlayerType { human, ai }

/// Controller responsible for managing the game logic and UI state.
class GameController extends GetxController {
  // Use Cases (Domain Layer dependencies)
  final MakeMoveUseCase makeMoveUseCase;
  final GetLegalMovesUseCase getLegalMovesUseCase;
  final GetBestMoveUseCase getBestMoveUseCase;
  final GameRepository gameRepository; // For saving/loading
  final AIEngine aiEngine;

  /// Reactive state variables for the UI (observable with GetX)
  final Rx<Board> board =
      Board.initialAsWhitePlayer().obs; // Current state of the chessboard
  Rx<Cell?> selectedCell = Rx<Cell?>(null); // The currently selected cell
  /// List of legal moves for the selected piece
  RxList<Move> legalMoves = <Move>[].obs;
  Either<Failure, List<Move>>? legalMovesResult;

  ///
  /// Current game outcome (playing, checkmate, draw)
  Rx<GameResult> gameResult = GameResult.playing().obs;
  RxBool isLoading =
      false.obs; // Indicates if an async operation is in progress
  RxString errorMessage = ''.obs; // Stores any error messages to display

  // Player type settings
  Rx<PlayerType> player1Type = PlayerType.human.obs; // Player White type
  Rx<PlayerType> player2Type = PlayerType.ai.obs; // Player Black type
  PieceColor playerColor = PieceColor.white; // Player's color of human player
  // AI difficulty settings
  RxInt aiDepth = 3.obs; // AI difficulty (search depth for Minimax)

  GameOptionsController gameOptionController = Get.find();
  GameController({
    required this.makeMoveUseCase,
    required this.getLegalMovesUseCase,
    required this.getBestMoveUseCase,
    required this.gameRepository,
    required this.aiEngine,
  });

  @override
  void onInit() {
    super.onInit();
    _initGame(); // Initialize the game when the controller is created
  }

  /// Initializes or resets the game to its starting state.
  void _initGame() {
    playerColor =
        gameOptionController
            .meColor
            .value; // Set player's color based on main menu selection
    // Initialize the board based on the player's color
    board.value = Board.initialAsWhitePlayer();
    gameOptionController.meColor.value == PieceColor.white
        ? setPlayerTypes(PlayerType.human, PlayerType.ai)
        : setPlayerTypes(PlayerType.ai, PlayerType.human);
    selectedCell.value = null; // Clear selected cell
    legalMoves.clear(); // Clear legal moves
    gameResult.value = GameResult.playing(); // Set game status to playing
    errorMessage.value = ''; // Clear any error messages

    // If the starting player is AI, trigger an AI move
    // if (board.value.currentPlayer == PieceColor.black &&
    //     player2Type.value == PlayerType.ai) {
    //   _makeAIMove();
    // } else if (board.value.currentPlayer == PieceColor.white &&
    //     player1Type.value == PlayerType.ai) {
    //   _makeAIMove();
    // }
  }

  /// Handles a cell tap event from the UI.
  Future<void> selectCell(Cell cell) async {
    /// check if the game is still playing
    if (isLoading.value || gameResult.value.outcome != GameOutcome.playing) {
      return; // Prevent interaction during loading or if game is over
    }

    final currentPiece = board.value.getPieceAt(
      cell,
    ); // Piece at the tapped cell

    // Scenario 1: A piece is already selected
    if (selectedCell.value != null) {
      if (legalMoves.isNotEmpty) {
        // Check if the tapped cell is a legal move for the selected piece
        final isLegalMove = legalMoves.any((move) => move.end == cell);
        if (isLegalMove) {
          // debugPrint("selectedCell.value != null and isLegalMove $isLegalMove");
          // If it's a legal move, try to make the move
          await _tryMove(selectedCell.value!, cell);
        }
      }
      debugPrint(
        "selectedCell.value != null ${selectedCell.value} $legalMoves",
      );
      // Try to move the selected piece to the newly tapped cell
      // await _tryMove(selectedCell.value!, cell);
      selectedCell.value = null; // Deselect the piece
      legalMoves.clear(); // Clear highlighted legal moves
    }
    // Scenario 2: No piece is selected, and the tapped cell contains a piece of the current player's color
    else if (currentPiece != null &&
        currentPiece.color == board.value.currentPlayer) {
      selectedCell.value = cell; // Select this piece
      await _getAndDisplayLegalMoves(cell); // Get and display its legal moves
    }
    // Scenario 3: No piece is selected, and the tapped cell is empty or contains an opponent's piece
    else {
      // Deselect any previously selected piece (if any) and clear moves
      debugPrint("selectedCell.value == null or opponent's piece");
      selectedCell.value = null;
      legalMoves.clear();
    }
  }

  /// Fetches and displays legal moves for a given starting cell.
  Future<void> _getAndDisplayLegalMoves(Cell cell) async {
    isLoading.value = true;
    errorMessage.value = ''; // Clear previous error
    // getLegalMovesUseCase.getLegalMoves(board.value, cell);
    final result = await getLegalMovesUseCase(
      board.value,
      cell,
    ); // Call the use case
    legalMovesResult = result; // Store the result for later use
    result.fold(
      (failure) {
        debugPrint("in GameController failure $failure");

        errorMessage.value = failure.message; // Set error message on failure
        legalMoves.clear(); // Clear moves
      },
      (moves) {
        // debugPrint("in GameController moves $moves");
        legalMoves.value = moves; // Update legal moves to display
        errorMessage.value = ''; // Clear error on success
      },
    );
    isLoading.value = false;
  }

  /// Attempts to make a move from a start cell to an end cell.
  Future<void> _tryMove(Cell start, Cell end) async {
    isLoading.value = true;
    errorMessage.value = '';

    final piece = board.value.getPieceAt(start);
    if (piece == null) {
      isLoading.value = false;
      return; // Should not happen if selectedCell logic is correct
    }

    Move move;
    // Special handling for promotion
    if (piece.type == PieceType.pawn && (end.row == 0 || end.row == 7)) {
      // If it's a pawn promotion, prompt the user for the piece type
      debugPrint("Promoting pawn at $start to $end");
      PieceType? promotedType = await Get.dialog<PieceType?>(PromotionDialog());
      debugPrint("in GameController _tryMove promotedType $promotedType");
      if (promotedType == null) {
        isLoading.value = false;
        return; // User cancelled promotion
      }
      move = Move(
        start: start,
        end: end,
        isPromotion: true,
        promotedPieceType: promotedType,
      );
      // debugPrint("in GameController _tryMove promotedType $promotedType");
    }
    // Special handling for castling (king moving two squares horizontally)
    else if (piece.type == PieceType.king && (end.col - start.col).abs() == 2) {
      debugPrint("in GameController _tryMove piece.type == PieceType.king");
      move = Move(start: start, end: end, isCastling: true);
    }
    // Special handling for en passant (pawn moving diagonally to an empty square)
    else if (piece.type == PieceType.pawn &&
        board.value.getPieceAt(end) == null &&
        start.row != end.row) {
      // debugPrint("in GameController _tryMove piece.type == PieceType.pawn");
      move = Move(start: start, end: end, isEnPassant: true);
    }
    // Regular move
    else {
      debugPrint("in GameController _tryMove regular move");
      move = Move(start: start, end: end);
    }

    await _applyMoveInternal(move); // Apply the constructed move
  }

  /// Internal function to apply a move using the use case and update state.
  Future<void> _applyMoveInternal(Move move) async {
    final result = await makeMoveUseCase(
      board.value,
      move,
      null,
      // legalMovesResult!,
    ); // Call the use case
    result.fold(
      (failure) {
        debugPrint("in GameController failure $failure");
        errorMessage.value = failure.message; // Set error message on failure
      },
      (tuple) {
        board.value = tuple.value1; // Update board with new state
        gameResult.value = tuple.value2; // Update game result
        errorMessage.value = ''; // Clear error on success
        // debugPrint(
        //   "in GameController _applyMoveInternal gameResult.value ${gameResult.value}",
        // );
        // If the game is still playing, check if it's AI's turn
        if (gameResult.value.outcome == GameOutcome.playing) {
          // _checkAndTriggerAIMove();
        }
      },
    );
    isLoading.value = false;
  }

  /// Checks the current player and triggers an AI move if it's an AI player's turn.
  void _checkAndTriggerAIMove() {
    if ((board.value.currentPlayer == PieceColor.white &&
            player1Type.value == PlayerType.ai) ||
        (board.value.currentPlayer == PieceColor.black &&
            player2Type.value == PlayerType.ai)) {
      _makeAIMove();
    }
  }

  /// Initiates an AI move.
  Future<void> _makeAIMove() async {
    isLoading.value = true;
    errorMessage.value = '';
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate AI thinking time

    final result = await getBestMoveUseCase(
      board.value,
      aiDepth.value,
    ); // Get best AI move
    result.fold(
      (failure) {
        errorMessage.value = "AI Error: ${failure.message}";
      },
      (aiMove) async {
        await _applyMoveInternal(aiMove); // Apply the AI's move
      },
    );
    isLoading.value = false;
  }

  /// Starts a new game.
  void newGame() {
    _initGame();
  }

  /// Sets the player types for Player 1 (White) and Player 2 (Black) and restarts the game.
  void setPlayerTypes(PlayerType p1, PlayerType p2) {
    player1Type.value = p1;
    player2Type.value = p2;
    // _initGame();
  }

  /// Sets the AI difficulty (search depth).
  void setAIDifficulty(int depth) {
    aiDepth.value = depth;
    // Optionally restart game or apply on next AI turn
  }

  /// Saves the current game state.
  Future<void> saveGame() async {
    isLoading.value = true;
    final result = await gameRepository.saveGame(board.value);
    result.fold(
      (failure) =>
          errorMessage.value = "Failed to save game: ${failure.message}",
      (_) => errorMessage.value = "Game saved successfully!",
    );
    isLoading.value = false;
  }

  /// Loads a previously saved game state.
  Future<void> loadGame() async {
    isLoading.value = true;
    final result = await gameRepository.loadGame();
    result.fold(
      (failure) =>
          errorMessage.value = "Failed to load game: ${failure.message}",
      (loadedBoard) {
        board.value = loadedBoard;
        selectedCell.value = null;
        legalMoves.clear();
        gameResult.value =
            GameResult.playing(); // Re-evaluate game result after load
        _checkAndTriggerAIMove(); // Check if AI needs to move after loading
        errorMessage.value = "Game loaded successfully!";
      },
    );
    isLoading.value = false;
  }
}
