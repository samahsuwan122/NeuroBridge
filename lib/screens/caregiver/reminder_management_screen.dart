import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class ReminderManagementScreen
    extends StatefulWidget {
  const ReminderManagementScreen({
    super.key,
  });

  @override
  State<ReminderManagementScreen>
      createState() =>
          _ReminderManagementScreenState();
}

class _ReminderManagementScreenState
    extends State<ReminderManagementScreen> {
  bool exercise = true;
  bool appointment = true;
  bool familyCall = false;
  bool dailyActivity = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'تذكيرات المريض',
                subtitle:
                    'تذكيرات يومية غير طبية.',
              ),

              const SizedBox(height: 25),

              _ReminderTile(
                title: 'وقت التمرين',
                icon:
                    Icons.psychology_alt_rounded,
                value: exercise,
                onChanged: (value) {
                  setState(() {
                    exercise = value;
                  });
                },
              ),

              const SizedBox(height: 10),

              _ReminderTile(
                title: 'موعد الجلسة',
                icon:
                    Icons.calendar_month_rounded,
                value: appointment,
                onChanged: (value) {
                  setState(() {
                    appointment = value;
                  });
                },
              ),

              const SizedBox(height: 10),

              _ReminderTile(
                title: 'الاتصال بالعائلة',
                icon: Icons.phone_outlined,
                value: familyCall,
                onChanged: (value) {
                  setState(() {
                    familyCall = value;
                  });
                },
              ),

              const SizedBox(height: 10),

              _ReminderTile(
                title: 'نشاط يومي بسيط',
                icon: Icons.directions_walk_rounded,
                value: dailyActivity,
                onChanged: (value) {
                  setState(() {
                    dailyActivity = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const CaregiverCard(
                color: Color(0xFFFFF2DF),
                child: Text(
                  'تذكيرات الأدوية غير متاحة في النسخة الحالية لأنها تحتاج متطلبات سلامة ومراجعة مختص.',
                  style: TextStyle(
                    height: 1.7,
                    color: Color(0xFF7B654B),
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

class _ReminderTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(
          icon,
          color: CaregiverColors.rose,
        ),
        value: value,
        activeColor: CaregiverColors.rose,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}