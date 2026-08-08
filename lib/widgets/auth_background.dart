import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCFD),
            Color(0xFFFFF6F8),
            Color(0xFFFCEEF2),
            Color(0xFFFFFAFB),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: _Circle(
              size: 260,
              color: Color(0x22D99AA8),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _Circle(
              size: 300,
              color: Color(0x22EDC5CD),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}