import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:neurobridge_mobile/app.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_user.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';

/// Auth controller that reports an authenticated user without any network.
class _FakeAuth extends AuthController {
  _FakeAuth(this._fakeUser)
      : super(
          AuthRepository(AuthApi(ApiClient()), SecureStorageService()),
        );

  final AuthUser _fakeUser;

  @override
  AuthUser? get user => _fakeUser;
  @override
  bool get isAuthenticated => true;
  @override
  AuthStatus get status => AuthStatus.authenticated;
  @override
  Future<void> logout() async {}
}

/// Home controller with a fixed status and no network (`load` is a no-op).
class _FakeHome extends HomeController {
  _FakeHome(this._fakeStatus)
      : super(PatientApi(ApiClient()), SecureStorageService());

  final HomeStatus _fakeStatus;

  @override
  HomeStatus get status => _fakeStatus;
  @override
  Future<void> load() async {}
}

Future<void> _pumpHome(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  HomeStatus home = HomeStatus.empty,
  List<String> roles = const ['patient'],
}) async {
  final auth = _FakeAuth(AuthUser(fullName: 'Sara Ali', roles: roles));
  await tester.pumpWidget(
    NeuroBridgeApp(
      auth: auth,
      locale: LocaleController(locale),
      home: _FakeHome(home),
      games: GamesController(GamesApi(ApiClient()), SecureStorageService()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the user name and roles', (tester) async {
    await _pumpHome(tester);
    expect(find.text('Welcome, Sara Ali'), findsOneWidget);
    expect(find.textContaining('patient'), findsWidgets);
  });

  testWidgets('home shows all dashboard cards (English)', (tester) async {
    await _pumpHome(tester);
    expect(find.text("Today's Therapy"), findsOneWidget);
    expect(find.text('Cognitive Games'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Family Support'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);
  });

  testWidgets('home shows Arabic labels when locale is ar', (tester) async {
    await _pumpHome(tester, locale: const Locale('ar'));
    expect(find.text('الألعاب الإدراكية'), findsOneWidget); // Cognitive Games
    expect(find.text('التذكيرات'), findsOneWidget); // Reminders
  });

  testWidgets('empty profile shows a safe placeholder message', (tester) async {
    await _pumpHome(tester, home: HomeStatus.empty);
    expect(find.text('No patient profile linked yet.'), findsOneWidget);
  });

  testWidgets('home shows a logout button', (tester) async {
    await _pumpHome(tester);
    expect(find.text('Log out'), findsOneWidget);
  });
}
