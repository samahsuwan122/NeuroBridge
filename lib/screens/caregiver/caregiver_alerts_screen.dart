import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class CaregiverAlertsScreen
    extends StatefulWidget {
  const CaregiverAlertsScreen({super.key});

  @override
  State<CaregiverAlertsScreen> createState() =>
      _CaregiverAlertsScreenState();
}

class _CaregiverAlertsScreenState
    extends State<CaregiverAlertsScreen> {
  bool missedSession = true;
  bool achievements = true;
  bool appointments = true;
  bool helpRequests = true;
  bool inactivity = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'تنبيهات النشاط',
                subtitle:
                    'اختر التنبيهات المهمة حتى لا تصبح الإشعارات مزعجة.',
              ),

              const SizedBox(height: 24),

              const Text(
                'آخر التنبيهات',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              const CaregiverCard(
                child: Text(
                  '🌷 أكمل سامي ثلاثة أيام متتالية.',
                ),
              ),

              const SizedBox(height: 9),

              const CaregiverCard(
                child: Text(
                  '📅 يوجد موعد غدًا الساعة 10:00 صباحًا.',
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'أنواع التنبيهات',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              _AlertSwitch(
                title: 'جلسة غير مكتملة',
                value: missedSession,
                onChanged: (v) {
                  setState(() {
                    missedSession = v;
                  });
                },
              ),
              _AlertSwitch(
                title: 'الإنجازات والاستمرار',
                value: achievements,
                onChanged: (v) {
                  setState(() {
                    achievements = v;
                  });
                },
              ),
              _AlertSwitch(
                title: 'المواعيد',
                value: appointments,
                onChanged: (v) {
                  setState(() {
                    appointments = v;
                  });
                },
              ),
              _AlertSwitch(
                title: 'طلب مساعدة من المريض',
                value: helpRequests,
                onChanged: (v) {
                  setState(() {
                    helpRequests = v;
                  });
                },
              ),
              _AlertSwitch(
                title: 'عدم استخدام التطبيق لفترة',
                value: inactivity,
                onChanged: (v) {
                  setState(() {
                    inactivity = v;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AlertSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),
      child: CaregiverCard(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor:
              CaregiverColors.rose,
          value: value,
          title: Text(title),
          onChanged: onChanged,
        ),
      ),
    );
  }
}