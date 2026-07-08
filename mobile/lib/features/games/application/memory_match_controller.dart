import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/memory_card.dart';

/// Pure-Dart controller for the Memory Match cognitive exercise.
///
/// Fixed board: 6 pairs = 12 cards (4x3). Tracks game-performance metrics only
/// (moves, mistakes, matched pairs, elapsed time) — no medical interpretation.
///
/// Deterministic when a [seed] is provided. Set [autoResolve] to false in tests
/// to flip mismatched cards back manually via [resolveMismatch].
class MemoryMatchController extends ChangeNotifier {
  MemoryMatchController({
    int? seed,
    this.autoResolve = true,
    this.mismatchDelay = const Duration(milliseconds: 800),
  })  : _random = seed != null ? Random(seed) : Random() {
    _init();
  }

  static const List<String> _symbols = ['🍎', '🌟', '🐶', '🌸', '⚽', '🎵'];

  final Random _random;
  final bool autoResolve;
  final Duration mismatchDelay;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  late List<MemoryCard> _cards;
  int _firstIndex = -1;
  List<int>? _pending; // two mismatched indices awaiting flip-back

  int moves = 0;
  int mistakes = 0;
  int matchedPairs = 0;
  bool completed = false;

  int get totalPairs => _symbols.length;
  List<MemoryCard> get cards => List.unmodifiable(_cards);
  bool get isBusy => _pending != null;
  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;

  void _init() {
    _timer?.cancel();
    _timer = null;
    _stopwatch
      ..stop()
      ..reset();
    _firstIndex = -1;
    _pending = null;
    moves = 0;
    mistakes = 0;
    matchedPairs = 0;
    completed = false;

    final cards = <MemoryCard>[];
    var id = 0;
    for (final symbol in _symbols) {
      cards.add(MemoryCard(id: id++, value: symbol));
      cards.add(MemoryCard(id: id++, value: symbol));
    }
    cards.shuffle(_random);
    _cards = cards;
  }

  void flip(int index) {
    if (completed || _pending != null) return;
    final card = _cards[index];
    if (card.isMatched || card.isFaceUp) return;

    if (!_stopwatch.isRunning) _stopwatch.start();
    card.isFaceUp = true;

    if (_firstIndex == -1) {
      _firstIndex = index;
      notifyListeners();
      return;
    }

    // Second card of the attempt.
    moves++;
    final first = _cards[_firstIndex];
    if (first.value == card.value) {
      first.isMatched = true;
      card.isMatched = true;
      matchedPairs++;
      _firstIndex = -1;
      if (matchedPairs == totalPairs) {
        completed = true;
        _stopwatch.stop();
      }
      notifyListeners();
    } else {
      mistakes++;
      _pending = [_firstIndex, index];
      _firstIndex = -1;
      notifyListeners();
      if (autoResolve) {
        _timer = Timer(mismatchDelay, resolveMismatch);
      }
    }
  }

  /// Flip the two mismatched cards back face-down.
  void resolveMismatch() {
    final pending = _pending;
    if (pending == null) return;
    for (final i in pending) {
      final card = _cards[i];
      if (!card.isMatched) card.isFaceUp = false;
    }
    _pending = null;
    _timer = null;
    notifyListeners();
  }

  void restart() {
    _init();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
