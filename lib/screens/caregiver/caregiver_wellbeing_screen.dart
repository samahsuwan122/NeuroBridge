import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class CaregiverWellbeingScreen
    extends StatefulWidget {
  const CaregiverWellbeingScreen({
    super.key,
  });

  @override
  State<CaregiverWellbeingScreen>
      createState() =>
          _CaregiverWellbeingScreenState();
}

class _CaregiverWellbeingScreenState
    extends State<CaregiverWellbeingScreen> {
  String? mood;
  bool quietNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'رفاه المرافق',
                subtitle:
                    'العناية بنفسك جزء مهم من قدرتك على تقديم الدعم.',
              ),

              const SizedBox(height: 25),

              const Text(
                'كيف تشعر اليوم؟',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  '😊 جيد',
                  '🙂 بخير',
                  '😴 متعب',
                  '😟 مضغوط',
                ].map((item) {
                  return ChoiceChip(
                    selected: mood == item,
                    label: Text(item),
                    onSelected: (_) {
                      setState(() {
                        mood = item;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              const CaregiverCard(
                color: Color(0xFFEAF4ED),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تذكير لطيف 🌿',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'خذ استراحة قصيرة عندما تحتاجها. ليس عليك متابعة كل شيء في كل لحظة.',
                      style: TextStyle(
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              CaregiverCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor:
                      CaregiverColors.rose,
                  value: quietNotifications,
                  title: const Text(
                    'تقليل الإشعارات',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'عرض التنبيهات المهمة فقط.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      quietNotifications =
                          value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 15),

              CaregiverMenuTile(
                icon: Icons.support_outlined,
                title: 'مصادر دعم',
                subtitle:
                    'محتوى تعليمي ومصادر للمرافقين',
                color: CaregiverColors.blue,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}