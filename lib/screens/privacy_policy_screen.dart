import 'package:flutter/material.dart';

import '../widgets/legal_page_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageLayout(
      title: 'سياسة الخصوصية',
      subtitle:
          'خصوصيتك مهمة لنا، ونعرض هنا بصورة مبسطة كيفية التعامل مع بياناتك.',
      icon: Icons.privacy_tip_outlined,
      children: [
        LegalSection(
          title: 'البيانات التي قد نجمعها',
          text:
              'قد تتضمن البيانات الاسم، البريد الإلكتروني، رقم الهاتف، نوع الحساب، بيانات الاستخدام والتقدم التي يختار المستخدم مشاركتها.',
        ),
        LegalSection(
          title: 'سبب استخدام البيانات',
          text:
              'تُستخدم البيانات لتشغيل الحساب، توفير تجربة مخصصة، متابعة التقدم وتحسين وظائف المنصة.',
        ),
        LegalSection(
          title: 'مشاركة البيانات',
          text:
              'لا ينبغي مشاركة البيانات الشخصية مع أطراف غير مخولة. عند تطوير النظام الخلفي سيتم تطبيق صلاحيات وصول مناسبة بحسب نوع الحساب.',
        ),
        LegalSection(
          title: 'الأمان',
          text:
              'عند ربط النظام بالخادم سيتم استخدام إجراءات تقنية مناسبة لحماية بيانات الحساب أثناء النقل والتخزين.',
        ),
      ],
    );
  }
}