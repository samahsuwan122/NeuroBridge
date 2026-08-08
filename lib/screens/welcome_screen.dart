import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AppLanguage _language = AppLanguage.arabic;
String get _currentFont {
  if (_language == AppLanguage.arabic) {
    return 'ArabicElegant';
  }

  return 'EnglishScript';
}
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const Color _background = Color(0xFFFFF9FB);
  static const Color _pinkVeryLight = Color(0xFFFFEEF3);
  static const Color _pinkLight = Color(0xFFF9DDE5);
  static const Color _rose = Color(0xFFB87585);
  static const Color _roseDark = Color(0xFF95606D);
  static const Color _brown = Color(0xFF513D39);
  static const Color _muted = Color(0xFF8E7975);
  static const Color _border = Color(0xFFEEDCE1);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_language);

    return Directionality(
  textDirection: _language.direction,
  child: Theme(
    data: Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
        fontFamily: _currentFont,
      ),
      primaryTextTheme:
          Theme.of(context).primaryTextTheme.apply(
        fontFamily: _currentFont,
      ),
    ),
    child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          children: [
            // الخلفية
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFCFD),
                      Color(0xFFFFF6F9),
                      Color(0xFFFCECF1),
                      Color(0xFFFFFAFB),
                    ],
                    stops: [
                      0.0,
                      0.35,
                      0.72,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
        
            // دوائر ناعمة بالخلفية
            Positioned(
              top: -120,
              right: -100,
              child: _GlowCircle(
                size: 300,
                color: _pinkLight.withValues(alpha: 0.45),
              ),
            ),

            Positioned(
              bottom: -150,
              left: -100,
              child: _GlowCircle(
                size: 340,
                color: _pinkLight.withValues(alpha: 0.38),
              ),
            ),

            Positioned(
              top: 330,
              left: -70,
              child: _GlowCircle(
                size: 170,
                color: const Color(0xFFFFE7EC)
                    .withValues(alpha: 0.45),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      34,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 620,
                        ),
                        child: Column(
                          children: [
                            _TopBar(
                              language: _language,
                              onChanged: (language) {
                                setState(() {
                                  _language = language;
                                });
                              },
                            ),

                            const SizedBox(height: 36),

                            // HERO
                            _HeroSection(
                              title: strings.title,
                              description: strings.description,
                            ),

                            const SizedBox(height: 38),

                            // عنوان المميزات
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _rose,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    strings.featuresTitle,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      color: _brown,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 17),

                            // المميزات
                            _FeatureCard(
                              icon: Icons.psychology_alt_rounded,
                              title: strings.exercises,
                              description:
                                  strings.exercisesDescription,
                              accentColor:
                                  const Color(0xFFB87585),
                              iconBackground:
                                  const Color(0xFFFFE9EF),
                            ),

                            const SizedBox(height: 13),

                            _FeatureCard(
                              icon: Icons.insights_rounded,
                              title: strings.progress,
                              description:
                                  strings.progressDescription,
                              accentColor:
                                  const Color(0xFF7895A4),
                              iconBackground:
                                  const Color(0xFFEAF2F5),
                            ),

                            const SizedBox(height: 13),

                            _FeatureCard(
                              icon:
                                  Icons.family_restroom_rounded,
                              title: strings.family,
                              description:
                                  strings.familyDescription,
                              accentColor:
                                  const Color(0xFFC79A62),
                              iconBackground:
                                  const Color(0xFFFFF2DF),
                            ),

                            const SizedBox(height: 35),

                            // إنشاء حساب
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RoleSelectionScreen(),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _rose,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      strings.createAccount,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(width: 9),

                                    const Icon(
                                      Icons
                                          .arrow_forward_rounded,
                                      size: 21,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 13),

                            // تسجيل الدخول
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _roseDark,
                                  backgroundColor:
                                      Colors.white.withValues(
                                    alpha: 0.70,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFDDBFC7),
                                    width: 1.3,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  strings.login,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Privacy / trust
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.52,
                                ),
                                borderRadius:
                                    BorderRadius.circular(18),
                                border: Border.all(
                                  color: _border,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .verified_user_outlined,
                                    size: 18,
                                    color: _rose,
                                  ),

                                  SizedBox(width: 8),

                                  Flexible(
                                    child: Text(
                                      'مساحتك آمنة، داعمة ومصممة لرحلة تأهيل أفضل',
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: _muted,
                                        fontWeight:
                                            FontWeight.w600,
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

// ======================================================
// HERO
// ======================================================

class _HeroSection extends StatelessWidget {
  final String title;
  final String description;

  const _HeroSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // دائرة حول الشعار
        Container(
          width: 185,
          height: 185,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFECF1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB87585)
                    .withValues(alpha: 0.13),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 23),

        // الاسم
       const Text(
  'NeuroBridge',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontFamily: 'EnglishScript',
    fontSize: 46,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: Color(0xFF95606D),
    letterSpacing: -1.8,
    height: 1.05,
  ),
),

        const SizedBox(height: 7),

        // Badge صغير
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAF0),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'رحلتك • دعمك • تقدّمك',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9D6170),
            ),
          ),
        ),

        const SizedBox(height: 25),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 29,
            height: 1.25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4D3935),
          ),
        ),

        const SizedBox(height: 15),

        Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8C7773),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// TOP BAR
// ======================================================

class _TopBar extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  const _TopBar({
    required this.language,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mini logo
        Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.78,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFEEDCE1),
            ),
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
          ),
        ),

        const SizedBox(width: 9),

      const Expanded(
  child: Text(
    'NeuroBridge',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: 'EnglishScript',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: Color(0xFF95606D),
      letterSpacing: -0.8,
    ),
  ),
),

        const SizedBox(width: 10),

        PopupMenuButton<AppLanguage>(
          initialValue: language,
          tooltip: 'Language',
          position: PopupMenuPosition.under,
          onSelected: onChanged,
          elevation: 10,
          color: const Color(0xFFFFFBFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          itemBuilder: (context) {
            return AppLanguage.values.map((item) {
              final isSelected = item == language;

              return PopupMenuItem<AppLanguage>(
                value: item,
                child: SizedBox(
                  width: 170,
                  child: Row(
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFE7ED)
                              : const Color(0xFFF8F0F2),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.code,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? const Color(0xFF9D6170)
                                : const Color(0xFF8B7774),
                          ),
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: const Color(0xFF513D39),
                          ),
                        ),
                      ),

                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: Color(0xFFB87585),
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },

          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.76,
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFE6CED4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9F6A77)
                      .withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 19,
                  color: Color(0xFFB87585),
                ),

                const SizedBox(width: 6),

                Text(
                  language.code,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5A4440),
                  ),
                ),

                const SizedBox(width: 3),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: Color(0xFF8D7773),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// FEATURE CARD
// ======================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final Color iconBackground;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.74,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFEEDCE1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E6F79)
                .withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

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
                    color: Color(0xFF513D39),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B7774),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 7),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: accentColor.withValues(
              alpha: 0.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// BACKGROUND CIRCLE
// ======================================================

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}