import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class PictureRecognitionScreen extends StatefulWidget {
  const PictureRecognitionScreen({super.key});

  @override
  State<PictureRecognitionScreen> createState() => _PictureRecognitionScreenState();
}

class _PictureRecognitionScreenState extends State<PictureRecognitionScreen> {
  static const _questions = <_PictureQuestion>[
    _PictureQuestion('تفاحة', '🍎', ['🍎', '🚗', '🐱', '🌳']),
    _PictureQuestion('سيارة', '🚗', ['🐶', '🚗', '🌷', '📕']),
    _PictureQuestion('قطة', '🐱', ['🐰', '🐱', '🐦', '🐟']),
    _PictureQuestion('شجرة', '🌳', ['🌞', '🏠', '🌳', '🌙']),
    _PictureQuestion('ساعة', '⌚', ['🔑', '⌚', '📱', '✏️']),
  ];
  final Stopwatch _watch = Stopwatch()..start();
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _checked = false;

  void _next() {
    final question = _questions[_index];
    if (!_checked) {
      if (_selected == question.answer) _correct++;
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
      _selected = null;
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
    final question = _questions[_index];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              _Header(index: _index, total: _questions.length),
              const SizedBox(height: 25),
              Text('اختر صورة: ${question.word}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 22),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 11,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (_, index) {
                  final option = question.options[index];
                  final selected = _selected == option;
                  final correct = option == question.answer;
                  final background = _checked && correct
                      ? const Color(0xFFE5F3E8)
                      : _checked && selected && !correct
                          ? const Color(0xFFFFE8EE)
                          : selected
                              ? const Color(0xFFF1E7D8)
                              : Colors.white.withValues(alpha: .82);
                  return InkWell(
                    borderRadius: BorderRadius.circular(21),
                    onTap: _checked ? null : () => setState(() => _selected = option),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: selected || (_checked && correct)
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 53)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _selected == null ? null : _next,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(
                    !_checked
                        ? 'تأكيد الاختيار'
                        : _index == _questions.length - 1
                            ? 'عرض النتيجة'
                            : 'الصورة التالية',
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

class _PictureQuestion {
  final String word;
  final String answer;
  final List<String> options;
  const _PictureQuestion(this.word, this.answer, this.options);
}

class _Header extends StatelessWidget {
  final int index;
  final int total;
  const _Header({required this.index, required this.total});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          const Expanded(
            child: Text('التعرّف على الصور',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ),
          Text('${index + 1} / $total',
              style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}
