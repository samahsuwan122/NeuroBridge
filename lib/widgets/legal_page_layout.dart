import 'package:flutter/material.dart';

import 'auth_background.dart';

class LegalPageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const LegalPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        'NeuroBridge',
                        textDirection:
                            TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w900,
                          color:
                              Color(0xFF95606D),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      22,
                      10,
                      22,
                      35,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 700,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(0xFFFFE9EF),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  size: 39,
                                  color:
                                      const Color(
                                    0xFFB87585,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            Center(
                              child: Text(
                                title,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      Color(0xFF4F3C38),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 9,
                            ),

                            Center(
                              child: Text(
                                subtitle,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  height: 1.6,
                                  color:
                                      Color(0xFF89736F),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final String title;
  final String text;

  const LegalSection({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: .74),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAD8DD),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F3C38),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: Color(0xFF806D69),
            ),
          ),
        ],
      ),
    );
  }
}