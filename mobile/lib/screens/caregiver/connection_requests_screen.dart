import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class ConnectionRequestsScreen extends StatelessWidget {
  const ConnectionRequestsScreen({super.key});

  void _action(
    BuildContext context,
    String action,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action),
      ),
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
                title: 'طلبات الربط',
              ),
              const SizedBox(height: 25),
              CaregiverCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سامي أحمد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: CaregiverColors.brown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'العلاقة: ابنة',
                      style: TextStyle(
                        color: CaregiverColors.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'الصلاحيات المطلوبة:',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• النشاط العام\n'
                      '• التقدّم\n'
                      '• المواعيد\n'
                      '• التواصل',
                      style: TextStyle(
                        height: 1.7,
                        color: CaregiverColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: CaregiverColors.green,
                            ),
                            onPressed: () {
                              _action(
                                context,
                                'تم قبول الطلب تجريبيًا.',
                              );
                            },
                            child: const Text(
                              'قبول',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _action(
                                context,
                                'تم رفض الطلب تجريبيًا.',
                              );
                            },
                            child: const Text(
                              'رفض',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          _action(
                            context,
                            'تم منح صلاحية مؤقتة تجريبيًا.',
                          );
                        },
                        icon: const Icon(
                          Icons.timer_outlined,
                        ),
                        label: const Text(
                          'منح صلاحية مؤقتة',
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
  }
}
