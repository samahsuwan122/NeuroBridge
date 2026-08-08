import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  String get _roleTitle {
    if (widget.role == 'patient') {
      return 'مريض';
    }

    return 'مرافق / فرد من العائلة';
  }

  String get _roleDescription {
    if (widget.role == 'patient') {
      return 'ستتمكن من الوصول إلى التمارين ومتابعة تقدمك وإنجازاتك.';
    }

    return 'ستتمكن من متابعة تقدم المريض وتقديم الدعم والمشاركة في رحلة التأهيل.';
  }

  IconData get _roleIcon {
    if (widget.role == 'patient') {
      return Icons.person_rounded;
    }

    return Icons.family_restroom_rounded;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يرجى الموافقة على الشروط وسياسة الخصوصية.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    // مؤقت إلى أن يتم ربط Firebase أو الـ Backend.
    await Future.delayed(
      const Duration(milliseconds: 1300),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم إنشاء الحساب بنجاح 🌷',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
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
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        Image.asset(
                          'assets/images/neurobridge_logo.png',
                          width: 105,
                          height: 105,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'إنشاء حساب',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF35251C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ابدأ رحلتك مع NeuroBridge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF8B7774),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _buildRoleCard(),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          hint: 'أدخل اسمك الكامل',
                          icon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال الاسم الكامل';
                            }

                            if (value.trim().length < 2) {
                              return 'الاسم قصير جدًا';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'example@email.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }

                            final email = value.trim();

                            final validEmail = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email);

                            if (!validEmail) {
                              return 'أدخل بريدًا إلكترونيًا صحيحًا';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          hint: 'اختياري',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(),
                        const SizedBox(height: 14),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 18),
                        _buildPasswordStrength(),
                        const SizedBox(height: 20),
                        _buildTerms(),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4A3528),
                              disabledBackgroundColor: const Color(0xFFD1B99B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'إنشاء الحساب',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لديك حساب بالفعل؟',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B7774),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: Color(0xFF76513E),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'NeuroBridge يدعم التأهيل والمتابعة ولا يقدّم تشخيصًا طبيًا.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: Color(0xFFA08E8A),
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
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          tooltip: 'رجوع',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF5A4541),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5D9C9),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 18,
                color: Color(0xFF76513E),
              ),
              SizedBox(width: 6),
              Text(
                'AR',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A4541),
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 17,
                color: Color(0xFF7E6965),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF5ECE0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD9C3A6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.82,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              _roleIcon,
              size: 29,
              color: const Color(0xFF4A3528),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نوع الحساب',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF927D79),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _roleTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF35251C),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _roleDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF8B7774),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4A3528),
            size: 23,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _hidePassword,
      textDirection: TextDirection.ltr,
      onChanged: (_) {
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }

        if (value.length < 6) {
          return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
        }

        return null;
      },
      decoration: _inputDecoration(
        label: 'كلمة المرور',
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          tooltip: _hidePassword ? 'إظهار' : 'إخفاء',
          onPressed: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
          icon: Icon(
            _hidePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF8D7975),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _hideConfirmPassword,
      textDirection: TextDirection.ltr,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى تأكيد كلمة المرور';
        }

        if (value != _passwordController.text) {
          return 'كلمتا المرور غير متطابقتين';
        }

        return null;
      },
      decoration: _inputDecoration(
        label: 'تأكيد كلمة المرور',
        hint: '••••••••',
        icon: Icons.lock_reset_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          tooltip: _hideConfirmPassword ? 'إظهار' : 'إخفاء',
          onPressed: () {
            setState(() {
              _hideConfirmPassword = !_hideConfirmPassword;
            });
          },
          icon: Icon(
            _hideConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF8D7975),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final password = _passwordController.text;

    double strength = 0;
    String strengthText = 'لم يتم إدخال كلمة مرور';

    if (password.isNotEmpty) {
      strength = 0.25;
      strengthText = 'ضعيفة';
    }

    if (password.length >= 6) {
      strength = 0.50;
      strengthText = 'متوسطة';
    }

    if (password.length >= 8 && RegExp(r'[0-9]').hasMatch(password)) {
      strength = 0.75;
      strengthText = 'جيدة';
    }

    if (password.length >= 10 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      strength = 1;
      strengthText = 'قوية';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'قوة كلمة المرور',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8B7774),
              ),
            ),
            const Spacer(),
            Text(
              strengthText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF76513E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 6,
            backgroundColor: const Color(0xFFECE0D0),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF4A3528),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _acceptedTerms = !_acceptedTerms;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptedTerms,
              activeColor: const Color(0xFF4A3528),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
            ),
            const SizedBox(width: 3),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 11,
                ),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF806D69),
                    ),
                    children: [
                      TextSpan(
                        text: 'أوافق على ',
                      ),
                      TextSpan(
                        text: 'الشروط والأحكام',
                        style: TextStyle(
                          color: Color(0xFF76513E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' و ',
                      ),
                      TextSpan(
                        text: 'سياسة الخصوصية',
                        style: TextStyle(
                          color: Color(0xFF76513E),
                          fontWeight: FontWeight.w800,
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
    );
  }

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
        color: const Color(0xFF4A3528),
      ),
      filled: true,
      fillColor: Colors.white.withValues(
        alpha: 0.84,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF78635F),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFB5A4A1),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8DDD0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8DDD0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF4A3528),
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD46A75),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD46A75),
          width: 1.5,
        ),
      ),
    );
  }
}
