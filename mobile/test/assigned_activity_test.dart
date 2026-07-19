import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/features/activities/data/assigned_activity.dart';

void main() {
  test('fromJson parses fields and safe generated content', () {
    final a = AssignedActivity.fromJson(const {
      'id': 'a1',
      'template_type': 'memory_recall',
      'title': 'Memory Recall',
      'instructions': 'Remember the words.',
      'difficulty': 'medium',
      'duration_minutes': 8,
      'status': 'assigned',
      'generated_content': {'kind': 'memory_recall', 'items': ['apple']},
      'created_at': '2026-07-17T10:00:00Z',
      'completed_at': null,
    });

    expect(a.id, 'a1');
    expect(a.title, 'Memory Recall');
    expect(a.difficulty, 'medium');
    expect(a.durationMinutes, 8);
    expect(a.isPending, isTrue);
    expect(a.isCompleted, isFalse);
    expect(a.generatedContent?['kind'], 'memory_recall');
  });

  test('template types map to the matching in-app game route', () {
    String? routeFor(String t) => AssignedActivity.fromJson({
          'id': 'x',
          'template_type': t,
          'title': 't',
          'difficulty': 'easy',
          'duration_minutes': 5,
          'status': 'assigned',
        }).gameRoute;

    expect(routeFor('memory_recall'), '/games/play/memory-recall');
    expect(routeFor('attention_focus'), '/games/play/attention-focus');
    expect(routeFor('reaction_time'), '/games/play/reaction-time');
    expect(routeFor('sequence_recall'), '/games/play/sequence-order');
    expect(routeFor('matching_game'), '/games/play/memory-match');
    // Preview-only template has no game route.
    expect(routeFor('daily_orientation'), isNull);
  });

  test('daily orientation is preview-only (not playable)', () {
    final a = AssignedActivity.fromJson(const {
      'id': 'a2',
      'template_type': 'daily_orientation',
      'title': 'Daily Orientation',
      'difficulty': 'easy',
      'duration_minutes': 5,
      'status': 'assigned',
    });
    expect(a.isPlayable, isFalse);
  });

  test('copyWith updates status and completed timestamp', () {
    final a = AssignedActivity.fromJson(const {
      'id': 'a3',
      'template_type': 'matching_game',
      'title': 'Matching Game',
      'difficulty': 'hard',
      'duration_minutes': 12,
      'status': 'assigned',
    });
    final done = a.copyWith(status: 'completed', completedAt: DateTime(2026, 7, 17));
    expect(done.isCompleted, isTrue);
    expect(done.completedAt, isNotNull);
    expect(done.id, 'a3');
  });
}
