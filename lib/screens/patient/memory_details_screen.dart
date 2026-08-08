import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class MemoryDetailsScreen extends StatefulWidget {
  final String title;
  final String date;
  final String emoji;
  final String description;

  const MemoryDetailsScreen({
    super.key,
    required this.title,
    required this.date,
    required this.emoji,
    required this.description,
  });

  @override
  State<MemoryDetailsScreen> createState() =>
      _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState
    extends State<MemoryDetailsScreen> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () =>
                    Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9EF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  widget.emoji,
                  style: const TextStyle(
                    fontSize: 120,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.date,
                style: const TextStyle(
                  color: Color(0xFF89736F),
                ),
              ),

              const SizedBox(height: 20),

              NeuroCard(
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    height: 1.8,
                    color: Color(0xFF6E5955),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const NeuroCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      color: Color(0xFFB87585),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'الأشخاص في الذكرى: سامي، ليلى، أحمد',
                        style: TextStyle(
                          color: Color(0xFF6E5955),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              NeuroCard(
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تشغيل الرسالة الصوتية تجريبيًا 🎧',
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      size: 38,
                      color: Color(0xFFB87585),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'استمع إلى رسالة العائلة',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F3C38),
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
                    backgroundColor: liked
                        ? const Color(0xFF71947A)
                        : const Color(0xFFB87585),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      liked = true;
                    });
                  },
                  icon: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons
                            .favorite_outline_rounded,
                  ),
                  label: Text(
                    liked
                        ? 'سعدتني هذه الذكرى ❤️'
                        : 'هذه الذكرى أسعدتني',
                    style: const TextStyle(
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