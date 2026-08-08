import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'language_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      icon: Icons.psychology_alt_rounded,
      title: 'تمارين معرفية يومية',
      description:
          'تمارين بسيطة وممتعة تساعد على تنشيط الذاكرة، التركيز والمهارات المعرفية خطوة بخطوة.',
    ),
    _OnboardingItem(
      icon: Icons.insights_rounded,
      title: 'تابع تقدّمك',
      description:
          'شاهد تطورك اليومي والأسبوعي، إنجازاتك واستمراريتك بطريقة واضحة ومشجعة.',
    ),
    _OnboardingItem(
      icon: Icons.family_restroom_rounded,
      title: 'ابقَ قريبًا ممن يدعمك',
      description:
          'تواصل بشكل آمن مع أفراد العائلة وفريق الرعاية وشارك معهم رحلتك وتقدمك.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LanguageScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/neurobridge_logo.png',
                      width: 42,
                      height: 42,
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'NeuroBridge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF59423C),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LanguageScreen(),
                          ),
                        );
                      },
                      child: const Text('تخطي'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    final page = _pages[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: .78),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18A56D79),
                                  blurRadius: 35,
                                  offset: Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 80,
                              color:
                                  const Color(0xFFB87585),
                            ),
                          ),

                          const SizedBox(height: 45),

                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4F3C38),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.8,
                              fontSize: 16,
                              color: Color(0xFF89736F),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) {
                    final selected =
                        index == _currentPage;

                    return AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: selected ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFB87585)
                            : const Color(0xFFE4CDD3),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  28,
                ),
                child: SizedBox(
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
                    onPressed: _next,
                    child: Text(
                      _currentPage ==
                              _pages.length - 1
                          ? 'ابدأ الآن'
                          : 'التالي',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
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

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}