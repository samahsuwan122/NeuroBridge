/// A safe, display-only view of a saved game result.
///
/// Contains exercise/game-performance fields only — no diagnosis or medical
/// interpretation.
class GameResultSummary {
  const GameResultSummary({
    required this.gameId,
    required this.gameTitle,
    required this.completed,
    this.score,
    this.maxScore,
    this.durationSeconds,
    this.createdAt,
    this.moves,
    this.mistakes,
  });

  final String gameId;
  final String gameTitle;
  final bool completed;
  final int? score;
  final int? maxScore;
  final int? durationSeconds;
  final DateTime? createdAt;
  final int? moves;
  final int? mistakes;

  factory GameResultSummary.fromResultJson(
    Map<String, dynamic> json, {
    required String gameTitle,
  }) {
    final metrics =
        (json['metrics'] as Map?)?.cast<String, dynamic>() ?? const {};
    return GameResultSummary(
      gameId: (json['game_definition_id'] ?? '').toString(),
      gameTitle: gameTitle,
      completed: (json['completed'] as bool?) ?? false,
      score: (json['score'] as num?)?.toInt(),
      maxScore: (json['max_score'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      moves: (metrics['moves'] as num?)?.toInt(),
      mistakes: (metrics['mistakes'] as num?)?.toInt(),
    );
  }

  /// Short local date (YYYY-MM-DD), or empty if unknown.
  String get shortDate {
    final date = createdAt;
    if (date == null) return '';
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}
