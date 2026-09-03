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
  static const _rounds = <_RecallRound>[
    _RecallRound(['تفاحة', 'قمر', 'كتاب', 'شجرة'],
        ['قمر', 'سيارة', 'شجرة', 'كتاب', 'بحر', 'تفاحة']),
    _RecallRound(['باب', 'ساعة', 'وردة', 'كرسي'],
        ['نافذة', 'ساعة', 'وردة', 'قلم', 'باب', 'كرسي']),
    _RecallRound(['مفتاح', 'بحر', 'قطة', 'شمس'],
        ['قطة', 'شمس', 'سيارة', 'مفتاح', 'نهر', 'بحر']),
  ];

  final Stopwatch _watch = Stopwatch()..start();
  final Set<String> _selected = {};
  Timer? _timer;
  int _roundIndex = 0;
  int _seconds = 7;
  int _correct = 0;
  bool _showWords = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 7;
    _showWords = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
        setState(() {
          _seconds = 0;
          _showWords = false;
        });
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _submit() {
    final round = _rounds[_roundIndex];
    _correct += _selected.where(round.words.contains).length;
    if (_roundIndex == _rounds.length - 1) {
      _watch.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseResultScreen(
            correctAnswers: _correct,
            totalQuestions: _rounds.length * 4,
            duration: _duration(_watch.elapsed),
          ),
        ),
      );
      return;
    }
    setState(() {
      _roundIndex++;
      _selected.clear();
    });
    _startTimer();
  }

  String _duration(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    _watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_roundIndex];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                const Expanded(child: Text('تذكّر الكلمات',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                Text('${_roundIndex + 1} / ${_rounds.length}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 20),
              if (_showWords) ...[
                Center(child: Chip(
                  avatar: const Icon(Icons.timer_outlined),
                  label: Text('احفظ الكلمات • $_seconds'),
                )),
                const SizedBox(height: 24),
                const Text('حاول تذكّر هذه الكلمات بهدوء',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 11,
                  runSpacing: 11,
                  children: round.words.map((word) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(word,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  )).toList(),
                ),
              ] else ...[
                const Text('ما الكلمات التي شاهدتها؟',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                const Text('اختر كل الكلمات التي تتذكرها.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: round.choices.map((word) => FilterChip(
                    selected: _selected.contains(word),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      child: Text(word),
                    ),
                    selectedColor: const Color(0xFFF0E3D2),
                    onSelected: (selected) => setState(() {
                      selected ? _selected.add(word) : _selected.remove(word);
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 27),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _selected.isEmpty ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text(
                      _roundIndex == _rounds.length - 1
                          ? 'عرض النتيجة'
                          : 'الجولة التالية',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

class _RecallRound {
  final List<String> words;
  final List<String> choices;
  const _RecallRound(this.words, this.choices);
}
