import 'package:flutter/material.dart';

import '../../core/services/profile_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import '../login_screen.dart';
import 'accessibility_screen.dart';
import 'edit_profile_screen.dart';
import 'patient_family_screen.dart';
import 'privacy_settings_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final VoidCallback? onBack;

  const PatientProfileScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.onBack,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late int userId;
  late String fullName;
  late String email;
  late String phone;
  late String role;
  String? birthDate;
  String preferredLanguage = 'ar';
  int familyCount = 0;
  int careTeamCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fullName = widget.fullName;
    email = widget.email;
    phone = widget.phone;
    role = widget.role;
    _loadProfile();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _loadProfile() async {
    try {
      final user = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() {
        userId = _asInt(user['id']);
        fullName = user['full_name']?.toString() ?? '';
        email = user['email']?.toString() ?? '';
        phone = user['phone']?.toString() ?? '';
        role = user['role']?.toString() ?? '';
        birthDate = user['birth_date']?.toString();
        preferredLanguage =
            user['preferred_language']?.toString() ?? 'ar';
        familyCount = _asInt(user['family_count']);
        careTeamCount = _asInt(user['care_team_count']);
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String get ageTitle {
    final date = DateTime.tryParse(birthDate ?? '');
    if (date == null) return 'غير محدد';
    final now = DateTime.now();
    var age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return '$age سنة';
  }

  String get languageTitle {
    const languages = {
      'ar': 'العربية',
      'en': 'English',
      'fr': 'Français',
      'es': 'Español',
      'de': 'Deutsch',
    };
    return languages[preferredLanguage] ?? 'العربية';
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: {
            'id': userId,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'role': role,
            'birth_date': birthDate,
            'preferred_language': preferredLanguage,
          },
        ),
      ),
    );

    if (!mounted || updated == null) return;
    await _loadProfile();
  }

  String get roleTitle {
    if (role == 'patient') {
      return 'حساب مريض';
    }

    if (role == 'caregiver') {
      return 'حساب مرافق / فرد من العائلة';
    }

    return 'حساب مستخدم';
  }

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        title: const Text(
          'تسجيل الخروج',
          textAlign: TextAlign.center,
        ),
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
    await ProfileService.logout();
    if (!context.mounted) return;
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
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading) const LinearProgressIndicator(minHeight: 2),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
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
                        color: Color(0xFFF1E7D8),
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
             Center(
  child: Text(
    fullName.isEmpty ? 'مستخدم NeuroBridge' : fullName,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
              ),
              const SizedBox(height: 4),
             Center(
  child: Text(
    roleTitle,
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
             
           _ProfileInfo(
  icon: Icons.email_outlined,
  title: 'البريد الإلكتروني',
  value: email.isEmpty ? 'غير محدد' : email,
),
const SizedBox(height: 10),
_ProfileInfo(
  icon: Icons.phone_outlined,
  title: 'رقم الهاتف',
  value: phone.isEmpty ? 'غير محدد' : phone,
),
const SizedBox(height: 10),
_ProfileInfo(
  icon: Icons.badge_outlined,
  title: 'نوع الحساب',
  value: roleTitle,
),
const SizedBox(height: 10),
_ProfileInfo(
  icon: Icons.cake_outlined,
  title: 'العمر',
  value: ageTitle,
),
const SizedBox(height: 10),
_ProfileInfo(
  icon: Icons.language_rounded,
  title: 'اللغة',
  value: languageTitle,
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
                      builder: (_) => const PatientFamilyScreen(),
                    ),
                  );
                },
                child: _MenuRow(
                  icon: Icons.family_restroom_rounded,
                  title: 'أفراد العائلة',
                  subtitle: '$familyCount أفراد مرتبطين',
                ),
              ),
              const SizedBox(height: 10),
              NeuroCard(
                child: _MenuRow(
                  icon: Icons.medical_services_outlined,
                  title: 'فريق الرعاية',
                  subtitle: '$careTeamCount مختصين',
                ),
              ),
              const SizedBox(height: 10),
              NeuroCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccessibilityScreen(),
                    ),
                  );
                },
                child: const _MenuRow(
                  icon: Icons.accessibility_new_rounded,
                  title: 'سهولة الاستخدام',
                  subtitle: 'الخط، الحركة، الصوت وحجم الأزرار',
                ),
              ),
              const SizedBox(height: 10),
              NeuroCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacySettingsScreen(),
                    ),
                  );
                },
                child: const _MenuRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'إعدادات الخصوصية',
                  subtitle: 'تحكم في المعلومات التي تتم مشاركتها',
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _openEditProfile,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text(
                    'تعديل المعلومات',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
            color: const Color(0xFF4A3528),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF76665A),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF35251C),
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
            color: const Color(0xFFF1E7D8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A3528),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF35251C),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF76665A),
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
