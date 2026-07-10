import 'dart:math';

import '../../../memories/data/memory_entry.dart';

/// The kind of supportive recall question. Prompts are localized in the UI.
enum RecallQuestionType { person, place, category }

/// A single multiple-choice question built ONLY from data the family already
/// entered in the Memory Album. Nothing is inferred or analyzed. This is a
/// supportive family-recall activity — not a diagnosis or a medical test.
class MemoryRecallQuestion {
  const MemoryRecallQuestion({
    required this.memory,
    required this.type,
    required this.correctAnswer,
    required this.options,
  });

  final MemoryEntry memory;
  final RecallQuestionType type;
  final String correctAnswer;

  /// Answer options (includes [correctAnswer]); already shuffled.
  final List<String> options;

  bool isCorrect(String option) => option == correctAnswer;
}

List<String> _distinct(Iterable<String?> values) {
  final seen = <String>{};
  for (final v in values) {
    final t = v?.trim();
    if (t != null && t.isNotEmpty) seen.add(t);
  }
  return seen.toList();
}

MemoryRecallQuestion? _build(
  MemoryEntry memory,
  RecallQuestionType type,
  String? answer,
  List<String> pool,
  Random rnd,
) {
  final value = answer?.trim();
  if (value == null || value.isEmpty) return null;
  final distractors = pool.where((v) => v != value).toList()..shuffle(rnd);
  if (distractors.isEmpty) return null; // no options → skip (not enough data)
  final options = <String>[value, ...distractors.take(3)]..shuffle(rnd);
  return MemoryRecallQuestion(
    memory: memory,
    type: type,
    correctAnswer: value,
    options: options,
  );
}

/// Build safe multiple-choice recall questions from Memory Album entries.
///
/// Uses only entered fields (person, place, category) and other entries as
/// distractors. A field with no available distractor is skipped. Returns at
/// most [maxQuestions] questions (shuffled). No inference, no AI, no image
/// analysis, no medical content.
List<MemoryRecallQuestion> generateMemoryRecallQuestions(
  List<MemoryEntry> memories, {
  Random? random,
  int maxQuestions = 6,
}) {
  final rnd = random ?? Random();
  final persons = _distinct(memories.map((m) => m.personName));
  final places = _distinct(memories.map((m) => m.placeName));
  final categories = _distinct(memories.map((m) => m.category));

  final questions = <MemoryRecallQuestion>[];
  for (final m in memories) {
    final person = _build(m, RecallQuestionType.person, m.personName, persons, rnd);
    if (person != null) questions.add(person);
    final place = _build(m, RecallQuestionType.place, m.placeName, places, rnd);
    if (place != null) questions.add(place);
    final category =
        _build(m, RecallQuestionType.category, m.category, categories, rnd);
    if (category != null) questions.add(category);
  }
  questions.shuffle(rnd);
  return questions.length > maxQuestions
      ? questions.sublist(0, maxQuestions)
      : questions;
}
