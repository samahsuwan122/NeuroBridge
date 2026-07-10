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
import 'package:neurobridge_mobile/features/games/attention_tap/application/attention_tap_controller.dart';
import 'package:neurobridge_mobile/features/games/attention_tap/presentation/attention_tap_screen.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

ApiClient _c() => ApiClient();

AttentionTapController _controller({int rounds = 10}) =>
    AttentionTapController(random: Random(1), totalRounds: rounds);

Future<void> _pumpScreen(
  WidgetTester tester,
  AttentionTapController controller,
) async {
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
        home: AttentionTapScreen(controller: controller),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tap the target cell each round until the exercise finishes (all correct).
void _playAllCorrect(AttentionTapController c) {
  c.start();
  while (!c.isFinished) {
    c.tapCell(c.cells.indexOf(c.target!));
  }
}

void main() {
  // --- controller (deterministic random) -------------------------------------

  test('starts in the idle state', () {
    final c = _controller();
    expect(c.status, AttentionStatus.idle);
    expect(c.completedRounds, 0);
  });

  test('start deals a grid with the target present', () {
    final c = _controller();
    c.start();
    expect(c.status, AttentionStatus.playing);
    expect(c.cells.length, c.gridSize);
    expect(c.target, isNotNull);
    expect(c.cells, contains(c.target));
  });

  test('a correct tap increases the correct count', () {
    final c = _controller();
    c.start();
    c.tapCell(c.cells.indexOf(c.target!));
    expect(c.correctCount, 1);
    expect(c.mistakeCount, 0);
    expect(c.lastTapCorrect, isTrue);
  });

  test('a distractor tap increases the mistake count', () {
    final c = _controller();
    c.start();
    final wrong = c.cells.indexWhere((icon) => icon != c.target);
    c.tapCell(wrong);
    expect(c.mistakeCount, 1);
    expect(c.correctCount, 0);
    expect(c.lastTapCorrect, isFalse);
  });

  test('after all rounds it finishes with score and accuracy', () {
    final c = _controller(rounds: 10);
    _playAllCorrect(c);
    expect(c.isFinished, isTrue);
    expect(c.completedRounds, 10);
    expect(c.correctCount, 10);
    expect(c.accuracyPercent, 100);
  });

  test('result metrics are performance-only (no diagnostic keys)', () {
    final c = _controller(rounds: 5);
    _playAllCorrect(c);
    final m = c.resultMetrics;
    expect(m['exercise_type'], 'attention_tap');
    expect(m['round_count'], 5);
    expect(m['correct_count'], 5);
    expect(m['mistake_count'], 0);
    expect(m['accuracy_percent'], 100);
    for (final key in m.keys) {
      for (final bad in ['diagnosis', 'disease', 'dementia', 'alzheimer',
        'interpretation']) {
        expect(key.toLowerCase().contains(bad), isFalse);
      }
    }
  });

  // --- screen (inject controller) --------------------------------------------

  testWidgets('initial instructions render', (tester) async {
    await _pumpScreen(tester, _controller());
    expect(find.textContaining('Tap the target and ignore'), findsOneWidget);
    expect(find.textContaining('not a medical assessment'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('starting shows the target instruction and grid', (tester) async {
    final c = _controller();
    await _pumpScreen(tester, c);
    c.start();
    await tester.pump();
    expect(find.text('Tap the target'), findsOneWidget);
    expect(find.byKey(const ValueKey('attention_cell_0')), findsOneWidget);
  });

  testWidgets('tapping the target cell shows correct feedback', (tester) async {
    final c = _controller();
    await _pumpScreen(tester, c);
    c.start();
    await tester.pump();
    final idx = c.cells.indexOf(c.target!);
    await tester.tap(find.byKey(ValueKey('attention_cell_$idx')));
    await tester.pump();
    expect(c.correctCount, 1);
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('final summary shows correct/accuracy', (tester) async {
    final c = _controller(rounds: 5);
    await _pumpScreen(tester, c);
    _playAllCorrect(c);
    await tester.pumpAndSettle();
    expect(find.text('Exercise complete'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);
  });

  testWidgets('attention tap screens contain no diagnosis/medical text',
      (tester) async {
    final c = _controller(rounds: 5);
    await _pumpScreen(tester, c);
    _playAllCorrect(c);
    await tester.pumpAndSettle();
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
