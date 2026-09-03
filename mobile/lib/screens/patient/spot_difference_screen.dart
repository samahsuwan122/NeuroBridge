import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class SpotDifferenceScreen extends StatefulWidget {
  const SpotDifferenceScreen({super.key});
  @override
  State<SpotDifferenceScreen> createState() => _SpotDifferenceScreenState();
}

class _SpotDifferenceScreenState extends State<SpotDifferenceScreen> {
  static const _rounds = <_DifferenceRound>[
    _DifferenceRound(
      ['🏠', '🌳', '☀️', '🐦', '🌷', '🚗', '☁️', '🐱', '⭐'],
      ['🏠', '🌲', '☀️', '🦋', '🌷', '🚗', '🌧️', '🐱', '⭐'],
      {1, 3, 6},
    ),
    _DifferenceRound(
      ['🍎', '🍌', '🍇', '🥕', '🍞', '🧀', '🥛', '🍓', '🍊'],
      ['🍎', '🍌', '🍐', '🥕', '🥐', '🧀', '🧃', '🍓', '🍊'],
      {2, 4, 6},
    ),
    _DifferenceRound(
      ['⚽', '🎈', '🎁', '🚲', '🧸', '🎵', '📕', '✏️', '⌚'],
      ['🏀', '🎈', '🎁', '🛴', '🧸', '🎵', '📗', '✏️', '⌚'],
      {0, 3, 6},
    ),
  ];

  final Stopwatch _watch = Stopwatch()..start();
  final Set<int> _found = {};
  int _roundIndex = 0;
  int _wrongTaps = 0;
  bool _showHint = false;

  void _tap(int index) {
    final round = _rounds[_roundIndex];
    if (round.differences.contains(index)) {
      setState(() => _found.add(index));
      if (_found.length == round.differences.length) {
        Future<void>.delayed(const Duration(milliseconds: 450), _nextRound);
      }
    } else {
      setState(() => _wrongTaps++);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('هذا العنصر متشابه، جرّبي مكانًا آخر.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 700),
      ));
    }
  }

  void _nextRound() {
    if (!mounted) return;
    if (_roundIndex == _rounds.length - 1) {
      _watch.stop();
      final total = _rounds.length * 3;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseResultScreen(
            correctAnswers: total,
            totalQuestions: total,
            duration: _duration(_watch.elapsed),
            extraText: 'عدد اللمسات غير الصحيحة: $_wrongTaps',
          ),
        ),
      );
      return;
    }
    setState(() {
      _roundIndex++;
      _found.clear();
      _showHint = false;
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
    final round = _rounds[_roundIndex];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                const Expanded(child: Text('اكتشف الاختلاف',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                Text('${_found.length} / ${round.differences.length}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 7),
              Text('الجولة ${_roundIndex + 1} من ${_rounds.length} • اضغط على الاختلاف في الصورة الثانية',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _PictureGrid(items: round.left)),
                const SizedBox(width: 10),
                Expanded(child: _PictureGrid(
                  items: round.right,
                  onTap: _tap,
                  found: _found,
                )),
              ]),
              if (_showHint) ...[
                const SizedBox(height: 14),
                NeuroCard(
                  color: const Color(0xFFFFF1DD),
                  child: Text(
                    'تلميح: ركّز على الصف ${(_firstMissing(round) ~/ 3) + 1}.',
                    style: const TextStyle(color: Color(0xFF806544)),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _found.length == round.differences.length
                    ? null
                    : () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('أعطني تلميحًا'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _firstMissing(_DifferenceRound round) =>
      round.differences.firstWhere((index) => !_found.contains(index));
}

class _PictureGrid extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int>? onTap;
  final Set<int> found;
  const _PictureGrid({required this.items, this.onTap, this.found = const {}});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
          ),
          itemBuilder: (_, index) => InkWell(
            onTap: onTap == null ? null : () => onTap!(index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: found.contains(index) ? const Color(0xFFE5F3E8) : null,
                borderRadius: BorderRadius.circular(10),
                border: found.contains(index)
                    ? Border.all(color: const Color(0xFF71947A), width: 2)
                    : null,
              ),
              child: FittedBox(child: Text(items[index],
                  style: const TextStyle(fontSize: 27))),
            ),
          ),
        ),
      );
}

class _DifferenceRound {
  final List<String> left;
  final List<String> right;
  final Set<int> differences;
  const _DifferenceRound(this.left, this.right, this.differences);
}
