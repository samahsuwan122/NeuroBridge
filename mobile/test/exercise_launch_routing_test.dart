import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/theme/app_theme.dart';
import 'package:neurobridge_mobile/models/exercise.dart';
import 'package:neurobridge_mobile/screens/patient/audio_memory_screen.dart';
import 'package:neurobridge_mobile/screens/patient/card_matching_screen.dart';
import 'package:neurobridge_mobile/screens/patient/categorization_screen.dart';
import 'package:neurobridge_mobile/screens/patient/emotion_recognition_screen.dart';
import 'package:neurobridge_mobile/screens/patient/event_ordering_screen.dart';
import 'package:neurobridge_mobile/screens/patient/exercise_details_screen.dart';
import 'package:neurobridge_mobile/screens/patient/exercise_play_resolver.dart';
import 'package:neurobridge_mobile/screens/patient/picture_recognition_screen.dart';
import 'package:neurobridge_mobile/screens/patient/sequence_screen.dart';
import 'package:neurobridge_mobile/screens/patient/spot_difference_screen.dart';
import 'package:neurobridge_mobile/screens/patient/word_recall_screen.dart';

void main() {
  final exercises = <Exercise>[
    _exercise(1, 'audio-memory', 'audio_memory', 'الذاكرة السمعية'),
    _exercise(2, 'spot-difference', 'spot_difference', 'اكتشف الاختلاف'),
    _exercise(3, 'card-matching', 'card_matching', 'تطابق البطاقات'),
    _exercise(4, 'word-recall', 'word_recall', 'تذكّر الكلمات'),
    _exercise(5, 'categorization', 'categorization', 'التصنيف'),
    _exercise(6, 'event-ordering', 'event_ordering', 'ترتيب الأحداث'),
    _exercise(
      7,
      'picture-recognition',
      'picture_recognition',
      'التعرّف على الصور',
    ),
    _exercise(8, 'sequence', 'sequence', 'أكمل التسلسل'),
  ];

  test('every database exercise resolves to a distinct playable type', () {
    final resolvedTypes = exercises
        .map((exercise) => resolveExercisePlayScreen(exercise).runtimeType)
        .toSet();

    expect(exercises, hasLength(8));
    expect(resolvedTypes, hasLength(exercises.length));

    for (final exercise in exercises) {
      expect(
        exercisePlayRoute(exercise).settings.name,
        '/exercises/${exercise.id}/play',
      );
    }
  });

  final launchCases = <(Exercise, Type)>[
    (_exercise(1, 'audio-memory', 'audio_memory', 'الذاكرة السمعية'),
        AudioMemoryScreen),
    (_exercise(4, 'word-recall', 'word_recall', 'تذكّر الكلمات'),
        WordRecallScreen),
    (
      _exercise(
        7,
        'picture-recognition',
        'picture_recognition',
        'التعرّف على الصور',
      ),
      PictureRecognitionScreen,
    ),
  ];

  for (final launchCase in launchCases) {
    testWidgets(
      '${launchCase.$1.code} details start the configured playable screen',
      (tester) async {
        tester.view.physicalSize = const Size(1366, 768);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final exercise = launchCase.$1;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: ExerciseDetailsScreen(exercise: exercise),
          ),
        );
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
      },
    );
  }

  test('all supported engine names map to the expected screen', () {
    final expectedTypes = <Type>[
      AudioMemoryScreen,
      SpotDifferenceScreen,
      CardMatchingScreen,
      WordRecallScreen,
      CategorizationScreen,
      EventOrderingScreen,
      PictureRecognitionScreen,
      SequenceScreen,
    ];

    final actualTypes = exercises
        .map((exercise) => resolveExercisePlayScreen(exercise).runtimeType)
        .toList();

    expect(actualTypes, expectedTypes);
  });

  final backCases = <Widget>[
    const AudioMemoryScreen(),
    const CategorizationScreen(),
    const PictureRecognitionScreen(),
    const SequenceScreen(),
    const SpotDifferenceScreen(),
    const EmotionRecognitionScreen(),
  ];

  for (final screen in backCases) {
    testWidgets(
      '${screen.runtimeType} has a working visible back button',
      (tester) async {
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
      },
    );
  }
}

Exercise _exercise(
  int id,
  String code,
  String engineType,
  String title,
) {
  return Exercise.fromJson({
    'id': id,
    'code': code,
    'title_ar': title,
    'description_ar': 'وصف تجريبي للتمرين',
    'goal_ar': 'هدف تجريبي للتمرين',
    'instructions_ar': 'اقرأ التعليمات ثم ابدأ التمرين.',
    'category_key': 'test',
    'category_ar': 'اختبار',
    'engine_type': engineType,
    'difficulty': 'easy',
    'duration_minutes': 5,
    'sound_enabled': true,
    'icon_key': 'psychology',
    'color_hex': 'FF4A3528',
    'source': 'system',
    'content': <String, dynamic>{},
  });
}