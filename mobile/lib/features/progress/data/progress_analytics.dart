import 'game_result_summary.dart';

/// Per-game performance summary (count + best score %). Display only.
class GameBreakdown {
  const GameBreakdown({
    required this.title,
    required this.count,
    this.bestPercent,
  });

  final String title;
  final int count;
  final int? bestPercent;
}

/// Safe, performance-only analytics derived from saved game results.
///
/// These are exercise-performance summaries only — never a diagnosis, medical
/// interpretation, or any normal/abnormal judgement.
class ProgressAnalytics {
  const ProgressAnalytics({
    required this.totalExercises,
    required this.completedExercises,
    required this.bestPercent,
    required this.averagePercent,
    required this.latestTitle,
    required this.latestDate,
    required this.breakdown,
  });

  final int totalExercises;
  final int completedExercises;
  final int? bestPercent; // 0..100, null when no result has a score/max
  final int? averagePercent;
  final String? latestTitle;
  final String? latestDate;
  final List<GameBreakdown> breakdown;

  /// Score percentage for a result, or null if it has no score/max.
  static int? _percent(GameResultSummary r) {
    final score = r.score;
    final max = r.maxScore;
    if (score == null || max == null || max <= 0) return null;
    return ((score / max) * 100).round();
  }

  factory ProgressAnalytics.from(List<GameResultSummary> results) {
    final total = results.length;
    final completed = results.where((r) => r.completed).length;

    final percents = results.map(_percent).whereType<int>().toList();
    final best = percents.isEmpty
        ? null
        : percents.reduce((a, b) => a > b ? a : b);
    final average = percents.isEmpty
        ? null
        : (percents.reduce((a, b) => a + b) / percents.length).round();

    // Latest by created date, falling back to the first result.
    GameResultSummary? latest;
    for (final r in results) {
      if (r.createdAt == null) continue;
      if (latest?.createdAt == null || r.createdAt!.isAfter(latest!.createdAt!)) {
        latest = r;
      }
    }
    if (latest == null && results.isNotEmpty) latest = results.first;

    // Group by game title.
    final byTitle = <String, List<GameResultSummary>>{};
    for (final r in results) {
      byTitle.putIfAbsent(r.gameTitle, () => []).add(r);
    }
    final breakdown = byTitle.entries.map((e) {
      final ps = e.value.map(_percent).whereType<int>().toList();
      final b = ps.isEmpty ? null : ps.reduce((a, b) => a > b ? a : b);
      return GameBreakdown(title: e.key, count: e.value.length, bestPercent: b);
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return ProgressAnalytics(
      totalExercises: total,
      completedExercises: completed,
      bestPercent: best,
      averagePercent: average,
      latestTitle: latest?.gameTitle,
      latestDate: latest?.shortDate,
      breakdown: breakdown,
    );
  }
}
