import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});
  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {
  static const _questions = <_SequenceQuestion>[
    _SequenceQuestion('1  ،  2  ،  3  ،  ؟', '4', ['3', '4', '5', '6']),
    _SequenceQuestion('2  ،  4  ،  6  ،  ؟', '8', ['7', '8', '9', '10']),
    _SequenceQuestion('10  ،  8  ،  6  ،  ؟', '4', ['2', '3', '4', '5']),
    _SequenceQuestion('●  ،  ■  ،  ●  ،  ؟', '■', ['▲', '●', '■', '★']),
    _SequenceQuestion('🌞  ،  🌙  ،  🌞  ،  ؟', '🌙', ['⭐', '🌞', '☁️', '🌙']),
  ];
  final Stopwatch _watch = Stopwatch()..start();
  int _index = 0;
  int _correct = 0;
  String? _answer;
  bool _checked = false;

  void _next() {
    if (!_checked) {
      if (_answer == _questions[_index].answer) _correct++;
      setState(() => _checked = true);
      return;
    }
    if (_index == _questions.length - 1) {
      _watch.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseResultScreen(
            correctAnswers: _correct,
            totalQuestions: _questions.length,
            duration: _duration(_watch.elapsed),
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _answer = null;
      _checked = false;
    });
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
    final q = _questions[_index];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              _Header(index: _index, total: _questions.length),
              const SizedBox(height: 28),
              const Text('ما العنصر التالي؟',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 16),
              NeuroCard(
                color: const Color(0xFFF1E7D8),
                child: Center(
                  child: FittedBox(
                    child: Text(q.sequence,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: q.options.map((option) {
                  final selected = _answer == option;
                  final correct = option == q.answer;
                  return ChoiceChip(
                    selected: selected,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(option, style: const TextStyle(fontSize: 22)),
                    ),
                    selectedColor: _checked && !correct
                        ? const Color(0xFFFFE8EE)
                        : const Color(0xFFF0E3D2),
                    backgroundColor:
                        _checked && correct ? const Color(0xFFE5F3E8) : null,
                    onSelected: _checked ? null : (_) => setState(() => _answer = option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _answer == null ? null : _next,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(
                    !_checked
                        ? 'تحقق من الإجابة'
                        : _index == _questions.length - 1
                            ? 'عرض النتيجة'
                            : 'التسلسل التالي',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SequenceQuestion {
  final String sequence;
  final String answer;
  final List<String> options;
  const _SequenceQuestion(this.sequence, this.answer, this.options);
}

class _Header extends StatelessWidget {
  final int index;
  final int total;
  const _Header({required this.index, required this.total});
  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        const Expanded(
          child: Text('أكمل التسلسل',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ),
        Text('${index + 1} / $total',
            style: const TextStyle(fontWeight: FontWeight.w900)),
      ]);
}
