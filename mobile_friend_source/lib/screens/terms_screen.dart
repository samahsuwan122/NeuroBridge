import 'package:flutter/material.dart';

import '../widgets/legal_page_layout.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageLayout(
      title: 'الشروط والأحكام',
      subtitle:
          'يرجى قراءة شروط استخدام NeuroBridge بعناية.',
      icon: Icons.description_outlined,
      children: [
        LegalSection(
          title: 'استخدام المنصة',
          text:
              'يهدف NeuroBridge إلى دعم تجربة التأهيل والمتابعة وتنظيم الأنشطة والتمارين والتواصل بين المستخدمين والأطراف المرتبطة بالرعاية.',
        ),
        LegalSection(
          title: 'الحساب',
          text:
              'يتحمل المستخدم مسؤولية الحفاظ على سرية بيانات الدخول وعدم مشاركتها مع الآخرين.',
        ),
        LegalSection(
          title: 'الاستخدام المناسب',
          text:
              'يجب استخدام المنصة بطريقة قانونية ومسؤولة، وعدم إساءة استخدام أدوات التواصل أو المحتوى.',
        ),
        LegalSection(
          title: 'المعلومات الصحية',
          text:
              'المحتوى المعروض داخل التطبيق لأغراض الدعم والمتابعة ولا ينبغي الاعتماد عليه كبديل عن التقييم أو الرعاية الطبية المتخصصة.',
        ),
      ],
    );
  }
}