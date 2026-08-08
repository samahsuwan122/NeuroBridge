import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';
import 'add_memory_screen.dart';

class FamilyMemoryAlbumScreen extends StatelessWidget {
  const FamilyMemoryAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memories = [
      ['🏞️', 'رحلة العائلة', '2025'],
      ['🎂', 'عيد الميلاد', '2025'],
      ['🌊', 'يوم البحر', '2024'],
      ['👨‍👩‍👧', 'زيارة الأحفاد', '2024'],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton:
            FloatingActionButton.extended(
          backgroundColor:
              CaregiverColors.rose,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddMemoryScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'إضافة ذكرى',
          ),
        ),
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'إدارة الذكريات',
              ),

              const SizedBox(height: 25),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: memories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .85,
                ),
                itemBuilder: (_, index) {
                  final memory =
                      memories[index];

                  return CaregiverCard(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          memory[0],
                          style: const TextStyle(
                            fontSize: 55,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          memory[1],
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        Text(
                          memory[2],
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                CaregiverColors.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}