import 'package:flutter/material.dart';

/// NeuroBridge "medical luxury" palette — deep emerald, ivory, muted sage, and
/// champagne-gold accents. Gold is used for accents only, never for body text.
class AppColors {
  const AppColors._();

  // Core brand
  static const Color deepEmerald = Color(0xFF0F5C4C);
  static const Color darkTeal = Color(0xFF0B4A3F);
  static const Color mutedSage = Color(0xFF8CA893);

  // Backgrounds / surfaces
  static const Color ivory = Color(0xFFFBF7EF);
  static const Color warmWhite = Color(0xFFFFFDF9);
  static const Color warmStone = Color(0xFFE7E0D4);

  // Accent (champagne gold) — accents/borders/icons only
  static const Color softGold = Color(0xFFC4A15A);

  static const Color errorRed = Color(0xFFB3261E);

  // Supporting tints / text tones
  static const Color emeraldTint = Color(0xFFCFE7DE);
  static const Color sageTint = Color(0xFFDDE8DB);
  static const Color goldTint = Color(0xFFF2E7CB);
  static const Color onSurfaceDeep = Color(0xFF1E2B26);
  static const Color onSurfaceMuted = Color(0xFF4C5A52);
  static const Color outlineSoft = Color(0xFF6B776E);
}
