import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class WordRecallScreen extends StatefulWidget {
  const WordRecallScreen({super.key});

  @override
  State<WordRecallScreen> createState() => _WordRecallScreenState();
}

class _WordRecallScreenState extends State<WordRecallScreen> {
  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;

  final List<String> words = [
    'تفاحة',
    'قمر',
    'كتاب',
    'شجرة',
    'ساعة',
  ];

  final List<String> choices = [
    'قمر',
    'سيارة',
    'شجرة',
    'كتاب',
    'بحر',
    'تفاحة',
    'كرسي',
    'ساعة',
  ];

  final Set<String> selected = {};

  bool showWords = true;
  int seconds = 6;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (seconds <= 1) {
          timer.cancel();

          setState(() {
            seconds = 0;
            showWords = false;
          });
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  void _finish() {
    final correct = selected.where(words.contains).length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: correct,
          totalQuestions: words.length,
          duration: '1:42',
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'تذكّر الكلمات',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (showWords) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E7D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'تذكّر الكلمات • $seconds',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: rose,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'حاول تذكّر هذه الكلمات بهدوء',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: words.map((word) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 21,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(
                            0xFFE4D8C8,
                          ),
                        ),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: brown,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                const Text(
                  'ما الكلمات التي شاهدتها؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر الكلمات التي تتذكرها. خذ وقتك.',
                  style: TextStyle(
                    color: muted,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: choices.map((word) {
                    final isSelected = selected.contains(word);

                    return FilterChip(
                      selected: isSelected,
                      label: Text(word),
                      selectedColor: const Color(0xFFF0E3D2),
                      checkmarkColor: rose,
                      side: BorderSide(
                        color: isSelected ? rose : const Color(0xFFE4D8C8),
                      ),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            selected.add(word);
                          } else {
                            selected.remove(word);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton(
                    onPressed: selected.isEmpty ? null : _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: rose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'إنهاء التمرين',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
