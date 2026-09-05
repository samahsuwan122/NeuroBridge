import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';
import 'caregiver_live_data.dart';

class FamilyProgressScreen extends StatelessWidget {
  const FamilyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CaregiverLiveData(
      title: 'التقدّم',
      builder: (context, data, reload) {
        final patient = asMap(data['patient']);
        final summary = asMap(data['summary']);
        final activities = asRows(data['activities']);
        final name = patient['full_name']?.toString() ?? 'المريض';
        final progressAllowed = asBool(asMap(data['privacy'])['share_progress']);

        if (!progressAllowed) {
          return const CaregiverCard(
            color: Color(0xFFFFF2DF),
            child: Text(
              'المريض لم يسمح بمشاركة بيانات التقدّم حاليًا.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final values = activities.take(7).map((activity) {
          final total = asInt(activity['total_questions']);
          if (total <= 0) return 0.0;
          return (asInt(activity['score']) / total).clamp(0.0, 1.0);
        }).toList().reversed.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدّم $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: CaregiverColors.brown,
              ),
            ),
            const Text(
              'يتم مقارنة المريض بنفسه فقط.',
              style: TextStyle(color: CaregiverColors.muted),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _FamilyStat(
                    value: '${asInt(summary['average'])}%',
                    label: 'متوسط الأداء',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FamilyStat(
                    value: '${asInt(summary['sessions'])}',
                    label: 'جلسة',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FamilyStat(
                    value: '${asInt(summary['active_days'])}',
                    label: 'أيام نشطة',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            CaregiverCard(
              child: SizedBox(
                height: 190,
                child: values.isEmpty
                    ? const Center(child: Text('لا توجد جلسات مسجلة بعد'))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: values.map((value) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                height: (145 * value.clamp(.05, 1.0)).toDouble(),
                                decoration: BoxDecoration(
                                  color: CaregiverColors.rose,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            const CaregiverCard(
              color: Color(0xFFEAF4ED),
              child: Text(
                'ركّزوا على التشجيع والاستمرارية بدل المقارنة أو الضغط على المريض.',
                style: TextStyle(height: 1.7, color: Color(0xFF607164)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FamilyStat extends StatelessWidget {
  final String value;
  final String label;

  const _FamilyStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      child: Column(
        children: [
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: CaregiverColors.rose,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: CaregiverColors.muted),
          ),
        ],
      ),
    );
  }
}
