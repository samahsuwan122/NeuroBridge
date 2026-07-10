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
import 'package:neurobridge_mobile/features/auth/data/auth_user.dart';
import 'package:neurobridge_mobile/features/games/application/game_result_controller.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/game_definition.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/games/presentation/game_details_screen.dart';
import 'package:neurobridge_mobile/features/games/presentation/games_screen.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/home/presentation/home_screen.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

class _FakeAuth extends AuthController {
  _FakeAuth()
      : super(AuthRepository(AuthApi(ApiClient()), SecureStorageService()));
  @override
  AuthUser? get user => const AuthUser(fullName: 'Sara Ali', roles: ['patient']);
  @override
  bool get isAuthenticated => true;
  @override
  AuthStatus get status => AuthStatus.authenticated;
  @override
  Future<void> logout() async {}
}

class _FakeHome extends HomeController {
  _FakeHome() : super(PatientApi(ApiClient()), SecureStorageService());
  @override
  HomeStatus get status => HomeStatus.empty;
  @override
  Future<void> load() async {}
}

class _FakeGames extends GamesController {
  _FakeGames(this._status, [this._games = const []])
      : super(GamesApi(ApiClient()), SecureStorageService());
  final GamesStatus _status;
  final List<GameDefinition> _games;
  @override
  GamesStatus get status => _status;
  @override
  List<GameDefinition> get games => _games;
  @override
  Future<void> load() async {}
}

const _memoryMatch = GameDefinition(
  id: '1',
  name: 'Memory Match',
  slug: 'memory_match',
  gameType: 'memory',
  difficulty: 'easy',
  description: 'Match pairs of cards.',
  instructions: 'Flip two cards at a time.',
  estimatedDurationMinutes: 5,
);
const _reactionTime = GameDefinition(
  id: '2',
  name: 'Reaction Time',
  slug: 'reaction_time',
  gameType: 'reaction',
  difficulty: 'easy',
);
const _sequenceOrder = GameDefinition(
  id: '3',
  name: 'Sequence Order',
  slug: 'sequence_order',
  gameType: 'sequence',
  difficulty: 'medium',
);
// A game that is not playable yet (still shows the coming-later note).
const _futureGame = GameDefinition(
  id: '9',
  name: 'Word Recall',
  slug: 'word_recall',
  gameType: 'language',
  difficulty: 'easy',
);

Future<void> _wrap(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  GamesController? games,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    AppScope(
      auth: _FakeAuth(),
      locale: LocaleController(locale),
      home: _FakeHome(),
      games: games ?? _FakeGames(GamesStatus.empty),
      gameResults: GameResultController(
        GameResultsApi(ApiClient()),
        PatientApi(ApiClient()),
        SecureStorageService(),
      ),
      progress: ProgressController(
        ProgressApi(ApiClient()),
        GamesApi(ApiClient()),
        SecureStorageService(),
      ),
      profile: ProfileController(ProfileApi(ApiClient()), SecureStorageService()),
      memories: MemoriesController(
        MemoriesApi(ApiClient()),
        PatientApi(ApiClient()),
        SecureStorageService(),
      ),
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Avoid pumpAndSettle here: a CircularProgressIndicator animates forever.
    // Two pumps let async localization resolve and the widget rebuild.
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  testWidgets('games screen shows a loading indicator', (tester) async {
    await _wrap(tester, const GamesScreen(),
        games: _FakeGames(GamesStatus.loading), settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('games screen shows a safe empty message', (tester) async {
    await _wrap(tester, const GamesScreen(),
        games: _FakeGames(GamesStatus.empty));
    expect(find.text('No games available yet.'), findsOneWidget);
  });

  testWidgets('games screen shows game cards', (tester) async {
    await _wrap(
      tester,
      const GamesScreen(),
      games: _FakeGames(GamesStatus.loaded, const [_memoryMatch, _reactionTime]),
    );
    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.text('Reaction Time'), findsOneWidget);
    expect(find.textContaining('Difficulty'), findsWidgets);
  });

  testWidgets('not-yet-playable game details shows the coming-later note',
      (tester) async {
    await _wrap(tester, const GameDetailsScreen(game: _futureGame));
    expect(find.text('Word Recall'), findsWidgets);
    expect(
      find.text('Game play will be added in a later phase.'),
      findsOneWidget,
    );
  });

  testWidgets('memory_match details shows a Play button', (tester) async {
    await _wrap(tester, const GameDetailsScreen(game: _memoryMatch));
    expect(find.text('Play'), findsOneWidget);
    expect(
      find.text('Game play will be added in a later phase.'),
      findsNothing,
    );
  });

  testWidgets('reaction_time details shows a Play button', (tester) async {
    await _wrap(tester, const GameDetailsScreen(game: _reactionTime));
    expect(find.text('Play'), findsOneWidget);
    expect(
      find.text('Game play will be added in a later phase.'),
      findsNothing,
    );
  });

  testWidgets('sequence_order details shows a Play button', (tester) async {
    await _wrap(tester, const GameDetailsScreen(game: _sequenceOrder));
    expect(find.text('Play'), findsOneWidget);
    expect(
      find.text('Game play will be added in a later phase.'),
      findsNothing,
    );
  });

  testWidgets('games screen renders Arabic labels', (tester) async {
    await _wrap(tester, const GamesScreen(),
        locale: const Locale('ar'), games: _FakeGames(GamesStatus.empty));
    expect(find.text('الألعاب الإدراكية'), findsOneWidget); // screen title
    expect(find.text('لا توجد ألعاب متاحة بعد.'), findsOneWidget); // empty
  });

  testWidgets('home has a Cognitive Games card', (tester) async {
    await _wrap(tester, const HomeScreen());
    expect(find.text('Cognitive Games'), findsOneWidget);
  });
}
