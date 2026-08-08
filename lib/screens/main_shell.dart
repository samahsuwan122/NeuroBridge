import 'package:flutter/material.dart';

import 'patient/patient_home_screen.dart';
import 'patient/exercises_screen.dart';
import 'patient/progress_screen.dart';
import 'patient/patient_profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {
  int _currentIndex = 0;

  static const Color _rose =
      Color(0xFFB87585);

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
        backgroundColor:
            const Color(0xFFFFF8FA),

        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  -4,
                ),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              height: 72,
              elevation: 0,
              backgroundColor:
                  Colors.white,
              indicatorColor:
                  const Color(
                0xFFFFE7ED,
              ),
              selectedIndex:
                  _currentIndex,

              labelBehavior:
                  NavigationDestinationLabelBehavior
                      .alwaysShow,

              onDestinationSelected:
                  (index) {
                setState(() {
                  _currentIndex =
                      index;
                });
              },

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
                    Icons
                        .psychology_alt_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons
                        .psychology_alt_rounded,
                    color: _rose,
                  ),
                  label: 'التمارين',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons
                        .insights_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.insights_rounded,
                    color: _rose,
                  ),
                  label: 'التقدّم',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons
                        .person_outline_rounded,
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