import 'package:flutter/material.dart';

import 'app.dart';
import 'core/localization/locale_controller.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/encouragements/application/encouragement_controller.dart';
import 'features/encouragements/data/encouragements_api.dart';
import 'features/games/application/game_result_controller.dart';
import 'features/games/application/games_controller.dart';
import 'features/games/data/game_results_api.dart';
import 'features/games/data/games_api.dart';
import 'features/home/application/home_controller.dart';
import 'features/home/data/patient_api.dart';
import 'features/memories/application/memories_controller.dart';
import 'features/memories/data/memories_api.dart';
import 'features/profile/application/profile_controller.dart';
import 'features/profile/data/profile_api.dart';
import 'features/progress/application/progress_controller.dart';
import 'features/progress/data/progress_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final apiClient = ApiClient();
  final authRepository = AuthRepository(AuthApi(apiClient), storage);
  final authController = AuthController(authRepository);
  final localeController = LocaleController();
  final homeController = HomeController(PatientApi(apiClient), storage);
  final gamesController = GamesController(GamesApi(apiClient), storage);
  final gameResultController = GameResultController(
    GameResultsApi(apiClient),
    PatientApi(apiClient),
    storage,
  );
  final progressController = ProgressController(
    ProgressApi(apiClient),
    GamesApi(apiClient),
    storage,
  );
  final profileController = ProfileController(ProfileApi(apiClient), storage);
  final memoriesController = MemoriesController(
    MemoriesApi(apiClient),
    PatientApi(apiClient),
    storage,
  );
  final encouragementController = EncouragementController(
    EncouragementsApi(apiClient),
    storage,
  );

  // Resolve initial auth state from any stored token before the first frame.
  await authController.bootstrap();

  runApp(
    NeuroBridgeApp(
      auth: authController,
      locale: localeController,
      home: homeController,
      games: gamesController,
      gameResults: gameResultController,
      progress: progressController,
      profile: profileController,
      memories: memoriesController,
      encouragements: encouragementController,
    ),
  );
}
