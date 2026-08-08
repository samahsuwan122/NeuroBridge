import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'memory_details_screen.dart';

class MemoryAlbumScreen extends StatelessWidget {
  const MemoryAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memories = const [
      ('رحلة العائلة', 'صيف 2025', '🏞️', 'يوم جميل مع العائلة'),
      ('عيد الميلاد', 'يناير 2025', '🎂', 'احتفال مميز في المنزل'),
      ('يوم على البحر', 'أغسطس 2024', '🌊', 'قضينا وقتًا سعيدًا معًا'),
      ('زيارة الأحفاد', 'يونيو 2024', '👨‍👩‍👧', 'زيارة مليئة بالضحك'),
    ];

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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'ألبوم الذكريات',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'ذكريات وصور أضافتها العائلة لك ❤️',
                style: TextStyle(
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: memories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 13,
                  crossAxisSpacing: 13,
                  childAspectRatio: .78,
                ),
                itemBuilder: (_, index) {
                  final memory = memories[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemoryDetailsScreen(
                              title: memory.$1,
                              date: memory.$2,
                              emoji: memory.$3,
                              description: memory.$4,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE4D8C8,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5ECE0),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      21,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  memory.$3,
                                  style: const TextStyle(
                                    fontSize: 65,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                13,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memory.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(
                                        0xFF35251C,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    memory.$2,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(
                                        0xFF76665A,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
