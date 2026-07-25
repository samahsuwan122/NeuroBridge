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
import 'package:neurobridge_mobile/features/games/reaction_time/application/reaction_time_controller.dart';
import 'package:neurobridge_mobile/features/games/reaction_time/presentation/reaction_time_screen.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

/// A clock we can advance deterministically in tests (no real time).
class _FakeClock {
  DateTime now = DateTime(2024, 1, 1);
  void advanceMs(int ms) => now = now.add(Duration(milliseconds: ms));
}

ApiClient _c() => ApiClient();

Future<void> _pumpScreen(
  WidgetTester tester,
  ReactionTimeController controller,
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
        home: ReactionTimeScreen(controller: controller),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Play one valid round on the controller with a fixed reaction time.
void _playRound(ReactionTimeController c, _FakeClock clock, int reactionMs) {
  c.beginRound();
  c.signalGo();
  clock.advanceMs(reactionMs);
  c.tap();
}

void main() {
  // --- controller (deterministic clock) --------------------------------------

  test('starts in the idle state', () {
    final c = ReactionTimeController(clock: () => DateTime(2024));
    expect(c.status, ReactionStatus.idle);
    expect(c.completedRounds, 0);
  });

  test('tapping before the signal is too soon and is not counted', () {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now);
    c.beginRound();
    c.tap(); // still waiting
    expect(c.status, ReactionStatus.tooSoon);
    expect(c.completedRounds, 0);
  });

  test('a valid tap records the reaction time', () {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now);
    c.beginRound();
    c.signalGo();
    clock.advanceMs(250);
    c.tap();
    expect(c.lastReactionMs, 250);
    expect(c.status, ReactionStatus.roundResult);
    expect(c.completedRounds, 1);
  });

  test('after all rounds it finishes with best/average', () {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now, totalRounds: 5);
    for (final ms in [200, 210, 220, 230, 240]) {
      _playRound(c, clock, ms);
    }
    expect(c.isFinished, isTrue);
    expect(c.completedRounds, 5);
    expect(c.bestReactionMs, 200);
    expect(c.averageReactionMs, 220);
    expect(c.reactionTimesMs, [200, 210, 220, 230, 240]);
  });

  test('result metrics are performance-only (no diagnostic keys)', () {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now, totalRounds: 3);
    for (final ms in [300, 320, 280]) {
      _playRound(c, clock, ms);
    }
    final m = c.resultMetrics;
    expect(m['exercise_type'], 'reaction_time');
    expect(m['round_count'], 3);
    expect(m['best_reaction_ms'], 280);
    expect(m['reaction_times_ms'], [300, 320, 280]);
    for (final key in m.keys) {
      for (final bad in ['diagnosis', 'disease', 'dementia', 'alzheimer',
        'interpretation']) {
        expect(key.toLowerCase().contains(bad), isFalse);
      }
    }
  });

  // --- screen (inject controller; drive directly, no real timers) ------------

  testWidgets('initial instructions render', (tester) async {
    await _pumpScreen(tester, ReactionTimeController(random: Random(1)));
    expect(find.textContaining('Tap as fast as you can'), findsOneWidget);
    expect(find.textContaining('not a medical assessment'), findsOneWidget);
    expect(find.text('Start round'), findsOneWidget);
  });

  testWidgets('tapping too soon shows the Too soon message', (tester) async {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now);
    await _pumpScreen(tester, c);
    c.beginRound(); // enter waiting without scheduling a real timer
    await tester.pump();
    await tester.tap(find.byKey(const Key('reaction_tap_area')));
    await tester.pump();
    expect(find.text('Too soon! Wait for the signal.'), findsOneWidget);
  });

  testWidgets('final summary shows best/average/rounds', (tester) async {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now, totalRounds: 5);
    await _pumpScreen(tester, c);
    for (final ms in [200, 220, 240, 260, 280]) {
      _playRound(c, clock, ms);
    }
    await tester.pumpAndSettle();
    expect(find.text('Exercise complete'), findsOneWidget);
    expect(find.textContaining('200 ms'), findsOneWidget); // best
    expect(find.text('Best'), findsOneWidget);
    expect(find.text('Average'), findsOneWidget);
  });

  testWidgets('reaction time screens contain no diagnosis/medical text',
      (tester) async {
    final clock = _FakeClock();
    final c = ReactionTimeController(clock: () => clock.now, totalRounds: 3);
    await _pumpScreen(tester, c);
    for (final ms in [300, 320, 280]) {
      _playRound(c, clock, ms);
    }
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
