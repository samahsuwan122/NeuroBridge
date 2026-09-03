import 'package:flutter/material.dart';

import '../../core/services/privacy_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool shareProgress = true;
  bool shareMood = false;
  bool shareAppointments = true;
  bool allowEncouragement = true;
  bool loading = true;
  bool saving = false;

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;
  static const muted = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _asBool(dynamic value) {
    return value == true || value == 1 || value?.toString() == '1';
  }

  Future<void> _load() async {
    try {
      final privacy = await PrivacyService.load();
      if (!mounted) return;
      setState(() {
        shareProgress = _asBool(privacy['share_progress']);
        shareMood = _asBool(privacy['share_mood']);
        shareAppointments = _asBool(privacy['share_appointments']);
        allowEncouragement = _asBool(privacy['allow_encouragement']);
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await PrivacyService.save(
        shareProgress: shareProgress,
        shareMood: shareMood,
        shareAppointments: shareAppointments,
        allowEncouragement: allowEncouragement,
      );
      if (!mounted) return;
      _message('تم حفظ إعدادات الخصوصية ✓');
    } catch (error) {
      if (!mounted) return;
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'إعدادات الخصوصية',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded, color: rose),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'أنت تتحكم بالمعلومات التي يمكن مشاركتها مع أفراد العائلة وفريق الرعاية المرتبطين بحسابك.',
                style: TextStyle(height: 1.7, color: muted),
              ),
              const SizedBox(height: 24),
              _PrivacySwitch(
                icon: Icons.insights_rounded,
                title: 'مشاركة التقدّم',
                subtitle: 'السماح بعرض نتائج التمارين ونسبة التقدّم',
                value: shareProgress,
                onChanged: loading
                    ? null
                    : (value) => setState(() => shareProgress = value),
              ),
              const SizedBox(height: 10),
              _PrivacySwitch(
                icon: Icons.favorite_outline_rounded,
                title: 'مشاركة الحالة المزاجية',
                subtitle: 'السماح بعرض إجابات تسجيل الحالة اليومية',
                value: shareMood,
                onChanged: loading
                    ? null
                    : (value) => setState(() => shareMood = value),
              ),
              const SizedBox(height: 10),
              _PrivacySwitch(
                icon: Icons.calendar_month_outlined,
                title: 'مشاركة المواعيد',
                subtitle: 'السماح بعرض المواعيد وتفاصيلها',
                value: shareAppointments,
                onChanged: loading
                    ? null
                    : (value) => setState(() => shareAppointments = value),
              ),
              const SizedBox(height: 10),
              _PrivacySwitch(
                icon: Icons.volunteer_activism_outlined,
                title: 'السماح برسائل التشجيع',
                subtitle: 'استقبال رسائل تشجيع من الأشخاص المرتبطين',
                value: allowEncouragement,
                onChanged: loading
                    ? null
                    : (value) => setState(() => allowEncouragement = value),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E7D8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: rose),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لن تغيّر هذه الخيارات بيانات حسابك الأساسية، وهي تطبّق فقط على الأشخاص المرتبطين بحسابك.',
                        style: TextStyle(height: 1.6, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: loading || saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: rose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: saving
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    saving ? 'جارٍ الحفظ...' : 'حفظ إعدادات الخصوصية',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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

class _PrivacySwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PrivacySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E7D8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
