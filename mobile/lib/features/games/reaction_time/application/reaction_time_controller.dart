import 'dart:math';

import 'package:flutter/foundation.dart';

enum ReactionStatus { idle, waiting, ready, tooSoon, roundResult, finished }

/// Drives the Reaction Time exercise: wait for the signal, then tap fast.
///
/// Timing is testable: the controller is a pure state machine over an injectable
/// [clock]; the screen owns the real `Timer` that calls [signalGo] after the
/// delay returned by [beginRound]. Results are game performance only — no
/// medical assessment, no normal/abnormal interpretation, no diagnosis.
class ReactionTimeController extends ChangeNotifier {
  ReactionTimeController({
    DateTime Function()? clock,
    Random? random,
    this.totalRounds = 5,
    this.minWaitMs = 1200,
    this.maxWaitMs = 3500,
  })  : _clock = clock ?? DateTime.now,
        _random = random ?? Random();

  final DateTime Function() _clock;
  final Random _random;
  final int totalRounds;
  final int minWaitMs;
  final int maxWaitMs;

  ReactionStatus _status = ReactionStatus.idle;
  final List<int> _reactions = [];
  int? _lastReactionMs;
  DateTime? _goAt;
  DateTime? _startedAt;

  ReactionStatus get status => _status;
  int get completedRounds => _reactions.length;
  int? get lastReactionMs => _lastReactionMs;
  List<int> get reactionTimesMs => List.unmodifiable(_reactions);
  bool get isFinished => _status == ReactionStatus.finished;

  int? get bestReactionMs =>
      _reactions.isEmpty ? null : _reactions.reduce(min);

  int? get averageReactionMs => _reactions.isEmpty
      ? null
      : (_reactions.reduce((a, b) => a + b) / _reactions.length).round();

  int get elapsedSeconds => _startedAt == null
      ? 0
      : _clock().difference(_startedAt!).inSeconds;

  /// Safe performance-only result metadata (no medical score/interpretation).
  Map<String, dynamic> get resultMetrics => {
        'exercise_type': 'reaction_time',
        'round_count': _reactions.length,
        'best_reaction_ms': bestReactionMs,
        'average_reaction_ms': averageReactionMs,
        'reaction_times_ms': List<int>.from(_reactions),
      };

  /// Begin a round: enter the waiting state and return the random delay before
  /// the signal. The caller (screen) schedules [signalGo] after this delay.
  Duration beginRound() {
    _startedAt ??= _clock();
    _status = ReactionStatus.waiting;
    _lastReactionMs = null;
    _goAt = null;
    notifyListeners();
    final span = (maxWaitMs - minWaitMs).clamp(1, 1 << 30);
    return Duration(milliseconds: minWaitMs + _random.nextInt(span));
  }

  /// The signal fires ("Tap now!"). Ignored unless currently waiting.
  void signalGo() {
    if (_status != ReactionStatus.waiting) return;
    _status = ReactionStatus.ready;
    _goAt = _clock();
    notifyListeners();
  }

  /// The user tapped the play area.
  void tap() {
    switch (_status) {
      case ReactionStatus.waiting:
        // Tapped before the signal — not counted; the round can be retried.
        _status = ReactionStatus.tooSoon;
        notifyListeners();
      case ReactionStatus.ready:
        final ms = _clock().difference(_goAt!).inMilliseconds;
        _lastReactionMs = ms < 0 ? 0 : ms;
        _reactions.add(_lastReactionMs!);
        _status = _reactions.length >= totalRounds
            ? ReactionStatus.finished
            : ReactionStatus.roundResult;
        notifyListeners();
      case ReactionStatus.idle:
      case ReactionStatus.tooSoon:
      case ReactionStatus.roundResult:
      case ReactionStatus.finished:
        break; // taps ignored in these states
    }
  }

  /// Reset back to the initial instructions.
  void restart() {
    _status = ReactionStatus.idle;
    _reactions.clear();
    _lastReactionMs = null;
    _goAt = null;
    _startedAt = null;
    notifyListeners();
  }
}
