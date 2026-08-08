import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import 'audio_memory_screen.dart';
import 'card_matching_screen.dart';
import 'categorization_screen.dart';
import 'event_ordering_screen.dart';
import 'picture_recognition_screen.dart';
import 'sequence_screen.dart';
import 'spot_difference_screen.dart';
import 'word_recall_screen.dart';

Widget resolveExercisePlayScreen(ExerciseType type) {
  return switch (type) {
    ExerciseType.audioMemory => const AudioMemoryScreen(),
    ExerciseType.spotDifference => const SpotDifferenceScreen(),
    ExerciseType.cardMatching => const CardMatchingScreen(),
    ExerciseType.wordRecall => const WordRecallScreen(),
    ExerciseType.categorization => const CategorizationScreen(),
    ExerciseType.eventOrdering => const EventOrderingScreen(),
    ExerciseType.pictureRecognition => const PictureRecognitionScreen(),
    ExerciseType.sequence => const SequenceScreen(),
  };
}

Route<void> exercisePlayRoute(Exercise exercise) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: '/exercises/${exercise.id}/play'),
    builder: (_) => resolveExercisePlayScreen(exercise.type),
  );
}
