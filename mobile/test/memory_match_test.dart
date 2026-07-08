import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/features/games/application/memory_match_controller.dart';

List<int> _indicesOfValue(MemoryMatchController c, String value) => [
      for (var i = 0; i < c.cards.length; i++)
        if (c.cards[i].value == value) i,
    ];

void main() {
  test('starts with 12 cards and zeroed metrics', () {
    final c = MemoryMatchController(seed: 1, autoResolve: false);
    expect(c.cards.length, 12);
    expect(c.totalPairs, 6);
    expect(c.moves, 0);
    expect(c.matchedPairs, 0);
    expect(c.mistakes, 0);
    expect(c.completed, isFalse);
  });

  test('matching pair increases matchedPairs', () {
    final c = MemoryMatchController(seed: 1, autoResolve: false);
    final pair = _indicesOfValue(c, c.cards.first.value);
    c.flip(pair[0]);
    c.flip(pair[1]);
    expect(c.matchedPairs, 1);
    expect(c.cards[pair[0]].isMatched, isTrue);
    expect(c.cards[pair[1]].isMatched, isTrue);
    expect(c.mistakes, 0);
  });

  test('wrong pair increases mistakes and can be flipped back', () {
    final c = MemoryMatchController(seed: 1, autoResolve: false);
    final firstValue = c.cards.first.value;
    final a = _indicesOfValue(c, firstValue).first;
    final b = c.cards.indexWhere((card) => card.value != firstValue);
    c.flip(a);
    c.flip(b);
    expect(c.mistakes, 1);
    expect(c.matchedPairs, 0);
    expect(c.isBusy, isTrue);
    c.resolveMismatch();
    expect(c.cards[a].isFaceUp, isFalse);
    expect(c.cards[b].isFaceUp, isFalse);
    expect(c.isBusy, isFalse);
  });

  test('completing all pairs sets completed = true', () {
    final c = MemoryMatchController(seed: 1, autoResolve: false);
    for (final value in c.cards.map((card) => card.value).toSet()) {
      final pair = _indicesOfValue(c, value);
      c.flip(pair[0]);
      c.flip(pair[1]);
    }
    expect(c.matchedPairs, c.totalPairs);
    expect(c.completed, isTrue);
    expect(c.mistakes, 0);
    expect(c.moves, 6);
  });

  test('restart resets the game', () {
    final c = MemoryMatchController(seed: 1, autoResolve: false);
    final pair = _indicesOfValue(c, c.cards.first.value);
    c.flip(pair[0]);
    c.flip(pair[1]);
    c.restart();
    expect(c.matchedPairs, 0);
    expect(c.moves, 0);
    expect(c.completed, isFalse);
    expect(c.cards.every((card) => !card.isFaceUp && !card.isMatched), isTrue);
  });
}
