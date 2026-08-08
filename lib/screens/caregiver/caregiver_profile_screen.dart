import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

import '../login_screen.dart';

import 'caregiver_alerts_screen.dart';
import 'family_permissions_screen.dart';
import 'patient_switcher_screen.dart';

class CaregiverProfileScreen
    extends StatelessWidget {
  const CaregiverProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'حسابي',
              ),

              const SizedBox(height: 25),

              const CircleAvatar(
                radius: 50,
                backgroundColor:
                    Color(0xFFFFE9EF),
                child: Icon(
                  Icons.person_rounded,
                  size: 53,
                  color:
                      CaregiverColors.rose,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'ليلى أحمد',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'ابنة • حساب مرافق',
                style: TextStyle(
                  color: CaregiverColors.rose,
                ),
              ),

              const SizedBox(height: 25),

              const CaregiverCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color:
                          CaregiverColors.rose,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'family@neurobridge.com',
                        textDirection:
                            TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.people_outline_rounded,
                title: 'المرضى المرتبطون',
                subtitle:
                    'إدارة الملفات المرتبطة',
                color: CaregiverColors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientSwitcherScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle:
                    'العربية، English والمزيد',
                color: CaregiverColors.green,
                onTap: () {},
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon:
                    Icons.notifications_none_rounded,
                title: 'الإشعارات',
                subtitle:
                    'إدارة التنبيهات',
                color: CaregiverColors.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CaregiverAlertsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon:
                    Icons.privacy_tip_outlined,
                title: 'الخصوصية والصلاحيات',
                subtitle:
                    'معرفة البيانات المتاحة لك',
                color: CaregiverColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FamilyPermissionsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFFC26470),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(),
                      ),
                      (_) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                  ),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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