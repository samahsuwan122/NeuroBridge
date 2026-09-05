import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';
import 'caregiver_live_data.dart';

class PatientSummaryScreen extends StatelessWidget {
  const PatientSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CaregiverLiveData(
      title: 'ملخص المريض',
      builder: (context, data, reload) {
        final patient = asMap(data['patient']);
        final summary = asMap(data['summary']);
        final privacy = asMap(data['privacy']);
        final appointments = asRows(data['appointments']);
        final name = patient['full_name']?.toString() ?? 'المريض';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص $name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Text(
              'يظهر فقط ما سمح المريض بمشاركته.',
              style: TextStyle(color: CaregiverColors.muted),
            ),
            const SizedBox(height: 22),
            if (asBool(privacy['share_progress']))
              Row(
                children: [
                  Expanded(child: _SummaryStat(value: '${asInt(summary['average'])}%', label: 'متوسط الأداء')),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryStat(value: '${asInt(summary['weekly_sessions'])}', label: 'جلسات الأسبوع')),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryStat(value: '${asInt(summary['minutes'])}', label: 'دقيقة تدريب')),
                ],
              )
            else
              const CaregiverCard(
                color: Color(0xFFFFF2DF),
                child: Text('بيانات التقدّم غير متاحة حسب صلاحيات المريض.'),
              ),
            const SizedBox(height: 16),
            CaregiverCard(
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: CaregiverColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الموعد القادم', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          !asBool(privacy['share_appointments'])
                              ? 'المريض لم يسمح بمشاركة المواعيد'
                              : appointments.isEmpty
                                  ? 'لا يوجد موعد قادم'
                                  : '${appointments.first['preferred_date'] ?? ''} • ${appointments.first['preferred_time'] ?? ''}\n${appointments.first['provider_name'] ?? 'مقدم الرعاية'}',
                          style: const TextStyle(color: CaregiverColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const CaregiverCard(
              color: Color(0xFFFFF2DF),
              child: Text(
                'ملاحظات الطبيب الخاصة والمعلومات الطبية الحساسة لا تظهر في حساب العائلة.',
                style: TextStyle(height: 1.7, color: Color(0xFF7A654D)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      child: Column(
        children: [
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: CaregiverColors.rose),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: CaregiverColors.muted)),
        ],
      ),
    );
  }
}
