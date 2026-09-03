import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class EventOrderingScreen extends StatefulWidget {
  const EventOrderingScreen({super.key});
  @override
  State<EventOrderingScreen> createState() => _EventOrderingScreenState();
}

class _EventOrderingScreenState extends State<EventOrderingScreen> {
  static const _rounds = <_OrderRound>[
    _OrderRound('رتّب خطوات تحضير الشاي',
        ['غلي الماء', 'وضع الشاي في الكوب', 'صب الماء', 'تقديم الكوب']),
    _OrderRound('رتّب خطوات غسل اليدين',
        ['فتح الماء', 'تبليل اليدين', 'استخدام الصابون', 'شطف اليدين', 'تجفيف اليدين']),
    _OrderRound('رتّب خطوات الخروج من المنزل',
        ['ارتداء الملابس', 'أخذ المفاتيح', 'إغلاق الباب', 'الذهاب إلى الوجهة']),
  ];
  final Stopwatch _watch = Stopwatch()..start();
  late List<String> _items;
  int _roundIndex = 0;
  int _correct = 0;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _items = _shuffled(_rounds.first.correct);
  }

  List<String> _shuffled(List<String> source) {
    final copy = List<String>.from(source)..shuffle();
    if (_same(copy, source)) return copy.reversed.toList();
    return copy;
  }

  bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _moveItem(int index, int change) {
    if (_checked) return;
    final newIndex = index + change;
    if (newIndex < 0 || newIndex >= _items.length) return;

    setState(() {
      final item = _items.removeAt(index);
      _items.insert(newIndex, item);
    });
  }

  void _next() {
    final round = _rounds[_roundIndex];
    if (!_checked) {
      var positions = 0;
      for (var i = 0; i < _items.length; i++) {
        if (_items[i] == round.correct[i]) positions++;
      }
      _correct += positions;
      setState(() => _checked = true);
      return;
    }
    if (_roundIndex == _rounds.length - 1) {
      _watch.stop();
      final total = _rounds.fold<int>(0, (sum, round) => sum + round.correct.length);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseResultScreen(
            correctAnswers: _correct,
            totalQuestions: total,
            duration: _duration(_watch.elapsed),
          ),
        ),
      );
      return;
    }
    setState(() {
      _roundIndex++;
      _items = _shuffled(_rounds[_roundIndex].correct);
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
    final round = _rounds[_roundIndex];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(index: _roundIndex, total: _rounds.length),
              const SizedBox(height: 18),
              Text(round.title,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('اسحب الخطوات للأعلى أو للأسفل.',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _items.length,
                onReorder: _checked
                    ? (_, __) {}
                    : (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _items.removeAt(oldIndex);
                          _items.insert(newIndex, item);
                        });
                      },
                itemBuilder: (_, index) {
                  final correct = _checked && _items[index] == round.correct[index];
                  return Container(
                    key: ValueKey('${_roundIndex}_${_items[index]}'),
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: correct ? const Color(0xFFE5F3E8) : Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF1E7D8),
                        child: Text('${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_items[index],
                          style: const TextStyle(fontWeight: FontWeight.w800))),
                      if (correct)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF71947A),
                        )
                      else ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 34,
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'تحريك للأعلى',
                                onPressed: index == 0
                                    ? null
                                    : () => _moveItem(index, -1),
                                icon: const Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  size: 23,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 34,
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'تحريك للأسفل',
                                onPressed: index == _items.length - 1
                                    ? null
                                    : () => _moveItem(index, 1),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 23,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            width: 38,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E7D8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.drag_indicator_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ]),
                  );
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(
                    !_checked
                        ? 'تحقق من الترتيب'
                        : _roundIndex == _rounds.length - 1
                            ? 'عرض النتيجة'
                            : 'المهمة التالية',
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

class _OrderRound {
  final String title;
  final List<String> correct;
  const _OrderRound(this.title, this.correct);
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
        const Expanded(child: Text('ترتيب الأحداث',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
        Text('${index + 1} / $total',
            style: const TextStyle(fontWeight: FontWeight.w900)),
      ]);
}
