import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'role_selection_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState
    extends State<LanguageScreen> {
  String selected = 'ar';

  final languages = const [
    ('ar', 'العربية', 'العربية'),
    ('en', 'English', 'English'),
    ('fr', 'Français', 'Français'),
    ('es', 'Español', 'Español'),
    ('de', 'Deutsch', 'Deutsch'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Image.asset(
                  'assets/images/neurobridge_logo.png',
                  width: 90,
                  height: 90,
                ),

                const SizedBox(height: 18),

                const Text(
                  'اختر لغتك',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F3C38),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'يمكنك تغيير اللغة لاحقًا من أي وقت',
                  style: TextStyle(
                    color: Color(0xFF89736F),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = languages[index];
                      final isSelected =
                          selected == item.$1;

                      return InkWell(
                        borderRadius:
                            BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            selected = item.$1;
                          });

                          // هنا لاحقًا نربط الترجمة
                          // حتى تتغير لغة التطبيق بالكامل فورًا
                        },
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 250),
                          padding:
                              const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFEDF2)
                                : Colors.white
                                    .withValues(alpha: .78),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB87585)
                                  : const Color(0xFFECDDE1),
                              width:
                                  isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFF4F6,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    13,
                                  ),
                                ),
                                child: Text(
                                  item.$1.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w900,
                                    color:
                                        Color(0xFF9D6170),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Text(
                                  item.$2,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        Color(0xFF4F3C38),
                                  ),
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color:
                                      Color(0xFFB87585),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFB87585),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoleSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'متابعة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}