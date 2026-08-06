import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class CardMatchingScreen extends StatefulWidget {
  const CardMatchingScreen({super.key});

  @override
  State<CardMatchingScreen> createState() =>
      _CardMatchingScreenState();
}

class _CardMatchingScreenState
    extends State<CardMatchingScreen> {
  static const rose = Color(0xFFB87585);
  static const brown = Color(0xFF4F3C38);

  final List<String> cards = [
    '🍎',
    '🌷',
    '⭐',
    '🐱',
    '🍎',
    '⭐',
    '🐱',
    '🌷',
  ];

  final Set<int> matched = {};
  final List<int> opened = [];

  int attempts = 0;

  void _tapCard(int index) {
    if (matched.contains(index) ||
        opened.contains(index) ||
        opened.length == 2) {
      return;
    }

    setState(() {
      opened.add(index);
    });

    if (opened.length == 2) {
      attempts++;

      final first = opened[0];
      final second = opened[1];

      if (cards[first] == cards[second]) {
        Future.delayed(
          const Duration(milliseconds: 450),
          () {
            if (!mounted) return;

            setState(() {
              matched.add(first);
              matched.add(second);
              opened.clear();
            });

            if (matched.length == cards.length) {
              _finish();
            }
          },
        );
      } else {
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) return;

            setState(() {
              opened.clear();
            });
          },
        );
      }
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: 4,
          totalQuestions: 4,
          duration: '2:15',
          extraText: '$attempts محاولة',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    icon:
                        const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'مطابقة البطاقات',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                  Text(
                    'المحاولات: $attempts',
                    style: const TextStyle(
                      color: rose,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                'ابحث عن الأزواج المتطابقة. لا يوجد مؤقت.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF89736F),
                ),
              ),

              const SizedBox(height: 28),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (_, index) {
                  final visible =
                      opened.contains(index) ||
                          matched.contains(index);

                  return GestureDetector(
                    onTap: () => _tapCard(index),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: visible
                            ? Colors.white
                            : const Color(0xFFB87585),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE1C4CB),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        visible ? cards[index] : '?',
                        style: TextStyle(
                          fontSize: visible ? 32 : 25,
                          color: visible
                              ? brown
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}