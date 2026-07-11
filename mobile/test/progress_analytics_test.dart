import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/features/progress/data/game_result_summary.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_analytics.dart';

GameResultSummary _r({
  required String title,
  int? score,
  int? max,
  bool completed = true,
  DateTime? at,
}) =>
    GameResultSummary(
      gameId: 'g',
      gameTitle: title,
      completed: completed,
      score: score,
      maxScore: max,
      createdAt: at,
    );

void main() {
  test('empty results give zeroed analytics', () {
    final a = ProgressAnalytics.from([]);
    expect(a.totalExercises, 0);
    expect(a.completedExercises, 0);
    expect(a.bestPercent, isNull);
    expect(a.averagePercent, isNull);
    expect(a.latestTitle, isNull);
    expect(a.breakdown, isEmpty);
  });

  test('computes best and average performance percentages', () {
    final a = ProgressAnalytics.from([
      _r(title: 'Memory Match', score: 6, max: 6), // 100
      _r(title: 'Memory Match', score: 3, max: 6), // 50
      _r(title: 'Reaction Time', score: 2, max: 5), // 40
    ]);
    expect(a.totalExercises, 3);
    expect(a.bestPercent, 100);
    expect(a.averagePercent, 63); // (100+50+40)/3 = 63.3 -> 63
  });

  test('groups results by game with counts and best %', () {
    final a = ProgressAnalytics.from([
      _r(title: 'Memory Match', score: 6, max: 6),
      _r(title: 'Memory Match', score: 3, max: 6),
      _r(title: 'Reaction Time', score: 2, max: 5),
    ]);
    final mm = a.breakdown.firstWhere((b) => b.title == 'Memory Match');
    expect(mm.count, 2);
    expect(mm.bestPercent, 100);
    expect(a.breakdown.first.title, 'Memory Match'); // sorted by count desc
  });

  test('latest activity uses the most recent created date', () {
    final a = ProgressAnalytics.from([
      _r(title: 'Old', score: 1, max: 2, at: DateTime(2026, 1, 1)),
      _r(title: 'New', score: 1, max: 2, at: DateTime(2026, 7, 1)),
    ]);
    expect(a.latestTitle, 'New');
  });

  test('results without score/max do not break percentages', () {
    final a = ProgressAnalytics.from([
      _r(title: 'Sequence Recall'), // no score/max
      _r(title: 'Memory Match', score: 4, max: 8), // 50
    ]);
    expect(a.totalExercises, 2);
    expect(a.bestPercent, 50);
    expect(a.averagePercent, 50);
  });

  test('completed count counts only completed results', () {
    final a = ProgressAnalytics.from([
      _r(title: 'A', score: 1, max: 2, completed: true),
      _r(title: 'B', score: 1, max: 2, completed: false),
    ]);
    expect(a.completedExercises, 1);
    expect(a.totalExercises, 2);
  });
}
