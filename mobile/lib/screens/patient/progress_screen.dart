import 'package:flutter/material.dart';

import '../../core/services/exercise_progress_service.dart';
import '../../core/services/patient_goals_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class ProgressScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final int refreshToken;

  const ProgressScreen({
    super.key,
    this.onBack,
    this.refreshToken = 0,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> _data = const {};
  List<PatientGoal> _goals = const [];
  bool _loading = true;
  String? _error;

  int _int(String key) {
    return int.tryParse(_data[key]?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        ExerciseProgressService.loadDashboard(),
        PatientGoalsService.loadGoals(),
      ]);

      if (!mounted) return;
      setState(() {
        _data = Map<String, dynamic>.from(results[0] as Map);
        _goals = List<PatientGoal>.from(results[1] as List);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekly = (_data['weekly'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final recent = (_data['recent'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقدّمي',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'أهدافك ونتائج تمارينك المكتملة.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 15),
                NeuroCard(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _load,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ] else if (!_loading) ...[
                const SizedBox(height: 22),
                const PatientSectionTitle(title: 'أهدافي'),
                const SizedBox(height: 12),
                if (_goals.isEmpty)
                  const NeuroCard(
                    child: Center(
                      child: Text('لم يعيّن مقدم الرعاية أهدافًا لك بعد.'),
                    ),
                  )
                else
                  ..._goals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GoalCard(goal: goal),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressStat(
                        Icons.task_alt_rounded,
                        '${_int('total_attempts')}',
                        'تمرين مكتمل',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProgressStat(
                        Icons.local_fire_department_rounded,
                        '${_int('streak')}',
                        'أيام استمرار',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressStat(
                        Icons.timer_outlined,
                        _time(_int('total_minutes')),
                        'وقت التدريب',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProgressStat(
                        Icons.insights_rounded,
                        '${_int('average')}%',
                        'متوسط الأداء',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const PatientSectionTitle(title: 'نشاط آخر 7 أيام'),
                const SizedBox(height: 12),
                NeuroCard(
                  child: SizedBox(
                    height: 190,
                    child: weekly.isEmpty
                        ? const Center(
                            child: Text('أكمل تمرينًا ليظهر نشاطك هنا.'),
                          )
                        : _WeeklyChart(items: weekly),
                  ),
                ),
                const SizedBox(height: 25),
                const PatientSectionTitle(title: 'آخر التمارين'),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const NeuroCard(
                    child: Center(
                      child: Text('لا توجد نتائج محفوظة بعد.'),
                    ),
                  )
                else
                  ...recent.map((row) => _RecentExercise(row: row)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _time(int minutes) {
    return minutes < 60
        ? '$minutes دقيقة'
        : '${(minutes / 60).toStringAsFixed(1)} ساعة';
  }
}

class _GoalCard extends StatelessWidget {
  final PatientGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent.clamp(0, 100).toInt();

    return NeuroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E7D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal.statusTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              goal.description,
              style: const TextStyle(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'التقدّم',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            color: AppColors.secondaryDark,
            backgroundColor: const Color(0xFFE8DCCB),
          ),
          const SizedBox(height: 8),
          Text(
            '${_number(goal.currentValue)} من ${_number(goal.targetValue)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          if (goal.dueDate != null && goal.dueDate!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'الموعد المستهدف: ${goal.dueDate}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _number(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _WeeklyChart({required this.items});

  @override
  Widget build(BuildContext context) {
    const days = ['ث', 'أ', 'ن', 'ث', 'خ', 'ج', 'س'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(items.length, (index) {
        final value = int.tryParse(items[index]['value']?.toString() ?? '') ?? 0;
        final date = DateTime.tryParse(items[index]['date']?.toString() ?? '');

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$value%', style: const TextStyle(fontSize: 9)),
                const SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 140.0 * (value.clamp(0, 100).toInt() / 100.0),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  date == null ? '' : days[date.weekday % 7],
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _RecentExercise extends StatelessWidget {
  final Map<String, dynamic> row;

  const _RecentExercise({required this.row});

  @override
  Widget build(BuildContext context) {
    final score = int.tryParse(row['score']?.toString() ?? '') ?? 0;
    final total = int.tryParse(row['total_questions']?.toString() ?? '') ?? 0;
    final percent = total == 0 ? 0 : (score * 100 / total).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: NeuroCard(
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E7D8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.psychology_alt_rounded),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row['title']?.toString() ?? 'تمرين',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row['completed_at']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 7),
          FittedBox(
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
