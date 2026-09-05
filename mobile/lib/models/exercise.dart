import 'package:flutter/material.dart';

enum ExerciseType {
  audioMemory,
  spotDifference,
  cardMatching,
  wordRecall,
  categorization,
  eventOrdering,
  pictureRecognition,
  sequence,
  adaptiveQuiz,
  unsupported,
}

class Exercise {
  final int id;
  final int? assignedActivityId;
  final bool isAssigned;
  final String code;
  final String title;
  final String description;
  final String goal;
  final String instructions;
  final String categoryKey;
  final String categoryTitle;
  final ExerciseType type;
  final String difficulty;
  final int durationMinutes;
  final bool soundEnabled;
  final String iconKey;
  final Color color;
  final String source;
  final Map<String, dynamic> content;

  const Exercise({
    required this.id,
    required this.assignedActivityId,
    required this.isAssigned,
    required this.code,
    required this.title,
    required this.description,
    required this.goal,
    required this.instructions,
    required this.categoryKey,
    required this.categoryTitle,
    required this.type,
    required this.difficulty,
    required this.durationMinutes,
    required this.soundEnabled,
    required this.iconKey,
    required this.color,
    required this.source,
    required this.content,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: _asInt(json['id']),
      assignedActivityId: json['assigned_activity_id'] == null
          ? null
          : _asInt(json['assigned_activity_id']),
      isAssigned: _asBool(json['is_assigned']),
      code: json['code']?.toString() ?? '',
      title: json['title_ar']?.toString() ?? 'تمرين',
      description: json['description_ar']?.toString() ?? '',
      goal: json['goal_ar']?.toString() ?? '',
      instructions: json['instructions_ar']?.toString() ?? '',
      categoryKey: json['category_key']?.toString() ?? 'other',
      categoryTitle: json['category_ar']?.toString() ?? 'أخرى',
      type: _typeFromKey(json['engine_type']?.toString() ?? ''),
      difficulty: json['difficulty']?.toString() ?? 'easy',
      durationMinutes: _asInt(json['duration_minutes'], fallback: 5),
      soundEnabled: _asBool(json['sound_enabled']),
      iconKey: json['icon_key']?.toString() ?? 'psychology',
      color: _colorFromHex(json['color_hex']?.toString()),
      source: json['source']?.toString() ?? 'system',
      content: json['content'] is Map
          ? Map<String, dynamic>.from(json['content'] as Map)
          : const {},
    );
  }

  String get difficultyTitle => switch (difficulty) {
        'hard' => 'صعب',
        'medium' => 'متوسط',
        _ => 'سهل',
      };

  String get sourceTitle => switch (source) {
        'ai' => 'نشاط مخصص من مقدم الرعاية',
        'admin' => 'أضيف بواسطة الإدارة',
        _ => '',
      };

  IconData get icon => switch (iconKey) {
        'hearing' => Icons.hearing_rounded,
        'visibility' => Icons.visibility_rounded,
        'cards' => Icons.grid_view_rounded,
        'translate' => Icons.translate_rounded,
        'lightbulb' => Icons.lightbulb_outline_rounded,
        'account_tree' => Icons.account_tree_outlined,
        'image_search' => Icons.image_search_rounded,
        'bolt' => Icons.bolt_rounded,
        _ => Icons.psychology_alt_rounded,
      };

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _asBool(dynamic value) {
    return value == true || value == 1 || value?.toString() == '1';
  }

  static ExerciseType _typeFromKey(String key) => switch (key) {
        'audio_memory' => ExerciseType.audioMemory,
        'spot_difference' => ExerciseType.spotDifference,
        'card_matching' => ExerciseType.cardMatching,
        'word_recall' => ExerciseType.wordRecall,
        'categorization' => ExerciseType.categorization,
        'event_ordering' => ExerciseType.eventOrdering,
        'picture_recognition' => ExerciseType.pictureRecognition,
        'sequence' => ExerciseType.sequence,
        'adaptive_quiz' => ExerciseType.adaptiveQuiz,
        _ => ExerciseType.unsupported,
      };

  static Color _colorFromHex(String? value) {
    final clean = (value ?? 'FF4A3528').replaceAll('#', '');
    final normalized = clean.length == 6 ? 'FF$clean' : clean;
    return Color(int.tryParse(normalized, radix: 16) ?? 0xFF4A3528);
  }
}
