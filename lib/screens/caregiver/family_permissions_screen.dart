import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class FamilyPermissionsScreen
    extends StatefulWidget {
  const FamilyPermissionsScreen({
    super.key,
  });

  @override
  State<FamilyPermissionsScreen>
      createState() =>
          _FamilyPermissionsScreenState();
}

class _FamilyPermissionsScreenState
    extends State<FamilyPermissionsScreen> {
  bool activity = true;
  bool progress = true;
  bool appointments = true;
  bool photos = true;
  bool communication = true;
  bool profile = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'صلاحياتي',
                subtitle:
                    'هذه الصلاحيات يحددها المريض أو المسؤول المخوّل.',
              ),

              const SizedBox(height: 25),

              _Permission(
                title: 'النشاط العام',
                value: activity,
                onChanged: null,
              ),
              _Permission(
                title: 'التقدّم',
                value: progress,
                onChanged: null,
              ),
              _Permission(
                title: 'المواعيد',
                value: appointments,
                onChanged: null,
              ),
              _Permission(
                title: 'الصور والذكريات',
                value: photos,
                onChanged: null,
              ),
              _Permission(
                title: 'التواصل',
                value: communication,
                onChanged: null,
              ),
              _Permission(
                title: 'الملف الشخصي',
                value: profile,
                onChanged: null,
              ),

              const SizedBox(height: 15),

              const CaregiverCard(
                color: Color(0xFFFFF2DF),
                child: Text(
                  'لا يستطيع المرافق منح نفسه صلاحيات حساسة. أي تغيير يحتاج موافقة المريض أو المسؤول المخوّل.',
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

class _Permission extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _Permission({
    required this.title,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),
      child: CaregiverCard(
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.check_circle_rounded
                  : Icons.lock_outline_rounded,
              color: value
                  ? CaregiverColors.green
                  : CaregiverColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              value ? 'مسموح' : 'غير مسموح',
              style: TextStyle(
                color: value
                    ? CaregiverColors.green
                    : CaregiverColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}