import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class CategorizationScreen extends StatefulWidget {
  const CategorizationScreen({super.key});

  @override
  State<CategorizationScreen> createState() => _CategorizationScreenState();
}

class _CategorizationScreenState extends State<CategorizationScreen> {
  static const _questions = <_CategoryQuestion>[
    _CategoryQuestion('🍎', 'تفاحة', 'طعام'),
    _CategoryQuestion('👕', 'قميص', 'ملابس'),
    _CategoryQuestion('🐱', 'قطة', 'حيوانات'),
    _CategoryQuestion('🪑', 'كرسي', 'أدوات منزلية'),
    _CategoryQuestion('🍞', 'خبز', 'طعام'),
    _CategoryQuestion('👟', 'حذاء', 'ملابس'),
  ];
  static const _categories = <(String, IconData)>[
    ('طعام', Icons.restaurant_rounded),
    ('ملابس', Icons.checkroom_rounded),
    ('حيوانات', Icons.pets_rounded),
    ('أدوات منزلية', Icons.chair_alt_rounded),
  ];

  final Stopwatch _watch = Stopwatch()..start();
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _checked = false;

  void _next() {
    if (!_checked) {
      final correct = _selected == _questions[_index].category;
      if (correct) _correct++;
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
              _GameHeader(title: 'تصنيف العناصر', index: _index, total: _questions.length),
              const SizedBox(height: 25),
              Text(question.emoji, style: const TextStyle(fontSize: 75)),
              Text(
                question.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'إلى أي مجموعة ينتمي هذا العنصر؟',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ..._categories.map((category) {
                final selected = _selected == category.$1;
                final correct = category.$1 == question.category;
                final color = _checked && correct
                    ? const Color(0xFFE5F3E8)
                    : _checked && selected && !correct
                        ? const Color(0xFFFFE8EE)
                        : selected
                            ? const Color(0xFFF1E7D8)
                            : Colors.white.withValues(alpha: .82);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: _checked
                        ? null
                        : () => setState(() => _selected = category.$1),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: selected || (_checked && correct)
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(category.$2, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.$1,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (_checked && correct)
                            const Icon(Icons.check_circle, color: Color(0xFF71947A)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _selected == null ? null : _next,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(
                    !_checked
                        ? 'تحقق من الإجابة'
                        : _index == _questions.length - 1
                            ? 'عرض النتيجة'
                            : 'العنصر التالي',
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

class _CategoryQuestion {
  final String emoji;
  final String name;
  final String category;
  const _CategoryQuestion(this.emoji, this.name, this.category);
}

class _GameHeader extends StatelessWidget {
  final String title;
  final int index;
  final int total;
  const _GameHeader({required this.title, required this.index, required this.total});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ),
          Text('${index + 1} / $total',
              style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}
