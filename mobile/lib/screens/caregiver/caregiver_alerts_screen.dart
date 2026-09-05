import 'package:flutter/material.dart';

import '../../core/services/caregiver_features_service.dart';
import '../../widgets/caregiver_ui.dart';
import 'caregiver_live_data.dart';

class CaregiverAlertsScreen extends StatelessWidget {
  const CaregiverAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CaregiverLiveData(
      title: 'تنبيهات النشاط',
      builder: (context, data, reload) {
        final settings = asMap(data['settings']);
        final checkins = asRows(data['checkins']);
        final moodAllowed = asBool(asMap(data['privacy'])['share_mood']);

        const alertTypes = {
          'missed_session_alert': 'جلسة غير مكتملة',
          'achievements_alert': 'الإنجازات والاستمرار',
          'appointments_alert': 'المواعيد',
          'help_requests_alert': 'طلب مساعدة من المريض',
          'inactivity_alert': 'عدم استخدام التطبيق لفترة',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آخر الحالات اليومية', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (!moodAllowed)
              const CaregiverCard(child: Text('المريض لم يسمح بمشاركة حالته اليومية.'))
            else if (checkins.isEmpty)
              const CaregiverCard(child: Text('لا توجد حالات يومية مسجلة بعد.'))
            else
              ...checkins.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CaregiverCard(
                      child: Text(
                        '${item['checkin_date'] ?? ''} • ${item['mood'] ?? 'غير محدد'} • طاقة ${item['energy'] ?? '-'}${asBool(item['need_help']) ? ' • يحتاج مساعدة' : ''}',
                      ),
                    ),
                  )),
            const SizedBox(height: 20),
            const Text('أنواع التنبيهات', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...alertTypes.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: CaregiverCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: CaregiverColors.rose,
                      title: Text(entry.value),
                      value: asBool(settings[entry.key]),
                      onChanged: (value) async {
                        try {
                          await CaregiverFeaturesService.post('settings', {entry.key: value});
                          await reload();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      },
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }
}
