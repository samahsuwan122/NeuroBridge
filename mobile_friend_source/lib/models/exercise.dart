import 'package:flutter/material.dart';

class Exercise {
  const Exercise({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.durationMinutes,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int durationMinutes;
  final Color color;
}
