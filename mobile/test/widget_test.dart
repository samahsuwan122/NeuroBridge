import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/app.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';
import 'package:neurobridge_mobile/features/games/application/game_result_controller.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

void main() {
  testWidgets('unauthenticated app shows the login screen', (tester) async {
    // No network calls: bootstrap() is not invoked and no login is attempted,
    // so secure storage / the API are never touched.
    final storage = SecureStorageService();
    final apiClient = ApiClient();
    final auth = AuthController(AuthRepository(AuthApi(apiClient), storage));
    final locale = LocaleController();
    final home = HomeController(PatientApi(apiClient), storage);
    final games = GamesController(GamesApi(apiClient), storage);
    final gameResults = GameResultController(
      GameResultsApi(apiClient),
      PatientApi(apiClient),
      storage,
    );
    final progress = ProgressController(
      ProgressApi(apiClient),
      GamesApi(apiClient),
      storage,
    );
    final profile = ProfileController(ProfileApi(apiClient), storage);

    await tester.pumpWidget(
      NeuroBridgeApp(
        auth: auth,
        locale: locale,
        home: home,
        games: games,
        gameResults: gameResults,
        progress: progress,
        profile: profile,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Email or phone'), findsOneWidget);
  });
}
