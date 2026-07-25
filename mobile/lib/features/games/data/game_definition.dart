/// A cognitive-exercise game definition (from GET /api/v1/games).
///
/// Exercise metadata only — no diagnostic or medical fields.
class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.name,
    required this.slug,
    required this.gameType,
    required this.difficulty,
    this.description,
    this.instructions,
    this.estimatedDurationMinutes,
    this.active = true,
  });

  final String id;
  final String name;
  final String slug;
  final String gameType;
  final String difficulty;
  final String? description;
  final String? instructions;
  final int? estimatedDurationMinutes;
  final bool active;

  factory GameDefinition.fromJson(Map<String, dynamic> json) {
    return GameDefinition(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      gameType: (json['game_type'] as String?) ?? '',
      difficulty: (json['difficulty'] as String?) ?? '',
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt(),
      active: (json['active'] as bool?) ?? true,
    );
  }
}
