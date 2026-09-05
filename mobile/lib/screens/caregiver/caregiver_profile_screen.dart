import 'package:flutter/material.dart';

import '../../core/services/caregiver_features_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/caregiver_ui.dart';
import '../login_screen.dart';
import 'caregiver_alerts_screen.dart';
import 'family_permissions_screen.dart';
import 'patient_switcher_screen.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() =>
      _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  bool _loading = true;
  bool _loggingOut = false;
  String? _error;
  Map<String, dynamic> _caregiver = {};

  String get _name {
    final value = _caregiver['full_name']?.toString().trim() ?? '';
    return value.isEmpty ? 'حساب المرافق' : value;
  }

  String get _email => _caregiver['email']?.toString().trim() ?? '';
  String get _phone => _caregiver['phone']?.toString().trim() ?? '';
  String get _relationship {
    final value = _caregiver['relationship']?.toString().trim() ?? '';
    return value.isEmpty ? 'مرافق' : value;
  }

  String get _imageUrl =>
      _caregiver['profile_image']?.toString().trim() ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await CaregiverFeaturesService.get('profile');
      final value = result['caregiver'];
      if (value is! Map) throw Exception('بيانات الحساب غير صحيحة');

      if (mounted) {
        setState(() {
          _caregiver = Map<String, dynamic>.from(value);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          title: const Text('تسجيل الخروج', textAlign: TextAlign.center),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);

    await ProfileService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _profileAvatar() {
    if (_imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFFF1E7D8),
        child: Icon(
          Icons.person_rounded,
          size: 53,
          color: CaregiverColors.rose,
        ),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFFF1E7D8),
      backgroundImage: NetworkImage(_imageUrl),
      onBackgroundImageError: (_, __) {},
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
              Row(
                children: [
                  const Expanded(child: CaregiverHeader(title: 'حسابي')),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: _loading ? null : _loadProfile,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: CaregiverCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 45,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 10),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 20),
                _profileAvatar(),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: CaregiverColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_relationship • حساب مرافق',
                  style: const TextStyle(color: CaregiverColors.rose),
                ),
                const SizedBox(height: 25),
                CaregiverCard(
                  child: Column(
                    children: [
                      if (_email.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: CaregiverColors.rose,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _email,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                      if (_email.isNotEmpty && _phone.isNotEmpty)
                        const Divider(height: 24),
                      if (_phone.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: CaregiverColors.rose,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _phone,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientSwitcherScreen(),
                      ),
                    );
                    if (mounted) _loadProfile();
                  },
                ),
                const SizedBox(height: 10),
                CaregiverMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'الإشعارات',
                  subtitle: 'إدارة تنبيهات المريض',
                  color: CaregiverColors.gold,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverAlertsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CaregiverMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'الخصوصية والصلاحيات',
                  subtitle: 'معرفة البيانات التي سمح المريض بمشاركتها',
                  color: CaregiverColors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyPermissionsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    onPressed: _loggingOut ? null : _confirmLogout,
                    icon: _loggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: Text(
                      _loggingOut ? 'جارٍ تسجيل الخروج...' : 'تسجيل الخروج',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
