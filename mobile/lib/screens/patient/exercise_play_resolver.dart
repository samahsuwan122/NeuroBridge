import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../core/services/exercise_progress_service.dart';
import 'audio_memory_screen.dart';
import 'adaptive_quiz_screen.dart';
import 'card_matching_screen.dart';
import 'categorization_screen.dart';
import 'event_ordering_screen.dart';
import 'picture_recognition_screen.dart';
import 'sequence_screen.dart';
import 'spot_difference_screen.dart';
import 'word_recall_screen.dart';

Widget resolveExercisePlayScreen(Exercise exercise) {
  return switch (exercise.type) {
    ExerciseType.adaptiveQuiz => AdaptiveQuizScreen(exercise: exercise),
    ExerciseType.audioMemory => const AudioMemoryScreen(),
    ExerciseType.spotDifference => const SpotDifferenceScreen(),
    ExerciseType.cardMatching => const CardMatchingScreen(),
    ExerciseType.wordRecall => const WordRecallScreen(),
    ExerciseType.categorization => const CategorizationScreen(),
    ExerciseType.eventOrdering => const EventOrderingScreen(),
    ExerciseType.pictureRecognition => const PictureRecognitionScreen(),
    ExerciseType.sequence => const SequenceScreen(),
    ExerciseType.unsupported => _UnsupportedExerciseScreen(
        title: exercise.title,
      ),
  };
}

Route<void> exercisePlayRoute(Exercise exercise) {
  ExerciseProgressService.beginExercise(exercise.id);
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: '/exercises/${exercise.id}/play'),
    builder: (_) => resolveExercisePlayScreen(exercise),
  );
}

class _UnsupportedExerciseScreen extends StatelessWidget {
  final String title;

  const _UnsupportedExerciseScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'محرك هذا التمرين غير مثبت في التطبيق بعد.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
