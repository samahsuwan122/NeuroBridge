import 'package:flutter/material.dart';

import '../widgets/legal_page_layout.dart';

class MedicalDisclaimerScreen
    extends StatelessWidget {
  const MedicalDisclaimerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const LegalPageLayout(
      title: 'إخلاء المسؤولية الطبية',
      subtitle:
          'NeuroBridge منصة داعمة للتأهيل والمتابعة وليست أداة للتشخيص الطبي.',
      icon: Icons.health_and_safety_outlined,
      children: [
        LegalSection(
          title: 'ليس أداة تشخيص',
          text:
              'لا يقوم NeuroBridge بتشخيص الأمراض أو الحالات الصحية، ولا يجب تفسير نتائج التمارين أو مؤشرات التقدم على أنها تشخيص طبي.',
        ),
        LegalSection(
          title: 'لا يستبدل المختص',
          text:
              'لا يحل التطبيق محل الطبيب أو المعالج أو أي مختص صحي مؤهل، ويجب الرجوع إلى المختص عند الحاجة إلى تقييم أو قرار متعلق بالحالة الصحية.',
        ),
        LegalSection(
          title: 'التمارين والأنشطة',
          text:
              'التمارين داخل المنصة مصممة لدعم عملية التأهيل والمتابعة. يجب اتباع توصيات فريق الرعاية عند وجود تعليمات خاصة بالمستخدم.',
        ),
        LegalSection(
          title: 'الحالات الطارئة',
          text:
              'لا ينبغي استخدام التطبيق للحصول على مساعدة في الحالات الطبية الطارئة. في مثل هذه الحالات يجب استخدام خدمات الطوارئ المناسبة مباشرة.',
        ),
      ],
    );
  }
}