import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_colors.dart';
import '../widgets/auth_background.dart';
import 'main_shell.dart';
import 'role_selection_screen.dart';
import 'forgot_password_screen.dart';
import '../core/services/session_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==========================================
  // Colors
  // ==========================================

  static const Color _rose = AppColors.primary;

  static const Color _roseDark = AppColors.primaryDark;

  static const Color _brown = AppColors.textPrimary;

  static const Color _muted = AppColors.textSecondary;

  static const Color _border = AppColors.border;

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

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ==========================================
  // Login
  // ==========================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://toyoraljana.com/api_neuro/login.php'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'remember_me': _rememberMe,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['user'] as Map<String, dynamic>;
        final token = data['token']?.toString() ?? '';

if (token.isEmpty) {
  _showLoginError(
    'لم يتم استلام جلسة الدخول من الخادم.',
  );
  return;
}

await SessionService.saveSession(
  token: token,
  user: user,
  rememberMe: _rememberMe,
);

if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('أهلًا ${user['full_name']} 🌷'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainShell(
              user: user,
            ),
          ),
          (route) => false,
        );
        return;
      }

      _showLoginError(data['message']?.toString());
    } catch (_) {
      if (!mounted) return;
      _showLoginError('تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // Login Error
  // ==========================================

  void _showLoginError([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6F4E50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Forgot Password
  // ==========================================
void _showForgotPassword() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ForgotPasswordScreen(),
    ),
  );
}
  // ==========================================
  // Build
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    35,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // =====================
                            // TOP BAR
                            // =====================

                            _buildTopBar(),

                            const SizedBox(
                              height: 25,
                            ),

                            // =====================
                            // LOGO
                            // =====================

                            _buildLogo(),

                            const SizedBox(
                              height: 20,
                            ),

                            // =====================
                            // TITLE
                            // =====================

                            const Text(
                              'أهلًا بعودتك 🌷',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                height: 1.3,
                                fontWeight: FontWeight.w900,
                                color: _brown,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'واصل رحلتك من حيث توقفت',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: _muted,
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // =====================
                            // DEMO ACCOUNT
                            // =====================

                            // =====================
                            // EMAIL
                            // =====================

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني';
                                }

                                if (!value.contains('@')) {
                                  return 'أدخل بريدًا إلكترونيًا صحيحًا';
                                }

                                return null;
                              },
                              decoration: _inputDecoration(
                                label: 'البريد الإلكتروني',
                                hint: 'example@email.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // =====================
                            // PASSWORD
                            // =====================

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }

                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _login();
                              },
                              decoration: _inputDecoration(
                                label: 'كلمة المرور',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _muted,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            // =====================
                            // REMEMBER
                            // =====================

                            Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 40,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: _rose,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'تذكّرني',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(
                                      0xFF725E5A,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _showForgotPassword,
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      color: _roseDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // =====================
                            // LOGIN BUTTON
                            // =====================

                            SizedBox(
                              width: double.infinity,
                              height: 59,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _login,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _rose,
                                  disabledBackgroundColor: const Color(
                                    0xFFD2BEA2,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          SizedBox(width: 9),
                                          Icon(
                                            Icons.login_rounded,
                                            size: 21,
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // =====================
                            // DIVIDER
                            // =====================

                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Color(
                                      0xFFE0D4C4,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    'أو',
                                    style: TextStyle(
                                      color: _muted,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Color(
                                      0xFFE0D4C4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 23,
                            ),

                            // =====================
                            // BIOMETRIC
                            // =====================

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'الدخول بالبصمة سيتم تفعيله لاحقًا.',
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _brown,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.65,
                                  ),
                                  side: const BorderSide(
                                    color: _border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 28,
                                  color: _rose,
                                ),
                                label: const Text(
                                  'الدخول بالبصمة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            const Text(
                              'سيتم تفعيل هذه الميزة لاحقًا',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(
                                  0xFFA18D89,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 27,
                            ),

                            // =====================
                            // REGISTER
                            // =====================

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ليس لديك حساب؟',
                                  style: TextStyle(
                                    color: _muted,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RoleSelectionScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      color: _roseDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 15,
                                  color: Color(
                                    0xFFA18D89,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Flexible(
                                  child: Text(
                                    'بياناتك وخصوصيتك ستكون محمية عند ربط النظام بالخادم',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.5,
                                      color: Color(
                                        0xFFA18D89,
                                      ),
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
      ),
    );
  }

  // ==========================================
  // Top Bar
  // ==========================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.75,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _border,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: _brown,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _border,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 18,
                color: _rose,
              ),
              SizedBox(width: 6),
              Text(
                'AR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _brown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Logo
  // ==========================================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 115,
          height: 115,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(
              alpha: 0.78,
            ),
            border: Border.all(
              color: _border,
            ),
            boxShadow: [
              BoxShadow(
                color: _rose.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/neurobridge_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'NeuroBridge',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _roseDark,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Input Style
  // ==========================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _rose,
      ),
      filled: true,
      fillColor: Colors.white.withValues(
        alpha: 0.83,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF75615D),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFB4A2A0),
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
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD16A76),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD16A76),
          width: 1.5,
        ),
      ),
    );
  }
}
