import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/auth_background.dart';
import 'password_changed_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  final _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordChangedScreen(),
      ),
      (route) => route.isFirst,
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
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 55),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1E7D8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.password_rounded,
                            size: 48,
                            color: rose,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'أنشئ كلمة مرور جديدة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'اختر كلمة مرور قوية وجديدة لحماية حسابك.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.7,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 35),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                            }

                            return null;
                          },
                          decoration: _passwordDecoration(
                            'كلمة المرور الجديدة',
                            _hidePassword,
                            () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _hideConfirm,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }

                            return null;
                          },
                          decoration: _passwordDecoration(
                            'تأكيد كلمة المرور',
                            _hideConfirm,
                            () {
                              setState(() {
                                _hideConfirm = !_hideConfirm;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: rose,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: _changePassword,
                            child: const Text(
                              'تغيير كلمة المرور',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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

  InputDecoration _passwordDecoration(
    String label,
    bool hidden,
    VoidCallback toggle,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: rose,
      ),
      suffixIcon: IconButton(
        onPressed: toggle,
        icon: Icon(
          hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .82),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
