import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'accessibility_screen.dart';
import 'patient_family_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  static const rose = Color(0xFFB87585);
  static const brown = Color(0xFF4F3C38);
  static const muted = Color(0xFF89736F);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'الملف الشخصي',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE9EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 55,
                        color: rose,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: rose,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'سامي أحمد',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Center(
                child: Text(
                  'حساب مريض',
                  style: TextStyle(
                    color: rose,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const PatientSectionTitle(
                title: 'معلوماتي',
              ),

              const SizedBox(height: 12),

              const _ProfileInfo(
                icon: Icons.cake_outlined,
                title: 'العمر',
                value: '63 سنة',
              ),

              const SizedBox(height: 10),

              const _ProfileInfo(
                icon: Icons.language_rounded,
                title: 'اللغة',
                value: 'العربية',
              ),

              const SizedBox(height: 10),

              const _ProfileInfo(
                icon: Icons.email_outlined,
                title: 'البريد الإلكتروني',
                value: 'patient@neurobridge.com',
              ),

              const SizedBox(height: 25),

              const PatientSectionTitle(
                title: 'الحساب والرعاية',
              ),

              const SizedBox(height: 12),

              NeuroCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientFamilyScreen(),
                    ),
                  );
                },
                child: const _MenuRow(
                  icon: Icons.family_restroom_rounded,
                  title: 'أفراد العائلة',
                  subtitle: '3 أفراد مرتبطين',
                ),
              ),

              const SizedBox(height: 10),

              const NeuroCard(
                child: _MenuRow(
                  icon: Icons.medical_services_outlined,
                  title: 'فريق الرعاية',
                  subtitle: '2 مختصين',
                ),
              ),

              const SizedBox(height: 10),

              NeuroCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AccessibilityScreen(),
                    ),
                  );
                },
                child: const _MenuRow(
                  icon: Icons.accessibility_new_rounded,
                  title: 'سهولة الاستخدام',
                  subtitle:
                      'الخط، الحركة، الصوت وحجم الأزرار',
                ),
              ),

              const SizedBox(height: 10),

              const NeuroCard(
                child: _MenuRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'إعدادات الخصوصية',
                  subtitle:
                      'تحكم في المعلومات التي تتم مشاركتها',
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'سيتم فتح تعديل الملف الشخصي لاحقًا.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text(
                    'تعديل المعلومات',
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

class _ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB87585),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF89736F),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F3C38),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9EF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB87585),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF89736F),
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: Color(0xFFB4A1A5),
        ),
      ],
    );
  }
}