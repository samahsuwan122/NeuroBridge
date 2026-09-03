import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class CardMatchingScreen extends StatefulWidget {
  const CardMatchingScreen({super.key});

  @override
  State<CardMatchingScreen> createState() => _CardMatchingScreenState();
}

class _CardMatchingScreenState extends State<CardMatchingScreen> {
  late List<String> _cards;
  final Set<int> _matched = {};
  final List<int> _opened = [];
  final Stopwatch _watch = Stopwatch();
  int _attempts = 0;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _cards = ['🍎', '🌷', '⭐', '🐱', '🍎', '⭐', '🐱', '🌷']
      ..shuffle(Random());
    _watch.start();
  }

  Future<void> _tapCard(int index) async {
    if (_checking || _matched.contains(index) || _opened.contains(index)) return;
    setState(() => _opened.add(index));
    if (_opened.length != 2) return;

    _attempts++;
    _checking = true;
    final first = _opened[0];
    final second = _opened[1];
    final match = _cards[first] == _cards[second];
    await Future<void>.delayed(Duration(milliseconds: match ? 400 : 750));
    if (!mounted) return;

    setState(() {
      if (match) {
        _matched.addAll([first, second]);
      }
      _opened.clear();
      _checking = false;
    });

    if (_matched.length == _cards.length) _finish();
  }

  void _finish() {
    _watch.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: _cards.length ~/ 2,
          totalQuestions: _cards.length ~/ 2,
          duration: _duration(_watch.elapsed),
          extraText: 'أكملت اللعبة في $_attempts محاولة.',
        ),
      ),
    );
  }

  String _duration(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              _Header(
                title: 'مطابقة البطاقات',
                trailing: 'المحاولات: $_attempts',
              ),
              const SizedBox(height: 10),
              const Text(
                'افتح بطاقتين وابحث عن الأزواج المتطابقة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (_, constraints) {
                  final columns = constraints.maxWidth < 390 ? 3 : 4;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: .86,
                    ),
                    itemBuilder: (_, index) {
                      final visible =
                          _opened.contains(index) || _matched.contains(index);
                      return Semantics(
                        button: true,
                        label: visible ? _cards[index] : 'بطاقة مخفية',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _tapCard(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _matched.contains(index)
                                  ? const Color(0xFFE5F3E8)
                                  : visible
                                      ? Colors.white
                                      : AppColors.primary,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              visible ? _cards[index] : '؟',
                              style: TextStyle(
                                fontSize: visible ? 34 : 25,
                                color: visible
                                    ? AppColors.textPrimary
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _Header extends StatelessWidget {
  final String title;
  final String trailing;
  const _Header({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      );
}
