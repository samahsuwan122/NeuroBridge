import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'login_screen.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 125,
                        height: 125,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE8EE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 70,
                          color: Color(0xFFB87585),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'تم تغيير كلمة المرور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4F3C38),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'تم تحديث كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.8,
                          color: Color(0xFF89736F),
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
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
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'العودة لتسجيل الدخول',
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
    );
  }
}