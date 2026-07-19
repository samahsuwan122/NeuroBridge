/// An activity the care team assigned to the patient
/// (from GET /api/v1/activities/my).
///
/// Cognitive-exercise content only — no diagnosis, treatment, prediction, or
/// scoring. `generatedContent` holds safe template parameters.
class AssignedActivity {
  const AssignedActivity({
    required this.id,
    required this.templateType,
    required this.title,
    required this.difficulty,
    required this.durationMinutes,
    required this.status,
    this.instructions,
    this.generatedContent,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String templateType;
  final String title;
  final String? instructions;
  final String difficulty;
  final int durationMinutes;
  final String status; // assigned / completed / skipped
  final Map<String, dynamic>? generatedContent;
  final DateTime? createdAt;
  final DateTime? completedAt;

  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isPending => status == 'assigned';

  /// The in-app game route for this template, or null if it is preview-only.
  String? get gameRoute {
    switch (templateType) {
      case 'memory_recall':
        return '/games/play/memory-recall';
      case 'attention_focus':
        return '/games/play/attention-focus';
      case 'reaction_time':
        return '/games/play/reaction-time';
      case 'sequence_recall':
        return '/games/play/sequence-order';
      case 'matching_game':
        return '/games/play/memory-match';
      default:
        return null; // daily_orientation and anything else: guided preview
    }
  }

  bool get isPlayable => gameRoute != null;

  factory AssignedActivity.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? s) =>
        s is String ? DateTime.tryParse(s) : null;
    return AssignedActivity(
      id: (json['id'] ?? '').toString(),
      templateType: (json['template_type'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      instructions: json['instructions'] as String?,
      difficulty: (json['difficulty'] as String?) ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'assigned',
      generatedContent:
          (json['generated_content'] as Map?)?.cast<String, dynamic>(),
      createdAt: parse(json['created_at']),
      completedAt: parse(json['completed_at']),
    );
  }

  AssignedActivity copyWith({String? status, DateTime? completedAt}) {
    return AssignedActivity(
      id: id,
      templateType: templateType,
      title: title,
      instructions: instructions,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      generatedContent: generatedContent,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
