import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/theme/app_theme.dart';
import 'package:neurobridge_mobile/models/exercise.dart';
import 'package:neurobridge_mobile/screens/patient/audio_memory_screen.dart';
import 'package:neurobridge_mobile/screens/patient/categorization_screen.dart';
import 'package:neurobridge_mobile/screens/patient/emotion_recognition_screen.dart';
import 'package:neurobridge_mobile/screens/patient/exercise_details_screen.dart';
import 'package:neurobridge_mobile/screens/patient/exercise_play_resolver.dart';
import 'package:neurobridge_mobile/screens/patient/exercises_screen.dart';
import 'package:neurobridge_mobile/screens/patient/picture_recognition_screen.dart';
import 'package:neurobridge_mobile/screens/patient/sequence_screen.dart';
import 'package:neurobridge_mobile/screens/patient/spot_difference_screen.dart';
import 'package:neurobridge_mobile/screens/patient/word_recall_screen.dart';

void main() {
  test('every configured exercise resolves to a distinct playable type', () {
    final resolvedTypes = ExerciseCatalog.all
        .map((exercise) => resolveExercisePlayScreen(exercise.type).runtimeType)
        .toSet();

    expect(ExerciseCatalog.all, hasLength(8));
    expect(resolvedTypes, hasLength(ExerciseCatalog.all.length));

    for (final exercise in ExerciseCatalog.all) {
      expect(exercisePlayRoute(exercise).settings.name,
          '/exercises/${exercise.id}/play');
    }
  });

  final launchCases = <(String, Type)>[
    ('memory', AudioMemoryScreen),
    ('language', WordRecallScreen),
    ('visual-perception', PictureRecognitionScreen),
  ];

  for (final launchCase in launchCases) {
    testWidgets('${launchCase.$1} card starts its configured playable screen',
        (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final exercise = ExerciseCatalog.all.singleWhere(
        (item) => item.id == launchCase.$1,
      );

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ExercisesScreen()),
      );
      await tester.pumpAndSettle();

      final cardTitle = find.text(exercise.title);
      await tester.ensureVisible(cardTitle);
      await tester.tap(cardTitle);
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailsScreen), findsOneWidget);
      expect(find.text(exercise.title), findsOneWidget);

      final startButton =
          find.widgetWithIcon(FilledButton, Icons.play_arrow_rounded);
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.byType(launchCase.$2), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  final backCases = <Widget>[
    const AudioMemoryScreen(),
    const CategorizationScreen(),
    const PictureRecognitionScreen(),
    const SequenceScreen(),
    const SpotDifferenceScreen(),
    const EmotionRecognitionScreen(),
  ];

  for (final screen in backCases) {
    testWidgets('${screen.runtimeType} has a working visible back button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => screen),
                    );
                  },
                  child: const Text('Open exercise'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open exercise'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open exercise'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
