// lib/presentation/bindings/game_binding.dart
import 'package:get/get.dart';

import '../../data/ai_engine.dart';
import '../../data/local_storage_service.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/game_repository_impl.dart';
import '../../domain/usecases/get_best_move_usecase.dart';
import '../../domain/usecases/get_legel_moves_usecase.dart';
import '../../domain/usecases/make_move_usecase.dart';
import '../controllers/game_controller.dart';
import '../controllers/get_options_controller.dart';

/// GetX Binding for setting up all the dependencies for the game.
/// This ensures that controllers, use cases, repositories, and services are
/// initialized and available throughout the app as needed (lazy-loaded).
class GameBinding extends Bindings {
  @override
  void dependencies() {
    // Data Layer: Register concrete implementations of services and repositories
    Get.lazyPut<LocalStorageService>(
      () => LocalStorageService(),
      fenix: true,
    ); // Local storage service
    Get.lazyPut<AIEngine>(() => AIEngine(), fenix: true); // AI logic engine

    // GameRepositoryImpl depends on LocalStorageService and AIEngine
    Get.lazyPut<GameRepository>(
      () => GameRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );

    // Domain Layer: Register use cases. They depend on the GameRepository interface.
    Get.lazyPut<MakeMoveUseCase>(
      () => MakeMoveUseCase(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetLegalMovesUseCase>(
      () => GetLegalMovesUseCase(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetBestMoveUseCase>(
      () => GetBestMoveUseCase(Get.find()),
      fenix: true,
    );
    // make this controller singleton
    Get.lazyPut<GameOptionsController>(
      () => GameOptionsController(),
      fenix: true,
    );
    // Presentation Layer: Register the GameController.
    // It depends on the use cases and GameRepository.
    Get.lazyPut<GameController>(
      () => GameController(
        makeMoveUseCase: Get.find(),
        getLegalMovesUseCase: Get.find(),
        getBestMoveUseCase: Get.find(),
        gameRepository: Get.find(),
        aiEngine: Get.find(),
      ),
      fenix: true, // Make this controller singleton
    );
  }
}
