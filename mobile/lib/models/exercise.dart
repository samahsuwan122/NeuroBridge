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
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.durationMinutes,
    required this.color,
  });

  final String id;
  final ExerciseType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final int durationMinutes;
  final Color color;
}

abstract final class ExerciseCatalog {
  static const all = <Exercise>[
    Exercise(
        id: 'memory',
        type: ExerciseType.audioMemory,
        title: 'الذاكرة',
        subtitle: 'تمارين الذاكرة السمعية',
        icon: Icons.memory_rounded,
        durationMinutes: 5,
        color: Color(0xFF4A3528)),
    Exercise(
        id: 'visual-attention',
        type: ExerciseType.spotDifference,
        title: 'الانتباه',
        subtitle: 'اكتشاف الفروق',
        icon: Icons.visibility_rounded,
        durationMinutes: 5,
        color: Color(0xFF7895A4)),
    Exercise(
        id: 'focus',
        type: ExerciseType.cardMatching,
        title: 'التركيز',
        subtitle: 'مطابقة البطاقات',
        icon: Icons.center_focus_strong_rounded,
        durationMinutes: 5,
        color: Color(0xFF9D7BB0)),
    Exercise(
        id: 'language',
        type: ExerciseType.wordRecall,
        title: 'اللغة',
        subtitle: 'تذكر الكلمات',
        icon: Icons.translate_rounded,
        durationMinutes: 5,
        color: Color(0xFFC79A62)),
    Exercise(
        id: 'problem-solving',
        type: ExerciseType.categorization,
        title: 'حل المشكلات',
        subtitle: 'تصنيف العناصر',
        icon: Icons.lightbulb_outline_rounded,
        durationMinutes: 5,
        color: Color(0xFF7D9B82)),
    Exercise(
        id: 'planning',
        type: ExerciseType.eventOrdering,
        title: 'الترتيب والتخطيط',
        subtitle: 'ترتيب الأحداث',
        icon: Icons.account_tree_outlined,
        durationMinutes: 5,
        color: Color(0xFFC37B74)),
    Exercise(
        id: 'visual-perception',
        type: ExerciseType.pictureRecognition,
        title: 'الإدراك البصري',
        subtitle: 'التعرف على الصور',
        icon: Icons.image_search_rounded,
        durationMinutes: 5,
        color: Color(0xFF7C8FB5)),
    Exercise(
        id: 'response-speed',
        type: ExerciseType.sequence,
        title: 'سرعة الاستجابة',
        subtitle: 'إكمال التسلسل',
        icon: Icons.bolt_rounded,
        durationMinutes: 5,
        color: Color(0xFFD39A5D)),
  ];
}
