import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../memories/data/memories_api.dart';
import '../data/memory_recall_question.dart';

enum RecallStatus { loading, ready, insufficient, error }

/// Minimum number of generated questions needed to run the exercise.
const int kMinRecallQuestions = 3;

/// Drives the personalized Memory Recall exercise: loads the patient's Memory
/// Album, builds safe multiple-choice questions, tracks the answer flow, and
/// exposes performance-only result metrics.
///
/// Never throws to the UI and never logs tokens. A missing token, backend
/// error, or too few usable memories maps to a safe state. This is a supportive
/// family-recall activity — no diagnosis, scoring interpretation, or AI.
class MemoryRecallController extends ChangeNotifier {
  MemoryRecallController(this._memoriesApi, this._storage, {Random? random})
      : _random = random ?? Random();

  final MemoriesApi _memoriesApi;
  final SecureStorageService _storage;
  final Random _random;

  RecallStatus _status = RecallStatus.loading;
  List<MemoryRecallQuestion> _questions = const [];
  int _index = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answeredCorrectly = false;
  bool _finished = false;
  DateTime? _startedAt;

  RecallStatus get status => _status;
  List<MemoryRecallQuestion> get questions => _questions;
  int get currentIndex => _index;
  int get total => _questions.length;
  int get score => _score;
  int? get selectedOption => _selectedOption;
  bool get answeredCorrectly => _answeredCorrectly;
  bool get isFinished => _finished;
  bool get isLastQuestion => _questions.isNotEmpty && _index == _questions.length - 1;

  MemoryRecallQuestion? get currentQuestion =>
      (_index >= 0 && _index < _questions.length) ? _questions[_index] : null;

  int get elapsedSeconds =>
      _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inSeconds;

  /// Distinct Memory Album entry ids used across the generated questions.
  List<String> get memoryEntryIds {
    final ids = <String>{};
    for (final q in _questions) {
      if (q.memory.id.isNotEmpty) ids.add(q.memory.id);
    }
    return ids.toList();
  }

  /// Performance-only result metadata (no diagnosis/scoring interpretation).
  Map<String, dynamic> get resultMetrics => {
        'exercise_type': 'memory_recall',
        'question_count': total,
        'correct_count': _score,
        'memory_entry_ids': memoryEntryIds,
      };

  Future<void> load() async {
    _reset();
    _status = RecallStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = RecallStatus.error;
        notifyListeners();
        return;
      }
      final memories = await _memoriesApi.listMemories(token);
      _questions = generateMemoryRecallQuestions(memories, random: _random);
      if (_questions.length < kMinRecallQuestions) {
        _status = RecallStatus.insufficient;
      } else {
        _status = RecallStatus.ready;
        _startedAt = DateTime.now();
      }
    } catch (_) {
      _status = RecallStatus.error;
    }
    notifyListeners();
  }

  /// Answer the current question. Wrong answers can be retried (supportive);
  /// the score counts a question once, when the correct option is chosen.
  void answer(int optionIndex) {
    final question = currentQuestion;
    if (question == null || _answeredCorrectly) return;
    if (optionIndex < 0 || optionIndex >= question.options.length) return;
    _selectedOption = optionIndex;
    if (question.isCorrect(question.options[optionIndex])) {
      _answeredCorrectly = true;
      _score++;
    }
    notifyListeners();
  }

  /// Advance to the next question, or finish after the last one.
  void next() {
    if (_index < _questions.length - 1) {
      _index++;
      _selectedOption = null;
      _answeredCorrectly = false;
    } else {
      _finished = true;
    }
    notifyListeners();
  }

  void _reset() {
    _questions = const [];
    _index = 0;
    _score = 0;
    _selectedOption = null;
    _answeredCorrectly = false;
    _finished = false;
    _startedAt = null;
  }
}
