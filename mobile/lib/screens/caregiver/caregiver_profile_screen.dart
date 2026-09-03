import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/caregiver_ui.dart';

import '../login_screen.dart';

import 'caregiver_alerts_screen.dart';
import 'family_permissions_screen.dart';
import 'patient_switcher_screen.dart';

class CaregiverProfileScreen extends StatelessWidget {
  const CaregiverProfileScreen({
    super.key,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.center),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(130, 48),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

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
                backgroundColor: Color(0xFFF1E7D8),
                child: Icon(
                  Icons.person_rounded,
                  size: 53,
                  color: CaregiverColors.rose,
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
                      color: CaregiverColors.rose,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'family@neurobridge.com',
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.people_outline_rounded,
                title: 'المرضى المرتبطون',
                subtitle: 'إدارة الملفات المرتبطة',
                color: CaregiverColors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientSwitcherScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle: 'العربية، English والمزيد',
                color: CaregiverColors.green,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                subtitle: 'إدارة التنبيهات',
                color: CaregiverColors.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverAlertsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.privacy_tip_outlined,
                title: 'الخصوصية والصلاحيات',
                subtitle: 'معرفة البيانات المتاحة لك',
                color: CaregiverColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyPermissionsScreen(),
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
                    foregroundColor: const Color(0xFFC26470),
                  ),
                  onPressed: () {
                    _confirmLogout(context);
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
