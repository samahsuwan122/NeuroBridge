import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/app.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('unauthenticated app shows the login screen', (tester) async {
    // No network calls are made here: bootstrap() is not invoked and no login
    // is attempted, so secure storage / the API are never touched.
    final auth = AuthController(
      AuthRepository(AuthApi(ApiClient()), SecureStorageService()),
    );
    final locale = LocaleController();

    await tester.pumpWidget(NeuroBridgeApp(auth: auth, locale: locale));
    await tester.pumpAndSettle();

    // The login title appears (app bar + button both read "Sign in").
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Email or phone'), findsOneWidget);
  });
}
