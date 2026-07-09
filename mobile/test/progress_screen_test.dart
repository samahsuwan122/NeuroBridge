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
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/game_result_summary.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';
import 'package:neurobridge_mobile/features/progress/presentation/progress_screen.dart';

/// Progress controller with a fixed status/results and no network.
class _FakeProgress extends ProgressController {
  _FakeProgress(this._status, [this._results = const []])
      : super(
          ProgressApi(ApiClient()),
          GamesApi(ApiClient()),
          SecureStorageService(),
        );

  final ProgressStatus _status;
  final List<GameResultSummary> _results;

  @override
  ProgressStatus get status => _status;
  @override
  List<GameResultSummary> get results => _results;
  @override
  Future<void> load() async {}
}

ApiClient _client() => ApiClient();

Future<void> _wrap(
  WidgetTester tester,
  ProgressController progress, {
  bool settle = true,
}) async {
  final storage = SecureStorageService();
  await tester.pumpWidget(
    AppScope(
      auth: AuthController(AuthRepository(AuthApi(_client()), storage)),
      locale: LocaleController(),
      home: HomeController(PatientApi(_client()), storage),
      games: GamesController(GamesApi(_client()), storage),
      gameResults: GameResultController(
        GameResultsApi(_client()),
        PatientApi(_client()),
        storage,
      ),
      progress: progress,
      profile: ProfileController(ProfileApi(ApiClient()), SecureStorageService()),
      memories: MemoriesController(
        MemoriesApi(ApiClient()),
        PatientApi(ApiClient()),
        SecureStorageService(),
      ),
      child: const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ProgressScreen(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

GameResultSummary _sampleResult() => GameResultSummary(
      gameId: 'g1',
      gameTitle: 'Memory Match',
      completed: true,
      score: 6,
      maxScore: 6,
      durationSeconds: 12,
      createdAt: DateTime(2026, 7, 9),
      moves: 6,
      mistakes: 0,
    );

void main() {
  testWidgets('progress shows a friendly empty state', (tester) async {
    await _wrap(tester, _FakeProgress(ProgressStatus.empty));
    expect(
      find.text('No results yet. Play a game to see your progress here.'),
      findsOneWidget,
    );
  });

  testWidgets('progress shows a saved result card', (tester) async {
    await _wrap(
      tester,
      _FakeProgress(ProgressStatus.loaded, [_sampleResult()]),
    );
    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.textContaining('6/6'), findsOneWidget); // score/max
    expect(find.textContaining('Completed'), findsWidgets);
  });

  testWidgets('progress error state shows a retry button', (tester) async {
    await _wrap(tester, _FakeProgress(ProgressStatus.error));
    expect(
      find.text('Could not load your progress. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('progress contains no diagnosis/medical text', (tester) async {
    await _wrap(
      tester,
      _FakeProgress(ProgressStatus.loaded, [_sampleResult()]),
    );
    for (final word in ['diagnosis', 'disease', 'dementia', 'alzheimer']) {
      expect(find.textContaining(word), findsNothing);
      expect(find.textContaining(word.toUpperCase()), findsNothing);
    }
  });
}
