import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class FamilyAppointmentsScreen extends StatelessWidget {
  const FamilyAppointmentsScreen({
    super.key,
  });

  void _demo(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
              const CaregiverHeader(
                title: 'مواعيد سامي',
              ),
              const SizedBox(height: 25),
              CaregiverCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جلسة متابعة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: CaregiverColors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الخميس 6 أغسطس • 10:00 صباحًا',
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'د. أحمد خالد • NeuroCare',
                      style: TextStyle(
                        color: CaregiverColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _demo(
                              context,
                              'تم إرسال تذكير للمريض تجريبيًا.',
                            );
                          },
                          child: const Text(
                            'تذكير المريض',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _demo(
                              context,
                              'سيتم ربط التقويم لاحقًا.',
                            );
                          },
                          child: const Text(
                            'إضافة للتقويم',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _demo(
                              context,
                              'سيتم فتح موقع العيادة لاحقًا.',
                            );
                          },
                          child: const Text(
                            'الموقع',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _demo(
                              context,
                              'تم تسجيل طلب تعديل تجريبيًا.',
                            );
                          },
                          child: const Text(
                            'طلب تعديل',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
