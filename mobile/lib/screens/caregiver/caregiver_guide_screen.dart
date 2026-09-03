import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class CaregiverGuideScreen extends StatelessWidget {
  const CaregiverGuideScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sections = [
      [
        'كيف أشجع دون ضغط؟',
        'استخدم كلمات داعمة وركّز على الاستمرار والمحاولة بدل الدرجات أو المقارنة.'
      ],
      [
        'كيف أساعد في التمرين؟',
        'قدّم التعليمات عند الحاجة، لكن اترك للمريض مساحة كافية للمحاولة بشكل مستقل.'
      ],
      [
        'متى أتركه يعتمد على نفسه؟',
        'إذا كان قادرًا على إكمال المهمة بأمان، امنحه الوقت بدل التدخل مباشرة.'
      ],
      [
        'كيف أستخدم ألبوم الذكريات؟',
        'اختر ذكريات مريحة وإيجابية وأضف صورًا وأسماءً ووصفًا بسيطًا.'
      ],
      [
        'كيف أحافظ على الخصوصية؟',
        'اطلع فقط على المعلومات التي سمح المريض بمشاركتها ولا تشاركها مع الآخرين دون موافقته.'
      ],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'دليل المرافق',
                subtitle: 'أفكار بسيطة لتقديم دعم هادئ ومحترم.',
              ),
              const SizedBox(height: 25),
              ...sections.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: CaregiverCard(
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(
                        item[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: CaregiverColors.brown,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      children: [
                        Text(
                          item[1],
                          style: const TextStyle(
                            height: 1.7,
                            color: CaregiverColors.muted,
                          ),
                        ),
                      ],
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
