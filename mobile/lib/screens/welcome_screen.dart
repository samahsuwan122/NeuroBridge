
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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

  // Dark Mode
  bool _isDarkMode = false;

  String get _currentFont {
    if (_language == AppLanguage.arabic) {
      return 'ArabicElegant';
    }

    return 'EnglishScript';
  }

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // =========================
  // LIGHT COLORS
  // =========================

  static const Color _lightBackground = Color(0xFFFFFBF7);
  static const Color _lightCard = Colors.white;
  static const Color _lightText = Color(0xFF4D3935);
  static const Color _lightSecondaryText = Color(0xFF8C7773);
  static const Color _lightBorder = Color(0xFFE9DDCD);

  // =========================
  // DARK COLORS
  // =========================

  static const Color _darkBackground = Color(0xFF181515);
  static const Color _darkCard = Color(0xFF242020);
  static const Color _darkText = Color(0xFFF5EDE7);
  static const Color _darkSecondaryText = Color(0xFFB9AAA3);
  static const Color _darkBorder = Color(0xFF3A3330);

  static const Color _primary = AppColors.primary;

  Color get _background =>
      _isDarkMode ? _darkBackground : _lightBackground;

  Color get _cardColor => _isDarkMode ? _darkCard : _lightCard;

  Color get _mainText => _isDarkMode ? _darkText : _lightText;

  Color get _secondaryText =>
      _isDarkMode ? _darkSecondaryText : _lightSecondaryText;

  Color get _border => _isDarkMode ? _darkBorder : _lightBorder;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
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
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: _background,
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: _currentFont,
              ),
          primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
                fontFamily: _currentFont,
              ),
        ),
        child: Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 620,
                      ),
                      child: Column(
                        children: [
                          // =========================
                          // TOP BAR
                          // =========================

                          _TopBar(
                            language: _language,
                            isDarkMode: _isDarkMode,
                            onLanguageChanged: (language) {
                              setState(() {
                                _language = language;
                              });
                            },
                            onThemeChanged: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),

                          const SizedBox(height: 35),

                          // =========================
                          // HERO
                          // =========================

                          _HeroSection(
                            title: strings.title,
                            description: strings.description,
                            isDarkMode: _isDarkMode,
                            mainText: _mainText,
                            secondaryText: _secondaryText,
                            borderColor: _border,
                          ),

                          const SizedBox(height: 36),

                          // =========================
                          // FEATURES TITLE
                          // =========================

                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              strings.featuresTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _mainText,
                              ),
                            ),
                          ),

                          const SizedBox(height: 13),

                          // =========================
                          // FEATURE 1
                          // =========================

                          _FeatureCard(
                            icon: Icons.psychology_alt_rounded,
                            title: strings.exercises,
                            description: strings.exercisesDescription,
                            accentColor: const Color(0xFFB89272),
                            iconBackground: _isDarkMode
                                ? const Color(0xFF342C27)
                                : const Color(0xFFF4ECE3),
                            cardColor: _cardColor,
                            borderColor: _border,
                            mainText: _mainText,
                            secondaryText: _secondaryText,
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // FEATURE 2
                          // =========================

                          _FeatureCard(
                            icon: Icons.insights_rounded,
                            title: strings.progress,
                            description: strings.progressDescription,
                            accentColor: const Color(0xFF7895A4),
                            iconBackground: _isDarkMode
                                ? const Color(0xFF273137)
                                : const Color(0xFFEDF3F5),
                            cardColor: _cardColor,
                            borderColor: _border,
                            mainText: _mainText,
                            secondaryText: _secondaryText,
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // FEATURE 3
                          // =========================

                          _FeatureCard(
                            icon: Icons.family_restroom_rounded,
                            title: strings.family,
                            description: strings.familyDescription,
                            accentColor: const Color(0xFFC79A62),
                            iconBackground: _isDarkMode
                                ? const Color(0xFF352E25)
                                : const Color(0xFFFFF4E5),
                            cardColor: _cardColor,
                            borderColor: _border,
                            mainText: _mainText,
                            secondaryText: _secondaryText,
                          ),

                          const SizedBox(height: 28),

                          // =========================
                          // CREATE ACCOUNT
                          // =========================

                          SizedBox(
                            width: double.infinity,
                            height: 52,
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
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                strings.createAccount,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =========================
                          // LOGIN
                          // =========================

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isDarkMode
                                    ? const Color(0xFFE3C6B2)
                                    : AppColors.primaryDark,
                                backgroundColor: _cardColor,
                                side: BorderSide(
                                  color: _border,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                strings.login,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // =========================
                          // TRUST MESSAGE
                          // =========================

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 16,
                                color: _isDarkMode
                                    ? const Color(0xFFD0A98D)
                                    : _primary,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  'مساحتك آمنة، داعمة ومصممة لرحلة تأهيل أفضل',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.4,
                                    color: _secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HERO SECTION
// ======================================================

class _HeroSection extends StatelessWidget {
  final String title;
  final String description;
  final bool isDarkMode;
  final Color mainText;
  final Color secondaryText;
  final Color borderColor;

  const _HeroSection({
    required this.title,
    required this.description,
    required this.isDarkMode,
    required this.mainText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================
        // LOGO
        // =========================

        Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode
                ? const Color(0xFF242020)
                : Colors.white,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 16),

        // =========================
        // APP NAME
        // =========================

        Text(
          'NeuroBridge',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'EnglishScript',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDarkMode
                ? const Color(0xFFE3C6B2)
                : const Color(0xFF6D513F),
          ),
        ),

        const SizedBox(height: 18),

        // =========================
        // TITLE
        // =========================

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: mainText,
          ),
        ),

        const SizedBox(height: 11),

        // =========================
        // DESCRIPTION
        // =========================

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w400,
              color: secondaryText,
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
  final bool isDarkMode;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onThemeChanged;

  const _TopBar({
    required this.language,
    required this.isDarkMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // =========================
        // SMALL LOGO
        // =========================

        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF242020)
                : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF3A3330)
                  : const Color(0xFFE8DDD0),
            ),
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
          ),
        ),

        const SizedBox(width: 8),

        // =========================
        // APP NAME
        // =========================

        Expanded(
          child: Text(
            'NeuroBridge',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'EnglishScript',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? const Color(0xFFE3C6B2)
                  : const Color(0xFF6D513F),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // =========================
        // DARK / LIGHT MODE
        // =========================

        InkWell(
          onTap: onThemeChanged,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF242020)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF3A3330)
                    : const Color(0xFFE0D3C4),
              ),
            ),
            child: Icon(
              isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 18,
              color: isDarkMode
                  ? const Color(0xFFE3C6B2)
                  : const Color(0xFF5A4440),
            ),
          ),
        ),

        const SizedBox(width: 7),

        // =========================
        // LANGUAGE
        // =========================

        PopupMenuButton<AppLanguage>(
          initialValue: language,
          tooltip: 'Language',
          position: PopupMenuPosition.under,
          onSelected: onLanguageChanged,
          elevation: 4,
          color: isDarkMode
              ? const Color(0xFF242020)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) {
            return AppLanguage.values.map((item) {
              final isSelected = item == language;

              return PopupMenuItem<AppLanguage>(
                value: item,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode
                                ? const Color(0xFF3A302B)
                                : const Color(0xFFF0E5D8))
                            : (isDarkMode
                                ? const Color(0xFF302A28)
                                : const Color(0xFFF8F5F1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? const Color(0xFFE3C6B2)
                              : const Color(0xFF76513E),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDarkMode
                              ? const Color(0xFFF0E7E2)
                              : const Color(0xFF513D39),
                        ),
                      ),
                    ),

                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: isDarkMode
                            ? const Color(0xFFE3C6B2)
                            : const Color(0xFF4A3528),
                      ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF242020)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF3A3330)
                    : const Color(0xFFE0D3C4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 17,
                  color: isDarkMode
                      ? const Color(0xFFE3C6B2)
                      : const Color(0xFF4A3528),
                ),

                const SizedBox(width: 4),

                Text(
                  language.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode
                        ? const Color(0xFFE3C6B2)
                        : const Color(0xFF5A4440),
                  ),
                ),

                const SizedBox(width: 1),

                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDarkMode
                      ? const Color(0xFFB9AAA3)
                      : const Color(0xFF8D7773),
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
  final Color cardColor;
  final Color borderColor;
  final Color mainText;
  final Color secondaryText;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.iconBackground,
    required this.cardColor,
    required this.borderColor,
    required this.mainText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          // =========================
          // ICON
          // =========================

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // TEXT
          // =========================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: mainText,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: accentColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
