import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/app_scope.dart';
import 'package:neurobridge_mobile/core/localization/app_localizations.dart';
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
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/patient_profile_detail.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/profile/presentation/profile_screen.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

class _FakeProfile extends ProfileController {
  _FakeProfile(this._status, [this._profile])
      : super(ProfileApi(ApiClient()), SecureStorageService());

  final ProfileStatus _status;
  final PatientProfileDetail? _profile;

  @override
  ProfileStatus get status => _status;
  @override
  PatientProfileDetail? get profile => _profile;
  @override
  Future<void> load() async {}
}

ApiClient _c() => ApiClient();

Future<void> _wrap(WidgetTester tester, ProfileController profile) async {
  final storage = SecureStorageService();
  await tester.pumpWidget(
    AppScope(
      auth: AuthController(AuthRepository(AuthApi(_c()), storage)),
      locale: LocaleController(),
      home: HomeController(PatientApi(_c()), storage),
      games: GamesController(GamesApi(_c()), storage),
      gameResults: GameResultController(
        GameResultsApi(_c()),
        PatientApi(_c()),
        storage,
      ),
      progress: ProgressController(ProgressApi(_c()), GamesApi(_c()), storage),
      profile: profile,
      memories: MemoriesController(MemoriesApi(_c()), storage),
      child: const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PatientProfileDetail _sample() => PatientProfileDetail(
      id: 'p1',
      fullName: 'Demo Patient',
      email: 'patient.demo@neurobridge.local',
      phone: '+100',
      dateOfBirth: DateTime(2000, 1, 2),
      gender: null, // exercises the "Not provided" fallback
      emergencyContactName: 'Care Giver',
      emergencyContactPhone: '+199',
      createdAt: DateTime(2026, 7, 9),
      allergies: 'Penicillin',
      currentMedications: null, // exercises the "Not provided" fallback
      bloodType: 'O+',
      mobilityNeeds: 'Needs walking support',
      visionHearingNeeds: 'Uses reading glasses',
      preferredCommunication: 'Speak slowly and clearly',
      caregiverNotes: 'Prefers morning activities',
    );

void main() {
  testWidgets('profile shows a friendly empty state', (tester) async {
    await _wrap(tester, _FakeProfile(ProfileStatus.empty));
    expect(find.text('No patient profile linked yet.'), findsOneWidget);
  });

  testWidgets('profile shows loaded fields with fallback', (tester) async {
    await _wrap(tester, _FakeProfile(ProfileStatus.loaded, _sample()));
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Demo Patient'), findsOneWidget);
    expect(find.text('patient.demo@neurobridge.local'), findsOneWidget);
    expect(find.textContaining('Care Giver'), findsOneWidget);
    expect(find.text('Not provided'), findsWidgets); // gender is null
  });

  testWidgets('profile error state shows a retry button', (tester) async {
    await _wrap(tester, _FakeProfile(ProfileStatus.error));
    expect(
      find.text('Could not load your profile. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('profile shows the care & safety section', (tester) async {
    await _wrap(tester, _FakeProfile(ProfileStatus.loaded, _sample()));
    expect(find.text('Care & Safety Information'), findsOneWidget);
    expect(find.text('Allergies'), findsOneWidget);
    expect(find.text('Penicillin'), findsOneWidget);
    expect(find.text('Blood type'), findsOneWidget);
    expect(find.text('O+'), findsOneWidget);
    expect(find.textContaining('Prefers morning activities'), findsOneWidget);
    // Missing care value falls back to "Not provided".
    expect(find.text('Not provided'), findsWidgets);
  });

  testWidgets('profile shows no diagnostic conclusions', (tester) async {
    await _wrap(tester, _FakeProfile(ProfileStatus.loaded, _sample()));
    for (final word in ['disease', 'dementia', 'alzheimer', 'interpretation']) {
      expect(find.textContaining(word), findsNothing);
      expect(find.textContaining(word.toUpperCase()), findsNothing);
    }
    // "diagnosis" appears only in the safe disclaimer ("not a medical diagnosis").
    expect(find.textContaining('not a medical diagnosis'), findsOneWidget);
  });
}
