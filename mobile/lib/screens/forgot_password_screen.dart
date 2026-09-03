import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/theme/app_colors.dart';
import '../widgets/auth_background.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

 final _emailController = TextEditingController();

  bool _loading = false;

  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;
  static const Color border = AppColors.border;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

 Future<void> _sendCode() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _loading = true;
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
            'email': _emailController.text.trim(),
          }),
        )
        .timeout(
          const Duration(seconds: 25),
        );

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (!mounted) return;

    if (response.statusCode == 200 && data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ??
                'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data['message'] ?? 'تعذر إرسال رمز التحقق',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
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
                        _BackButton(),
                        const SizedBox(height: 40),
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1E7D8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: rose.withValues(
                                  alpha: .13,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 52,
                            color: rose,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'نسيت كلمة المرور؟',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رمزًا لاستعادة حسابك.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.8,
                            fontSize: 15,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 35),
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
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'example@email.com',
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: rose,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: .82),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: rose,
                                width: 1.7,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _loading ? null : _sendCode,
                            style: FilledButton.styleFrom(
                              backgroundColor: rose,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'إرسال رمز التحقق',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'للتجربة فقط: لن يتم إرسال بريد حقيقي حتى يتم ربط الـ Backend.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: Color(0xFFA18D89),
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
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE4D8C8),
          ),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 17,
          ),
        ),
      ),
    );
  }
}
