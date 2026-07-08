/// A single card in the Memory Match exercise.
class MemoryCard {
  MemoryCard({
    required this.id,
    required this.value,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  final int id;

  /// The visible face (an emoji/symbol). Two cards match when values are equal.
  final String value;

  bool isFaceUp;
  bool isMatched;
}
