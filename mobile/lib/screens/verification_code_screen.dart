import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_colors.dart';
import '../widgets/auth_background.dart';
import 'reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isVerifying = false;
  bool _isResending = false;

  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;

  String get code {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    if (code.length != 6) {
      _showMessage(
        'يرجى إدخال رمز التحقق المكوّن من 6 أرقام.',
      );

      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://toyoraljana.com/api_neuro/verify_reset_code.php',
            ),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': widget.email,
              'code': code,
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
        final resetToken =
            data['reset_token']?.toString() ?? '';

        if (resetToken.isEmpty) {
          _showMessage(
            'لم يتم استلام رمز أمان لتغيير كلمة المرور.',
          );

          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: widget.email,
              resetToken: resetToken,
            ),
          ),
        );

        return;
      }

      _showMessage(
        data['message'] ?? 'رمز التحقق غير صحيح.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://toyoraljana.com/api_neuro/request_reset.php',
            ),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': widget.email,
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
        for (final controller in _controllers) {
          controller.clear();
        }

        _showMessage(
          data['message'] ?? 'تم إرسال رمز جديد.',
        );

        return;
      }

      _showMessage(
        data['message'] ?? 'تعذر إعادة إرسال الرمز.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'تعذر الاتصال بالخادم.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1E7D8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 48,
                          color: rose,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'تحقق من بريدك',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          color: brown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'أدخل رمز التحقق المكوّن من 6 أرقام '
                        'الذي تم إرساله إلى\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          height: 1.7,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          children: List.generate(
                            6,
                            (index) {
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: TextField(
                                    controller:
                                        _controllers[index],
                                    keyboardType:
                                        TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                    ],
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                      color: brown,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white
                                          .withValues(alpha: .82),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          15,
                                        ),
                                        borderSide:
                                            const BorderSide(
                                          color: Color(
                                            0xFFE4D8C8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty &&
                                          index < 5) {
                                        FocusScope.of(context)
                                            .nextFocus();
                                      }

                                      if (value.isEmpty &&
                                          index > 0) {
                                        FocusScope.of(context)
                                            .previousFocus();
                                      }

                                      if (code.length == 6) {
                                        _verify();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed:
                              _isVerifying ? null : _verify,
                          style: FilledButton.styleFrom(
                            backgroundColor: rose,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: _isVerifying
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
                                  'تحقق من الرمز',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _isResending
                            ? null
                            : _resendCode,
                        child: Text(
                          _isResending
                              ? 'جارٍ إعادة الإرسال...'
                              : 'لم يصلك الرمز؟ إعادة الإرسال',
                          style: const TextStyle(
                            color: rose,
                            fontWeight: FontWeight.w800,
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
    );
  }
}