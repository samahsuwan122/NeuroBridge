import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'ai_assistant_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() =>
      _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const Color _rose = Color(0xFFB87585);
  static const Color _roseDark = Color(0xFF95606D);
  static const Color _brown = Color(0xFF4F3C38);
  static const Color _muted = Color(0xFF89736F);
  static const Color _border = Color(0xFFEAD8DD);

  final TextEditingController _searchController =
      TextEditingController();

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      question: 'كيف أبدأ تمرينًا جديدًا؟',
      answer:
          'انتقل إلى قسم التمارين من شريط التنقل، اختر التمرين المناسب لك، ثم اضغط على "ابدأ الآن".',
    ),
    _FaqItem(
      question: 'كيف أتابع تقدّمي؟',
      answer:
          'يمكنك فتح صفحة "تقدّمي" لمشاهدة الجلسات المكتملة، مدة التدريب والإنجازات الأسبوعية.',
    ),
    _FaqItem(
      question: 'هل تستطيع عائلتي متابعة تقدّمي؟',
      answer:
          'نعم، بعد ربط حساب أحد أفراد العائلة بحسابك سيتمكن من مشاهدة المعلومات المسموح بمشاركتها وتقديم الدعم لك.',
    ),
    _FaqItem(
      question: 'هل NeuroBridge يشخّص حالتي؟',
      answer:
          'لا. NeuroBridge منصة لدعم التأهيل والمتابعة ولا يقدم تشخيصًا طبيًا ولا يستبدل الطبيب أو المختص.',
    ),
    _FaqItem(
      question: 'هل يمكنني تغيير اللغة؟',
      answer:
          'نعم، يمكنك تغيير لغة التطبيق من زر اللغة أو من الإعدادات لاحقًا.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFaqs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * .78,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFAFB),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2CDD2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        color: _rose,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'الأسئلة الشائعة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _brown,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    itemCount: _faqs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final faq = _faqs[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _border,
                          ),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          iconColor: _rose,
                          collapsedIconColor: _muted,
                          title: Text(
                            faq.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _brown,
                            ),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            18,
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                faq.answer,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.7,
                                  color: _muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTutorials() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * .72,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFAFB),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2CDD2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'فيديوهات تعليمية قصيرة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _brown,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'تعرف على أهم ميزات NeuroBridge في دقائق.',
                  style: TextStyle(
                    color: _muted,
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: ListView(
                    children: const [
                      _VideoCard(
                        title: 'كيف تبدأ أول تمرين؟',
                        duration: '1:20',
                        icon: Icons.psychology_alt_rounded,
                      ),
                      SizedBox(height: 12),
                      _VideoCard(
                        title: 'كيف تتابع تقدمك؟',
                        duration: '1:05',
                        icon: Icons.insights_rounded,
                      ),
                      SizedBox(height: 12),
                      _VideoCard(
                        title: 'ربط حساب العائلة',
                        duration: '1:35',
                        icon: Icons.family_restroom_rounded,
                      ),
                      SizedBox(height: 12),
                      _VideoCard(
                        title: 'استخدام مساعد NeuroBridge AI',
                        duration: '0:55',
                        icon: Icons.auto_awesome_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportProblem() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAFB),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2CDD2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Row(
                    children: [
                      Icon(
                        Icons.bug_report_outlined,
                        color: _rose,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'الإبلاغ عن مشكلة',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: _brown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'صف المشكلة التي واجهتك بالتفصيل...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _rose,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _rose,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم تسجيل البلاغ تجريبيًا ✓',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text(
                        'إرسال البلاغ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContactSupport() {
    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFFFFFAFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            icon: const Icon(
              Icons.support_agent_rounded,
              size: 50,
              color: _rose,
            ),
            title: const Text(
              'التواصل مع الدعم',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'سيتم ربط هذه الصفحة بنظام الدعم عند تجهيز الـ Backend.\n\nيمكن لاحقًا إضافة البريد الإلكتروني، المحادثة المباشرة أو تذاكر الدعم.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.7,
                color: _muted,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _rose,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                35,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),

                      const SizedBox(height: 26),

                      const Text(
                        'كيف يمكننا مساعدتك؟ 🌷',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _brown,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'ابحث عن إجابة، تعرّف على التطبيق أو تحدث مع مساعد NeuroBridge الذكي.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: _muted,
                        ),
                      ),

                      const SizedBox(height: 22),

                      _buildSearchBar(),

                      const SizedBox(height: 24),

                      // AI HERO
                      _buildAiCard(),

                      const SizedBox(height: 28),

                      const Text(
                        'مركز المساعدة',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _brown,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _HelpTile(
                        icon: Icons.help_outline_rounded,
                        title: 'الأسئلة الشائعة',
                        subtitle:
                            'إجابات سريعة على أكثر الأسئلة شيوعًا',
                        color: const Color(0xFFB87585),
                        background:
                            const Color(0xFFFFE9EF),
                        onTap: _showFaqs,
                      ),

                      const SizedBox(height: 12),

                      _HelpTile(
                        icon: Icons.menu_book_rounded,
                        title: 'شرح استخدام التطبيق',
                        subtitle:
                            'تعرف على خطوات استخدام NeuroBridge',
                        color: const Color(0xFF7895A4),
                        background:
                            const Color(0xFFEAF2F5),
                        onTap: _showTutorials,
                      ),

                      const SizedBox(height: 12),

                      _HelpTile(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'فيديوهات تعليمية قصيرة',
                        subtitle:
                            'شروحات سريعة لأهم ميزات التطبيق',
                        color: const Color(0xFF9D7BB0),
                        background:
                            const Color(0xFFF3EAF7),
                        onTap: _showTutorials,
                      ),

                      const SizedBox(height: 12),

                      _HelpTile(
                        icon: Icons.support_agent_rounded,
                        title: 'التواصل مع الدعم',
                        subtitle:
                            'تحدث مع فريق المساعدة عند الحاجة',
                        color: const Color(0xFFC79A62),
                        background:
                            const Color(0xFFFFF2DF),
                        onTap: _showContactSupport,
                      ),

                      const SizedBox(height: 12),

                      _HelpTile(
                        icon: Icons.bug_report_outlined,
                        title: 'الإبلاغ عن مشكلة',
                        subtitle:
                            'أخبرنا عن أي مشكلة واجهتك',
                        color: const Color(0xFFC86D76),
                        background:
                            const Color(0xFFFFE9EB),
                        onTap: _showReportProblem,
                      ),

                      const SizedBox(height: 28),

                      _buildMedicalNotice(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .76),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: _brown,
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'مركز المساعدة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _brown,
            ),
          ),
        ),

        Container(
          width: 43,
          height: 43,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .76),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'ابحث عن سؤال أو ميزة...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _rose,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            if (_searchController.text.trim().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiAssistantScreen(
                    initialQuestion:
                        _searchController.text.trim(),
                  ),
                ),
              );
            }
          },
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: _rose,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: _rose,
            width: 1.5,
          ),
        ),
      ),
      onSubmitted: (value) {
        if (value.trim().isEmpty) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiAssistantScreen(
              initialQuestion: value.trim(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFE8EF),
            Color(0xFFFFF6F9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE2BEC8),
        ),
        boxShadow: [
          BoxShadow(
            color: _rose.withValues(alpha: .10),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 57,
                height: 57,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _rose,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'NeuroBridge AI',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _brown,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: _rose,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'مساعدك الذكي لفهم التطبيق والحصول على مساعدة سريعة.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          SizedBox(
            width: double.infinity,
            height: 53,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _rose,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AiAssistantScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
              ),
              label: const Text(
                'ابدأ المحادثة',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: _rose,
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'NeuroBridge ومساعده الذكي يدعمان التأهيل والمتابعة وتوضيح استخدام التطبيق، ولا يقدمان تشخيصًا طبيًا ولا يستبدلان الطبيب أو المختص.',
              style: TextStyle(
                fontSize: 12,
                height: 1.7,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFEAD8DD),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF89736F),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFFB29EA2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final IconData icon;

  const _VideoCard({
    required this.title,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAD8DD),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9EF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFB87585),
                ),
                const Positioned(
                  bottom: 4,
                  right: 5,
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 18,
                    color: Color(0xFF95606D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4F3C38),
              ),
            ),
          ),

          Text(
            duration,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF89736F),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}