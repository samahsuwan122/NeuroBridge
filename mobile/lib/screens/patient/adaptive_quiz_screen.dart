import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class AdaptiveQuizScreen extends StatefulWidget {
  final Exercise exercise;

  const AdaptiveQuizScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<AdaptiveQuizScreen> createState() => _AdaptiveQuizScreenState();
}

class _AdaptiveQuizScreenState extends State<AdaptiveQuizScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _studyTimer;

  late final List<_Question> _questions;
  late final String _studyText;
  late int _studySeconds;

  bool _studying = false;
  bool _checked = false;
  int _index = 0;
  int _correct = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();

    final content = widget.exercise.content;
    _studyText = content['study_text']?.toString().trim() ?? '';
    _studySeconds = _asInt(content['study_seconds'], fallback: 20);
    _questions = _parseQuestions(content['questions']);

    if (_studyText.isNotEmpty) {
      _studying = true;
      _startStudyTimer();
    } else {
      _stopwatch.start();
    }
  }

  List<_Question> _parseQuestions(dynamic value) {
    if (value is! List) return const [];

    return value.whereType<Map>().map((raw) {
      final data = Map<String, dynamic>.from(raw);
      final options = data['options'] is List
          ? (data['options'] as List).map((e) => e.toString()).toList()
          : <String>[];

      return _Question(
        prompt: data['prompt']?.toString() ?? '',
        options: options,
        answer: data['answer']?.toString() ?? '',
        explanation: data['explanation']?.toString() ?? '',
      );
    }).where((q) {
      return q.prompt.isNotEmpty &&
          q.answer.isNotEmpty &&
          q.options.contains(q.answer);
    }).toList();
  }

  void _startStudyTimer() {
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_studySeconds <= 1) {
        timer.cancel();
        _beginQuestions();
        return;
      }

      setState(() => _studySeconds--);
    });
  }

  void _beginQuestions() {
    _studyTimer?.cancel();
    setState(() => _studying = false);
    _stopwatch.start();
  }

  void _submit() {
    if (_selected == null) return;

    if (!_checked) {
      if (_selected == _questions[_index].answer) {
        _correct++;
      }
      setState(() => _checked = true);
      return;
    }

    if (_index == _questions.length - 1) {
      _finish();
      return;
    }

    setState(() {
      _index++;
      _selected = null;
      _checked = false;
    });
  }

  void _finish() {
    _stopwatch.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: _correct,
          totalQuestions: _questions.length,
          duration: _formatDuration(_stopwatch.elapsed),
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '${value.inMinutes}:$seconds';
  }

  int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: _questions.isEmpty
              ? _InvalidContent(onBack: () => Navigator.pop(context))
              : _studying
                  ? _buildStudyStep()
                  : _buildQuestionStep(),
        ),
      ),
    );
  }

  Widget _buildStudyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: widget.exercise.title,
          trailing: '$_studySeconds ث',
          onBack: () => Navigator.pop(context),
        ),
        const SizedBox(height: 24),
        const Text(
          'اقرأ واحفظ المعلومات التالية',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'ستختفي المعلومات عند بدء الأسئلة.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        NeuroCard(
          color: const Color(0xFFF1E7D8),
          child: SelectableText(
            _studyText,
            style: const TextStyle(
              height: 1.9,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _beginQuestions,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'أنا جاهز للأسئلة',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionStep() {
    final question = _questions[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: widget.exercise.title,
          trailing: '${_index + 1} / ${_questions.length}',
          onBack: () => Navigator.pop(context),
        ),
        const SizedBox(height: 18),
        LinearProgressIndicator(
          value: (_index + 1) / _questions.length,
          minHeight: 7,
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primary,
          backgroundColor: const Color(0xFFE8DCCB),
        ),
        const SizedBox(height: 28),
        Text(
          question.prompt,
          style: const TextStyle(
            height: 1.6,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        ...question.options.map((option) {
          final selected = _selected == option;
          final correct = option == question.answer;

          Color? color;
          if (_checked && correct) {
            color = const Color(0xFFE4F2E8);
          } else if (_checked && selected && !correct) {
            color = const Color(0xFFFFE8EE);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _checked
                  ? null
                  : () => setState(() => _selected = option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color ?? Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected || (_checked && correct)
                        ? AppColors.primary
                        : AppColors.border,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _checked && correct
                          ? Icons.check_circle_rounded
                          : selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                      color: selected || (_checked && correct)
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_checked && question.explanation.isNotEmpty) ...[
          const SizedBox(height: 4),
          NeuroCard(
            color: const Color(0xFFF5ECE0),
            child: Text(
              question.explanation,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _selected == null ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              !_checked
                  ? 'تحقق من الإجابة'
                  : _index == _questions.length - 1
                      ? 'عرض النتيجة'
                      : 'السؤال التالي',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _Question {
  final String prompt;
  final List<String> options;
  final String answer;
  final String explanation;

  const _Question({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

class _Header extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.trailing,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          trailing,
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InvalidContent extends StatelessWidget {
  final VoidCallback onBack;

  const _InvalidContent({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeuroCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            const Text('محتوى هذا التمرين غير صالح.'),
            TextButton(onPressed: onBack, child: const Text('العودة')),
          ],
        ),
      ),
    );
  }
}
