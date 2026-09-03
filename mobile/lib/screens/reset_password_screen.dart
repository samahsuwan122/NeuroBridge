import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_colors.dart';
import '../widgets/auth_background.dart';
import 'password_changed_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController =
      TextEditingController();

  final _confirmController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
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
            Uri.parse(
              'https://toyoraljana.com/api_neuro/reset_password.php',
            ),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': widget.email,
              'reset_token': widget.resetToken,
              'new_password':
                  _passwordController.text,
            }),
          )
          .timeout(
            const Duration(seconds: 25),
          );

      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      if (response.statusCode == 200 &&
          data['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PasswordChangedScreen(),
          ),
          (route) => false,
        );

        return;
      }

      _showMessage(
        data['message'] ??
            'تعذر تغيير كلمة المرور.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
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
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
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
                        Text(
                          'سيتم تحديث كلمة المرور لحساب:\n'
                          '${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.7,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 35),
                        TextFormField(
                          controller:
                              _passwordController,
                          obscureText: _hidePassword,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }

                            if (value.length < 8) {
                              return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                            }

                            return null;
                          },
                          decoration:
                              _passwordDecoration(
                            'كلمة المرور الجديدة',
                            _hidePassword,
                            () {
                              setState(() {
                                _hidePassword =
                                    !_hidePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller:
                              _confirmController,
                          obscureText: _hideConfirm,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'يرجى تأكيد كلمة المرور';
                            }

                            if (value !=
                                _passwordController.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }

                            return null;
                          },
                          decoration:
                              _passwordDecoration(
                            'تأكيد كلمة المرور',
                            _hideConfirm,
                            () {
                              setState(() {
                                _hideConfirm =
                                    !_hideConfirm;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : _changePassword,
                            style:
                                FilledButton.styleFrom(
                              backgroundColor: rose,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'تغيير كلمة المرور',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w900,
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
          hidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
      filled: true,
      fillColor:
          Colors.white.withValues(alpha: .82),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}