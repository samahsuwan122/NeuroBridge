import 'dart:math';

import 'package:flutter/material.dart';

enum AttentionStatus { idle, playing, finished }

/// Drives the Attention Tap exercise: each round shows a grid of icons; tap the
/// one that matches the target. Correct taps raise the correct count, other taps
/// raise the mistake count, and every tap advances the round.
///
/// Deterministic/testable: grid + target come from an injectable [Random]; there
/// are no timers. Results are game performance only — no medical assessment, no
/// normal/abnormal interpretation, no diagnosis.
class AttentionTapController extends ChangeNotifier {
  AttentionTapController({
    Random? random,
    DateTime Function()? clock,
    this.totalRounds = 10,
    this.gridSize = 6,
  })  : _random = random ?? Random(),
        _clock = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _clock;
  final int totalRounds;
  final int gridSize;

  /// Distinct, high-contrast icons used as targets/distractors.
  static const List<IconData> iconPool = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.circle,
    Icons.square_rounded,
    Icons.hexagon_rounded,
    Icons.pentagon_rounded,
  ];

  AttentionStatus _status = AttentionStatus.idle;
  int _round = 0; // rounds completed (taps made)
  int _correct = 0;
  int _mistakes = 0;
  IconData? _target;
  List<IconData> _cells = const [];
  bool? _lastTapCorrect;
  DateTime? _startedAt;

  AttentionStatus get status => _status;
  int get completedRounds => _round;
  int get correctCount => _correct;
  int get mistakeCount => _mistakes;
  IconData? get target => _target;
  List<IconData> get cells => List.unmodifiable(_cells);
  bool? get lastTapCorrect => _lastTapCorrect;
  bool get isFinished => _status == AttentionStatus.finished;

  int get accuracyPercent =>
      _round == 0 ? 0 : ((_correct / _round) * 100).round();

  int get elapsedSeconds =>
      _startedAt == null ? 0 : _clock().difference(_startedAt!).inSeconds;

  /// Safe performance-only result metadata (no medical score/interpretation).
  Map<String, dynamic> get resultMetrics => {
        'exercise_type': 'attention_tap',
        'round_count': _round,
        'correct_count': _correct,
        'mistake_count': _mistakes,
        'accuracy_percent': accuracyPercent,
      };

  void start() {
    _status = AttentionStatus.playing;
    _round = 0;
    _correct = 0;
    _mistakes = 0;
    _lastTapCorrect = null;
    _startedAt = _clock();
    _generateRound();
    notifyListeners();
  }

  void tapCell(int index) {
    if (_status != AttentionStatus.playing) return;
    if (index < 0 || index >= _cells.length) return;
    final correct = _cells[index] == _target;
    if (correct) {
      _correct++;
    } else {
      _mistakes++;
    }
    _lastTapCorrect = correct;
    _round++;
    if (_round >= totalRounds) {
      _status = AttentionStatus.finished;
    } else {
      _generateRound();
    }
    notifyListeners();
  }

  void restart() {
    _status = AttentionStatus.idle;
    _round = 0;
    _correct = 0;
    _mistakes = 0;
    _target = null;
    _cells = const [];
    _lastTapCorrect = null;
    _startedAt = null;
    notifyListeners();
  }

  void _generateRound() {
    final target = iconPool[_random.nextInt(iconPool.length)];
    final distractors = iconPool.where((i) => i != target).toList();
    final cells = <IconData>[target]; // guarantee at least one target
    while (cells.length < gridSize) {
      cells.add(distractors[_random.nextInt(distractors.length)]);
    }
    cells.shuffle(_random);
    _target = target;
    _cells = cells;
  }
}
