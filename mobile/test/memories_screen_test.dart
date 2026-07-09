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
import 'package:neurobridge_mobile/features/memories/data/memory_entry.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memories_screen.dart';
import 'package:neurobridge_mobile/features/memories/presentation/memory_details_screen.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

/// Memories controller with a fixed status/list and no network.
class _FakeMemories extends MemoriesController {
  _FakeMemories(this._status, [this._memories = const []])
      : super(MemoriesApi(ApiClient()), SecureStorageService());

  final MemoriesStatus _status;
  final List<MemoryEntry> _memories;

  @override
  MemoriesStatus get status => _status;
  @override
  List<MemoryEntry> get memories => _memories;
  @override
  Future<void> load() async {}
}

ApiClient _c() => ApiClient();

Future<void> _wrap(
  WidgetTester tester,
  Widget child, {
  MemoriesController? memories,
}) async {
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
      profile: ProfileController(ProfileApi(_c()), storage),
      memories: memories ?? _FakeMemories(MemoriesStatus.empty),
      child: MaterialApp(
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
  await tester.pumpAndSettle();
}

MemoryEntry _sample() => MemoryEntry(
      id: 'm1',
      title: 'Family picnic at the park',
      description: 'A sunny afternoon by the lake with the whole family.',
      personName: 'Layla',
      relationship: 'daughter',
      placeName: 'City Park',
      memoryDate: DateTime(2020, 6, 1),
      category: 'family',
      mediaType: 'text',
      createdAt: DateTime(2026, 7, 10),
    );

void main() {
  testWidgets('memory album shows a friendly empty state', (tester) async {
    await _wrap(tester, const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.empty));
    expect(find.text('No memories yet.'), findsOneWidget);
  });

  testWidgets('memory album renders a memory card', (tester) async {
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [_sample()]),
    );
    expect(find.text('Family picnic at the park'), findsOneWidget);
    expect(find.textContaining('Layla'), findsOneWidget);
    expect(find.text('City Park'), findsOneWidget);
  });

  testWidgets('memory album error state shows a retry button', (tester) async {
    await _wrap(tester, const MemoriesScreen(),
        memories: _FakeMemories(MemoriesStatus.error));
    expect(
      find.text('Could not load memories. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('memory details shows the memory fields', (tester) async {
    await _wrap(tester, MemoryDetailsScreen(memory: _sample()));
    expect(find.text('Family picnic at the park'), findsOneWidget);
    expect(find.textContaining('sunny afternoon'), findsOneWidget);
    expect(find.text('Person'), findsOneWidget);
    expect(find.text('Layla'), findsOneWidget);
    expect(find.text('Relationship'), findsOneWidget);
    expect(find.text('Place'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Media type'), findsOneWidget);
  });

  testWidgets('memory album shows the supportive-only safe note',
      (tester) async {
    await _wrap(
      tester,
      const MemoriesScreen(),
      memories: _FakeMemories(MemoriesStatus.loaded, [_sample()]),
    );
    expect(
      find.textContaining('supportive recall activities only'),
      findsOneWidget,
    );
  });

  testWidgets('memory screens contain no diagnosis/medical text',
      (tester) async {
    await _wrap(tester, MemoryDetailsScreen(memory: _sample()));
    for (final word in [
      'diagnosis',
      'disease',
      'dementia',
      'alzheimer',
      'interpretation'
    ]) {
      expect(find.textContaining(word), findsNothing);
      expect(find.textContaining(word.toUpperCase()), findsNothing);
    }
  });
}
