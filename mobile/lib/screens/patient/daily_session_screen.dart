import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'word_recall_screen.dart';

class DailySessionScreen extends StatelessWidget {
  const DailySessionScreen({super.key});

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
                      Icons.close_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'جلسة اليوم',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'التمرين 2 من 4',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6D513F),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: .5,
                  minHeight: 9,
                  backgroundColor: Color(0xFFDDCFBD),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF4A3528),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              NeuroCard(
                color: const Color(0xFFF1E7D8),
                child: Column(
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        size: 48,
                        color: Color(0xFF4A3528),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'تذكّر الكلمات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'خذ وقتك. لا يوجد داعٍ للاستعجال.',
                      style: TextStyle(
                        color: Color(0xFF76665A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
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
                        builder: (_) => const WordRecallScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'ابدأ التمرين',
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
