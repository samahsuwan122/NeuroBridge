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
import 'package:neurobridge_mobile/features/games/sequence_recall/application/sequence_recall_controller.dart';
import 'package:neurobridge_mobile/features/games/sequence_recall/presentation/sequence_recall_screen.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

ApiClient _c() => ApiClient();

SequenceRecallController _controller({int rounds = 5}) =>
    SequenceRecallController(random: Random(1), totalRounds: rounds);

Future<void> _pumpScreen(
  WidgetTester tester,
  SequenceRecallController controller,
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
        home: SequenceRecallScreen(controller: controller),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Play every round correctly by driving the controller (no timers/UI).
void _playAllCorrect(SequenceRecallController c) {
  c.start();
  while (!c.isFinished) {
    c.beginInput();
    for (final tile in c.sequence) {
      c.tapTile(tile);
    }
    c.continueGame();
  }
}

void main() {
  // --- controller (deterministic random) -------------------------------------

  test('starts in the idle state', () {
    final c = _controller();
    expect(c.status, SequenceStatus.idle);
    expect(c.completedRounds, 0);
  });

  test('start deals the first sequence and enters watch', () {
    final c = _controller();
    c.start();
    expect(c.status, SequenceStatus.watch);
    expect(c.sequence.length, c.startLength);
  });

  test('beginInput switches to input mode', () {
    final c = _controller();
    c.start();
    c.beginInput();
    expect(c.status, SequenceStatus.input);
    expect(c.inputLength, 0);
  });

  test('a correct repeat increases the correct count', () {
    final c = _controller();
    c.start();
    c.beginInput();
    for (final tile in c.sequence) {
      c.tapTile(tile);
    }
    expect(c.correctCount, 1);
    expect(c.mistakeCount, 0);
    expect(c.lastRoundCorrect, isTrue);
    expect(c.longestSequence, c.startLength);
    expect(c.status, SequenceStatus.roundResult);
  });

  test('a wrong tap increases the mistake count', () {
    final c = _controller();
    c.start();
    c.beginInput();
    final wrong = (c.sequence.first + 1) % c.tileCount;
    c.tapTile(wrong);
    expect(c.mistakeCount, 1);
    expect(c.correctCount, 0);
    expect(c.lastRoundCorrect, isFalse);
    expect(c.status, SequenceStatus.roundResult);
  });

  test('after all rounds it finishes with score/accuracy/longest', () {
    final c = _controller(rounds: 5);
    _playAllCorrect(c);
    expect(c.isFinished, isTrue);
    expect(c.completedRounds, 5);
    expect(c.correctCount, 5);
    expect(c.accuracyPercent, 100);
    expect(c.longestSequence, c.startLength + 4); // grows each round
  });

  test('result metrics are performance-only (no diagnostic keys)', () {
    final c = _controller(rounds: 5);
    _playAllCorrect(c);
    final m = c.resultMetrics;
    expect(m['exercise_type'], 'sequence_recall');
    expect(m['round_count'], 5);
    expect(m['correct_count'], 5);
    expect(m['mistake_count'], 0);
    expect(m['longest_sequence'], c.startLength + 4);
    expect(m['accuracy_percent'], 100);
    for (final key in m.keys) {
      for (final bad in ['diagnosis', 'disease', 'dementia', 'alzheimer',
        'interpretation']) {
        expect(key.toLowerCase().contains(bad), isFalse);
      }
    }
  });

  // --- screen (inject controller; drive directly, no real timers) ------------

  testWidgets('initial instructions render', (tester) async {
    await _pumpScreen(tester, _controller());
    expect(find.textContaining('Watch the sequence, then repeat'), findsOneWidget);
    expect(find.textContaining('not a medical assessment'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('starting shows the watch state', (tester) async {
    final c = _controller();
    await _pumpScreen(tester, c);
    c.start();
    await tester.pump();
    expect(find.text('Watch the sequence'), findsOneWidget);
  });

  testWidgets('input mode renders tappable tiles', (tester) async {
    final c = _controller();
    await _pumpScreen(tester, c);
    c.start();
    c.beginInput();
    await tester.pump();
    expect(find.text('Repeat the sequence'), findsOneWidget);
    expect(find.byKey(const ValueKey('seq_tile_0')), findsOneWidget);
  });

  testWidgets('repeating the sequence shows correct feedback', (tester) async {
    final c = _controller();
    await _pumpScreen(tester, c);
    c.start();
    c.beginInput();
    await tester.pump();
    for (final tile in c.sequence) {
      await tester.tap(find.byKey(ValueKey('seq_tile_$tile')));
      await tester.pump();
    }
    expect(c.correctCount, 1);
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('final summary shows longest/accuracy', (tester) async {
    final c = _controller(rounds: 5);
    await _pumpScreen(tester, c);
    _playAllCorrect(c);
    await tester.pumpAndSettle();
    expect(find.text('Exercise complete'), findsOneWidget);
    expect(find.text('Longest'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);
  });

  testWidgets('sequence recall screens contain no diagnosis/medical text',
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
