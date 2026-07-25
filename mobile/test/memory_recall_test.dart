import 'dart:math';

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
import 'package:neurobridge_mobile/features/games/memory_recall/application/memory_recall_controller.dart';
import 'package:neurobridge_mobile/features/games/memory_recall/data/memory_recall_question.dart';
import 'package:neurobridge_mobile/features/games/memory_recall/presentation/memory_recall_screen.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/memories/data/memory_entry.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

MemoryEntry _m(String id,
        {String? person, String? place, String? category}) =>
    MemoryEntry(
      id: id,
      title: 'Memory $id',
      personName: person,
      placeName: place,
      category: category,
    );

/// Three memories with distinct fields → enough for person/place/category qs.
List<MemoryEntry> _richMemories() => [
      _m('1', person: 'Layla', place: 'City Park', category: 'family'),
      _m('2', person: 'Omar', place: 'The Beach', category: 'trip'),
      _m('3', person: 'Sara', place: 'Home', category: 'holiday'),
    ];

class _FakeMemoriesApi extends MemoriesApi {
  _FakeMemoriesApi(this._memories) : super(ApiClient());
  final List<MemoryEntry> _memories;
  @override
  Future<List<MemoryEntry>> listMemories(String token) async => _memories;
}

class _FakeStorage extends SecureStorageService {
  @override
  Future<String?> readAccessToken() async => 'token';
}

MemoryRecallController _controller(List<MemoryEntry> memories) =>
    MemoryRecallController(_FakeMemoriesApi(memories), _FakeStorage(),
        random: Random(1));

ApiClient _c() => ApiClient();

Future<void> _pumpRecall(
  WidgetTester tester, {
  required MemoryRecallController controller,
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
      memories: MemoriesController(MemoriesApi(_c()), PatientApi(_c()), storage),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // game: null so the screen does not attempt a network submit.
        home: MemoryRecallScreen(controller: controller),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // --- question generation ---------------------------------------------------

  test('generates a person question with the correct answer among options', () {
    final qs = generateMemoryRecallQuestions(_richMemories(), random: Random(1));
    final person = qs.where((q) => q.type == RecallQuestionType.person);
    expect(person, isNotEmpty);
    final q = person.first;
    expect(q.options, contains(q.correctAnswer));
    expect(q.options.length, inInclusiveRange(2, 4));
  });

  test('generates a place question', () {
    final qs = generateMemoryRecallQuestions(_richMemories(), random: Random(1));
    expect(qs.any((q) => q.type == RecallQuestionType.place), isTrue);
  });

  test('generates a category question', () {
    final qs = generateMemoryRecallQuestions(_richMemories(), random: Random(1));
    expect(qs.any((q) => q.type == RecallQuestionType.category), isTrue);
  });

  test('a single memory yields no questions (no distractors)', () {
    final qs = generateMemoryRecallQuestions(
        [_m('1', person: 'Layla', place: 'Park', category: 'family')]);
    expect(qs, isEmpty);
  });

  // --- controller ------------------------------------------------------------

  test('load with too few memories -> insufficient', () async {
    final c = _controller([_m('1', person: 'Layla')]);
    await c.load();
    expect(c.status, RecallStatus.insufficient);
  });

  test('load with rich memories -> ready with questions', () async {
    final c = _controller(_richMemories());
    await c.load();
    expect(c.status, RecallStatus.ready);
    expect(c.total, greaterThanOrEqualTo(kMinRecallQuestions));
  });

  test('missing token -> error (no crash)', () async {
    final c = MemoryRecallController(
        _FakeMemoriesApi(_richMemories()), _NoTokenStorage(),
        random: Random(1));
    await c.load();
    expect(c.status, RecallStatus.error);
  });

  test('selecting the correct answer updates the score once', () async {
    final c = _controller(_richMemories());
    await c.load();
    final q = c.currentQuestion!;
    c.answer(q.options.indexOf(q.correctAnswer));
    expect(c.score, 1);
    expect(c.answeredCorrectly, isTrue);
    // A second answer does not double-count.
    c.answer(0);
    expect(c.score, 1);
  });

  test('result metrics are performance-only (no diagnostic keys)', () async {
    final c = _controller(_richMemories());
    await c.load();
    while (!c.isFinished) {
      final q = c.currentQuestion!;
      c.answer(q.options.indexOf(q.correctAnswer));
      c.next();
    }
    final metrics = c.resultMetrics;
    expect(metrics['exercise_type'], 'memory_recall');
    expect(metrics['question_count'], c.total);
    expect(metrics['correct_count'], c.total); // all answered correctly
    expect(metrics['memory_entry_ids'], isA<List>());
    for (final key in metrics.keys) {
      for (final bad in ['diagnosis', 'disease', 'dementia', 'alzheimer',
        'interpretation']) {
        expect(key.toLowerCase().contains(bad), isFalse);
      }
    }
  });

  // --- screen ----------------------------------------------------------------

  testWidgets('insufficient memories shows a friendly message', (tester) async {
    await _pumpRecall(tester, controller: _controller([_m('1', person: 'A')]));
    expect(find.text('Add more memories to start this exercise.'),
        findsOneWidget);
  });

  testWidgets('ready state shows the supportive note and progress',
      (tester) async {
    await _pumpRecall(tester, controller: _controller(_richMemories()));
    expect(find.textContaining('supportive recall activity'), findsOneWidget);
    expect(find.textContaining(' / '), findsOneWidget); // "1 / N" progress
  });

  testWidgets('final summary shows the score', (tester) async {
    final c = _controller(_richMemories());
    await _pumpRecall(tester, controller: c);
    while (!c.isFinished) {
      final q = c.currentQuestion!;
      c.answer(q.options.indexOf(q.correctAnswer));
      c.next();
    }
    await tester.pumpAndSettle();
    expect(find.text('Exercise complete'), findsOneWidget);
    expect(find.textContaining('${c.score}/${c.total}'), findsOneWidget);
  });

  testWidgets('memory recall screens contain no diagnosis/medical text',
      (tester) async {
    await _pumpRecall(tester, controller: _controller(_richMemories()));
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

class _NoTokenStorage extends SecureStorageService {
  @override
  Future<String?> readAccessToken() async => null;
}
