import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

import 'caregiver/caregiver_home_screen.dart';

import 'patient/patient_home_screen.dart';
import 'patient/exercises_screen.dart';
import 'patient/progress_screen.dart';
import 'patient/patient_profile_screen.dart';

class MainShell extends StatelessWidget {
  final Map<String, dynamic> user;

  const MainShell({
    super.key,
    required this.user,
  });

  String _readRole() {
    return (user['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final String role = _readRole();

    /*
     * حساب العائلة قد يرجع من قاعدة البيانات:
     * caregiver أو family
     */
    if (role == 'caregiver' || role == 'family') {
      return const CaregiverHomeScreen();
    }

    /*
     * حساب المريض.
     */
    if (role == 'patient') {
      return PatientMainShell(user: user);
    }

    /*
     * في حال لم يُرجع الخادم دورًا صحيحًا،
     * نظهر رسالة واضحة بدل الصفحة البيضاء.
     */
    return UnsupportedAccountRoleScreen(
      role: role,
    );
  }
}

class PatientMainShell extends StatefulWidget {
  final Map<String, dynamic> user;

  const PatientMainShell({
    super.key,
    required this.user,
  });

  @override
  State<PatientMainShell> createState() {
    return _PatientMainShellState();
  }
}

class _PatientMainShellState extends State<PatientMainShell> {
  int _currentIndex = 0;
  int _refreshToken = 0;

  static const Color _rose =
      AppColors.secondaryDark;

  int _readUserId(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  void _openHome() {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex = 0;
      _refreshToken++;
    });
  }

  List<Widget> get _pages {
    final Map<String, dynamic> user =
        widget.user;

    return [
      PatientHomeScreen(
        userId: _readUserId(user['id']),
        fullName:
            user['full_name']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        phone: user['phone']?.toString() ?? '',
        role: user['role']?.toString() ?? '',
        refreshToken: _refreshToken,
      ),
      ExercisesScreen(
        onBack: _openHome,
      ),
      ProgressScreen(
        refreshToken: _refreshToken,
        onBack: _openHome,
      ),
      PatientProfileScreen(
        userId: _readUserId(user['id']),
        fullName:
            user['full_name']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        phone: user['phone']?.toString() ?? '',
        role: user['role']?.toString() ?? '',
        onBack: _openHome,
      ),
    ];
  }

  void _changePage(int index) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex = index;
      _refreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(23),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              backgroundColor:
                  AppColors.surface,
              indicatorColor:
                  AppColors.secondarySoft,
              selectedIndex: _currentIndex,
              onDestinationSelected:
                  _changePage,
              labelBehavior:
                  NavigationDestinationLabelBehavior
                      .alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: _rose,
                  ),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.psychology_alt_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.psychology_alt_rounded,
                    color: _rose,
                  ),
                  label: 'التمارين',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.insights_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.insights_rounded,
                    color: _rose,
                  ),
                  label: 'التقدّم',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline_rounded,
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: _rose,
                  ),
                  label: 'حسابي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UnsupportedAccountRoleScreen
    extends StatelessWidget {
  final String role;

  const UnsupportedAccountRoleScreen({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final String displayedRole =
        role.isEmpty ? 'غير موجود' : role;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Container(
              width: 420,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.manage_accounts_outlined,
                    size: 58,
                    color: AppColors.secondaryDark,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'نوع الحساب غير مدعوم',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الدور الذي أعاده الخادم: '
                    '$displayedRole',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يجب أن يكون الدور patient '
                    'للمريض أو caregiver للعائلة.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}