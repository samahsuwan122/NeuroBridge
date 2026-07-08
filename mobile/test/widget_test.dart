import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/app.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';

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

    await tester.pumpWidget(
      NeuroBridgeApp(auth: auth, locale: locale, home: home, games: games),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Email or phone'), findsOneWidget);
  });
}
