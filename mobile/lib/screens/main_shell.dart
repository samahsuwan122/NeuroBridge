import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'patient/patient_home_screen.dart';
import 'patient/exercises_screen.dart';
import 'patient/progress_screen.dart';
import 'patient/patient_profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const Color _rose = AppColors.secondaryDark;

  final List<Widget> _pages = const [
    PatientHomeScreen(),
    ExercisesScreen(),
    ProgressScreen(),
    PatientProfileScreen(),
  ];

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
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.secondarySoft,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
