import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'memory_album_screen.dart';

class MemoryTreeScreen extends StatelessWidget {
  const MemoryTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
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
                      'شجرة الذاكرة',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'شجرتك تنمو مع كل خطوة جميلة في رحلتك 🌿',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 300,
                height: 360,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6EF),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFE4D8C8),
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 40,
                      child: Icon(
                        Icons.park_rounded,
                        size: 230,
                        color: Color(0xFF89A986),
                      ),
                    ),
                    Positioned(
                      top: 65,
                      left: 80,
                      child: _MemoryLeaf(
                        icon: '❤️',
                      ),
                    ),
                    Positioned(
                      top: 115,
                      right: 73,
                      child: _MemoryLeaf(
                        icon: '🌷',
                      ),
                    ),
                    Positioned(
                      top: 170,
                      left: 90,
                      child: _MemoryLeaf(
                        icon: '📷',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const NeuroCard(
                color: Color(0xFFEAF4ED),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      color: Color(0xFF71947A),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'أضفت 18 ورقة جديدة إلى شجرتك هذا الشهر.',
                        style: TextStyle(
                          color: Color(0xFF617265),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3528),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MemoryAlbumScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: const Text(
                    'فتح ألبوم الذكريات',
                    style: TextStyle(
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

class _MemoryLeaf extends StatelessWidget {
  final String icon;

  const _MemoryLeaf({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .07,
            ),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        icon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
