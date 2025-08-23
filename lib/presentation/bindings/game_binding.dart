// lib/presentation/bindings/game_binding.dart
import 'package:chess_gemini_2/domain/usecases/play_sound_usecase.dart';
import 'package:get/get.dart';

import '../../data/local_storage_service.dart';
import '../../domain/repositories/audio_player_service_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/game_repository_impl.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/usecases/get_ai_move.dart';
import '../../domain/usecases/get_board_state.dart';
import '../../domain/usecases/get_game_result.dart';
import '../../domain/usecases/get_legal_moves.dart';
import '../../domain/usecases/is_king_in_check.dart';
import '../../domain/usecases/make_move.dart';
import '../../domain/usecases/reset_game.dart';
import '../controllers/game_controller.dart';
import '../controllers/get_options_controller.dart';

/// [GameBinding]
/// يربط الاعتمادات (dependencies) لوحدة اللعبة.
/// Binds the dependencies for the game module.
class GameBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل GetAIMoveUseCase
    // Register GetAIMoveUseCase
    // Get.lazyPut<GetAIMoveUseCase>(
    //   () => GetAIMoveUseCase(Get.find<AIGameRepositoryImpl>()),
    // );

    // Data Layer: Register concrete implementations of services and repositories
    Get.lazyPut<LocalStorageService>(
      () => LocalStorageService(),
      fenix: true,
    ); // Local storage service

    // GameRepositoryImpl depends on LocalStorageService and AIEngine
    Get.lazyPut<GameRepository>(() => GameRepositoryImpl(), fenix: true);

    // make this controller singleton
    Get.lazyPut<GameOptionsController>(
      () => GameOptionsController(),
      fenix: true,
    );

    // تسجيل الـ Repository
    Get.lazyPut<GameRepository>(() => GameRepositoryImpl());

    // تسجيل الـ Use Cases
    Get.lazyPut(
      () => GetBoardState(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => GetLegalMoves(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => MakeMove(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => ResetGame(Get.find<GameRepository>()),

      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => GetGameResult(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => IsKingInCheck(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    );
    Get.lazyPut(
      () => GetAiMove(Get.find<GameRepository>()),
      fenix: true, // Make this controller singleton
    ); // تسجيل جديد
    Get.lazyPut<AudioPlayerService>(
      () => AudioPlayerServiceImpl(),
      fenix: true, // Make this controller singleton
    ); // تسجيل جديد
    Get.lazyPut(
      () => PlaySoundUseCase(Get.find<AudioPlayerService>()),
      fenix: true, // Make this controller singleton
    ); // تسجيل جديد

    // تسجيل المتحكم (Controller)
    Get.lazyPut<GameController>(
      () => GameController(
        getBoardState: Get.find<GetBoardState>(),
        getLegalMoves: Get.find<GetLegalMoves>(),
        makeMove: Get.find<MakeMove>(),
        resetGame: Get.find<ResetGame>(),
        getGameResult: Get.find<GetGameResult>(),
        isKingInCheck: Get.find<IsKingInCheck>(),
        // getAiMove: Get.find<GetAiMove>(),
        getAIMoveUseCase: Get.find(),
        playSoundUseCase: Get.find<PlaySoundUseCase>(),
      ),
      fenix: true, // Make this controller singleton
    );
  }
}
