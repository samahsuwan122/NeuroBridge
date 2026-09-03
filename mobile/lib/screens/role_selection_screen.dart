import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/localization/app_language.dart';
import '../widgets/auth_background.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? role;

  AppLanguage _language = AppLanguage.arabic;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color _rose = AppColors.primary;
  static const Color _roseDark = AppColors.primaryDark;
  static const Color _brown = AppColors.textPrimary;
  static const Color _muted = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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

  // =====================================================
  // TEXT DIRECTION
  // =====================================================

  TextDirection get _direction {
    return _language == AppLanguage.arabic
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  // =====================================================
  // TRANSLATIONS
  // =====================================================

  String get _title {
    switch (_language) {
      case AppLanguage.arabic:
        return 'كيف ستستخدم التطبيق؟';

      case AppLanguage.english:
        return 'How will you use NeuroBridge?';

      case AppLanguage.french:
        return 'Comment utiliserez-vous NeuroBridge ?';

      case AppLanguage.spanish:
        return '¿Cómo usarás NeuroBridge?';

      case AppLanguage.german:
        return 'Wie möchten Sie NeuroBridge nutzen?';

      default:
        return 'How will you use NeuroBridge?';
    }
  }

  String get _subtitle {
    switch (_language) {
      case AppLanguage.arabic:
        return 'اختر نوع الحساب الذي يناسب دورك';

      case AppLanguage.english:
        return 'Choose the account type that fits your role';

      case AppLanguage.french:
        return 'Choisissez le type de compte adapté à votre rôle';

      case AppLanguage.spanish:
        return 'Elige el tipo de cuenta que se adapte a tu rol';

      case AppLanguage.german:
        return 'Wählen Sie den passenden Kontotyp';

      default:
        return 'Choose your account type';
    }
  }

  String get _patientTitle {
    switch (_language) {
      case AppLanguage.arabic:
        return 'أنا مريض';

      case AppLanguage.english:
        return 'I am a patient';

      case AppLanguage.french:
        return 'Je suis un patient';

      case AppLanguage.spanish:
        return 'Soy paciente';

      case AppLanguage.german:
        return 'Ich bin Patient';

      default:
        return 'I am a patient';
    }
  }

  String get _patientDescription {
    switch (_language) {
      case AppLanguage.arabic:
        return 'الوصول إلى التمارين اليومية والألعاب المعرفية، متابعة التقدّم والإنجازات والبقاء على تواصل مع العائلة.';

      case AppLanguage.english:
        return 'Access daily exercises and cognitive games, track progress and achievements, and stay connected with family.';

      case AppLanguage.french:
        return 'Accédez aux exercices quotidiens et aux jeux cognitifs, suivez vos progrès et restez connecté avec votre famille.';

      case AppLanguage.spanish:
        return 'Accede a ejercicios diarios y juegos cognitivos, sigue tu progreso y mantente conectado con tu familia.';

      case AppLanguage.german:
        return 'Greifen Sie auf tägliche Übungen und kognitive Spiele zu und verfolgen Sie Ihre Fortschritte.';

      default:
        return '';
    }
  }

  String get _familyTitle {
    switch (_language) {
      case AppLanguage.arabic:
        return 'أنا مرافق / فرد من العائلة';

      case AppLanguage.english:
        return 'I am a caregiver / family member';

      case AppLanguage.french:
        return 'Je suis un proche / accompagnant';

      case AppLanguage.spanish:
        return 'Soy cuidador / familiar';

      case AppLanguage.german:
        return 'Ich bin Betreuer / Familienmitglied';

      default:
        return '';
    }
  }

  String get _familyDescription {
    switch (_language) {
      case AppLanguage.arabic:
        return 'متابعة تقدّم المريض، إرسال رسائل دعم، الاطلاع على النشاط والمواعيد المشتركة والمشاركة في رحلة التأهيل.';

      case AppLanguage.english:
        return 'Follow patient progress, send supportive messages, view activity and shared appointments, and take part in recovery.';

      case AppLanguage.french:
        return 'Suivez les progrès du patient, envoyez des messages de soutien et consultez les rendez-vous partagés.';

      case AppLanguage.spanish:
        return 'Sigue el progreso del paciente, envía mensajes de apoyo y consulta las citas compartidas.';

      case AppLanguage.german:
        return 'Verfolgen Sie den Fortschritt, senden Sie Unterstützung und sehen Sie gemeinsame Termine ein.';

      default:
        return '';
    }
  }

  String get _continueText {
    switch (_language) {
      case AppLanguage.arabic:
        return 'متابعة';

      case AppLanguage.english:
        return 'Continue';

      case AppLanguage.french:
        return 'Continuer';

      case AppLanguage.spanish:
        return 'Continuar';

      case AppLanguage.german:
        return 'Weiter';

      default:
        return 'Continue';
    }
  }

  String get _chooseHint {
    switch (_language) {
      case AppLanguage.arabic:
        return 'يمكنك تغيير نوع الحساب لاحقًا من الإعدادات';

      case AppLanguage.english:
        return 'You can manage your account settings later';

      case AppLanguage.french:
        return 'Vous pourrez gérer votre compte plus tard';

      case AppLanguage.spanish:
        return 'Podrás gestionar tu cuenta más tarde';

      case AppLanguage.german:
        return 'Sie können Ihr Konto später verwalten';

      default:
        return '';
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final isRTL = _language == AppLanguage.arabic;

    return Directionality(
      textDirection: _direction,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    25,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 620,
                      ),
                      child: Column(
                        children: [
                          // =============================
                          // TOP BAR
                          // =============================

                          _buildTopBar(),

                          const SizedBox(height: 20), // Reduced

                          // =============================
                          // LOGO
                          // =============================

                          Container(
                            width: 95,
                            height: 95,
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.82,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFFE3D5C2,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _rose.withValues(
                                    alpha: 0.10,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(
                                    0,
                                    12,
                                  ),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/neurobridge_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 12), // Reduced

                          // اسم التطبيق منفصل حتى لا يلخبط RTL
                          const Text(
                            'NeuroBridge',
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: _roseDark,
                              letterSpacing: -0.8,
                            ),
                          ),

                          const SizedBox(height: 19),

                          // =============================
                          // TITLE
                          // =============================

                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            child: Column(
                              key: ValueKey(_language),
                              children: [
                                Text(
                                  _title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: _language == AppLanguage.arabic
                                        ? 30
                                        : 28,
                                    height: 1.3,
                                    fontWeight: FontWeight.w900,
                                    color: _brown,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  _subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // =============================
                          // PATIENT
                          // =============================

                          _RoleCard(
                            selected: role == 'patient',
                            icon: Icons.person_rounded,
                            title: _patientTitle,
                            description: _patientDescription,
                            isRTL: isRTL,
                            onTap: () {
                              setState(() {
                                role = 'patient';
                              });
                            },
                          ),

                          const SizedBox(height: 15),

                          // =============================
                          // FAMILY
                          // =============================

                          _RoleCard(
                            selected: role == 'caregiver',
                            icon: Icons.family_restroom_rounded,
                            title: _familyTitle,
                            description: _familyDescription,
                            isRTL: isRTL,
                            onTap: () {
                              setState(() {
                                role = 'caregiver';
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // =============================
                          // HINT (Improved Contrast)
                          // =============================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Color(0xFF8A7A6E),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _chooseHint,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5A4A3E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // =============================
                          // CONTINUE
                          // =============================

                          AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            width: double.infinity,
                            height: 60,
                            child: FilledButton(
                              onPressed: role == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RegisterScreen(
                                            role: role!,
                                          ),
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: _rose,
                                disabledBackgroundColor: const Color(
                                  0xFFDED3C4,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFFAA9DA0,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _continueText,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (role != null) ...[
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Icon(
                                      // Fix: Arrow direction based on language
                                      isRTL
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: 21,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
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

  // =====================================================
  // TOP BAR
  // =====================================================

  Widget _buildTopBar() {
    final isRTL = _language == AppLanguage.arabic;

    return Row(
      children: [
        // Back Button - Direction aware
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4D7C6),
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              // Fix: Arrow direction based on language
              isRTL
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: _brown,
            ),
          ),
        ),

        const Spacer(),

        // =============================
        // LANGUAGE
        // =============================

        PopupMenuButton<AppLanguage>(
          initialValue: _language,
          position: PopupMenuPosition.under,
          tooltip: 'Language',
          color: const Color(0xFFFEFBF5),
          elevation: 8,
          onSelected: (language) {
            setState(() {
              _language = language;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          itemBuilder: (context) {
            return [
              AppLanguage.arabic,
              AppLanguage.english,
              AppLanguage.french,
              AppLanguage.spanish,
              AppLanguage.german,
            ].map((item) {
              final selected = item == _language;

              return PopupMenuItem<AppLanguage>(
                value: item,
                child: SizedBox(
                  width: 175,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(
                                  0xFFE9D9C4,
                                )
                              : const Color(
                                  0xFFF6F0E7,
                                ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          item.code,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: selected ? _roseDark : _muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w600,
                            color: _brown,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: _rose,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.78,
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFDCCBB4),
              ),
              boxShadow: [
                BoxShadow(
                  color: _rose.withValues(
                    alpha: 0.07,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 19,
                  color: _rose,
                ),
                const SizedBox(width: 7),
                Text(
                  _language.code,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _brown,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================
// ROLE CARD (Improved)
// =========================================================

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final bool isRTL;
  final VoidCallback onTap;

  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.isRTL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 260,
          ),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(16), // Reduced padding
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFE8D9C8), // Darker for better selection
                      Color(0xFFF5EEE4),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(
                        alpha: 0.82,
                      ),
                      Colors.white.withValues(
                        alpha: 0.70,
                      ),
                    ],
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color:
                  selected ? const Color(0xFF4A3528) : const Color(0xFFE4D8C8),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF4A3528,
                ).withValues(
                  alpha: selected ? 0.18 : 0.04, // Stronger shadow when selected
                ),
                blurRadius: selected ? 30 : 15,
                offset: const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // =================================================
              // FIX: Reorder based on RTL
              // If RTL: Check icon comes first (right side)
              // If LTR: Category icon comes first (left side)
              // =================================================

              if (isRTL) _buildCheckIcon(),
              if (isRTL) const SizedBox(width: 10),

              // Category Icon
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 260,
                ),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(
                          0xFFEEDFCB,
                        )
                      : const Color(
                          0xFFF7EEE2,
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 31,
                  color: selected
                      ? const Color(
                          0xFFA96475,
                        )
                      : const Color(
                          0xFFBD7C8D,
                        ),
                ),
              ),

              const SizedBox(width: 17),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w900,
                        color: Color(
                          0xFF35251C,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15, // Increased for readability
                        height: 1.7,
                        fontWeight: FontWeight.w500, // Slightly bolder
                        color: Color(0xFF4A3528), // Darker for contrast
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // FIX: Reorder based on RTL (continued)
              // If NOT RTL: Check icon comes last (right side)
              // =================================================

              if (!isRTL) const SizedBox(width: 10),
              if (!isRTL) _buildCheckIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckIcon() {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 200,
      ),
      child: selected
          ? const Icon(
              Icons.check_circle_rounded,
              key: ValueKey(
                'checked',
              ),
              color: Color(
                0xFF4A3528,
              ),
              size: 25,
            )
          : const Icon(
              Icons.radio_button_unchecked_rounded,
              key: ValueKey(
                'unchecked',
              ),
              color: Color(
                0xFFD8C9B5,
              ),
              size: 24,
            ),
    );
  }
}