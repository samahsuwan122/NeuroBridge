import 'dart:math';

import 'package:flutter/foundation.dart';

enum SequenceStatus { idle, watch, input, roundResult, finished }

/// Drives the Sequence Recall exercise: watch a growing sequence of tiles, then
/// repeat it in order. Correct repeats raise the correct count; a wrong tap ends
/// the round as a mistake. Every round advances.
///
/// Deterministic/testable: sequences come from an injectable [Random]; there are
/// no timers in the controller (the screen owns the reveal animation). Results
/// are game performance only — no medical assessment, no normal/abnormal
/// interpretation, no diagnosis.
class SequenceRecallController extends ChangeNotifier {
  SequenceRecallController({
    Random? random,
    DateTime Function()? clock,
    this.totalRounds = 5,
    this.startLength = 3,
    this.tileCount = 4,
  })  : _random = random ?? Random(),
        _clock = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _clock;
  final int totalRounds;
  final int startLength;
  final int tileCount;

  SequenceStatus _status = SequenceStatus.idle;
  List<int> _sequence = const [];
  final List<int> _input = [];
  int _round = 0; // rounds completed
  int _correct = 0;
  int _mistakes = 0;
  int _longest = 0;
  bool? _lastRoundCorrect;
  DateTime? _startedAt;

  SequenceStatus get status => _status;
  List<int> get sequence => List.unmodifiable(_sequence);
  int get inputLength => _input.length;
  int get completedRounds => _round;
  int get correctCount => _correct;
  int get mistakeCount => _mistakes;
  int get longestSequence => _longest;
  bool? get lastRoundCorrect => _lastRoundCorrect;
  bool get isFinished => _status == SequenceStatus.finished;

  int get accuracyPercent =>
      _round == 0 ? 0 : ((_correct / _round) * 100).round();

  int get elapsedSeconds =>
      _startedAt == null ? 0 : _clock().difference(_startedAt!).inSeconds;

  /// Safe performance-only result metadata (no medical score/interpretation).
  Map<String, dynamic> get resultMetrics => {
        'exercise_type': 'sequence_recall',
        'round_count': _round,
        'correct_count': _correct,
        'mistake_count': _mistakes,
        'longest_sequence': _longest,
        'accuracy_percent': accuracyPercent,
      };

  void start() {
    _status = SequenceStatus.watch;
    _round = 0;
    _correct = 0;
    _mistakes = 0;
    _longest = 0;
    _lastRoundCorrect = null;
    _startedAt = _clock();
    _input.clear();
    _generateSequence();
    notifyListeners();
  }

  /// Switch from watching to input (called by the screen after the reveal).
  void beginInput() {
    if (_status != SequenceStatus.watch) return;
    _status = SequenceStatus.input;
    _input.clear();
    notifyListeners();
  }

  void tapTile(int tile) {
    if (_status != SequenceStatus.input) return;
    final pos = _input.length;
    if (pos >= _sequence.length) return;
    _input.add(tile);
    if (tile != _sequence[pos]) {
      // Wrong tap ends the round as a mistake.
      _mistakes++;
      _lastRoundCorrect = false;
      _status = SequenceStatus.roundResult;
    } else if (_input.length == _sequence.length) {
      // Full correct repeat.
      _correct++;
      if (_sequence.length > _longest) _longest = _sequence.length;
      _lastRoundCorrect = true;
      _status = SequenceStatus.roundResult;
    }
    notifyListeners();
  }

  /// Advance to the next round (or finish) after a round result.
  void continueGame() {
    if (_status != SequenceStatus.roundResult) return;
    _round++;
    if (_round >= totalRounds) {
      _status = SequenceStatus.finished;
    } else {
      _lastRoundCorrect = null;
      _input.clear();
      _generateSequence();
      _status = SequenceStatus.watch;
    }
    notifyListeners();
  }

  void restart() {
    _status = SequenceStatus.idle;
    _sequence = const [];
    _input.clear();
    _round = 0;
    _correct = 0;
    _mistakes = 0;
    _longest = 0;
    _lastRoundCorrect = null;
    _startedAt = null;
    notifyListeners();
  }

  void _generateSequence() {
    final length = startLength + _round;
    _sequence =
        List<int>.generate(length, (_) => _random.nextInt(tileCount));
  }
}
