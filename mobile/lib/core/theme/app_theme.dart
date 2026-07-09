import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Premium "medical luxury" theme (Material 3, light mode): deep emerald on a
/// warm ivory background, muted sage, and champagne-gold accents. Rounded cards,
/// soft shadows, and elderly-friendly spacing/typography.
class AppTheme {
  const AppTheme._();

  static ColorScheme _scheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.deepEmerald,
      brightness: Brightness.light,
    );
    return base.copyWith(
      primary: AppColors.deepEmerald,
      onPrimary: AppColors.warmWhite,
      primaryContainer: AppColors.emeraldTint,
      onPrimaryContainer: AppColors.darkTeal,
      secondary: AppColors.mutedSage,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.sageTint,
      onSecondaryContainer: const Color(0xFF2E3B31),
      tertiary: AppColors.softGold,
      onTertiary: const Color(0xFF3A2E10),
      tertiaryContainer: AppColors.goldTint,
      onTertiaryContainer: const Color(0xFF4A3B18),
      surface: AppColors.warmWhite,
      onSurface: AppColors.onSurfaceDeep,
      onSurfaceVariant: AppColors.onSurfaceMuted,
      surfaceContainerHighest: AppColors.warmStone,
      outline: AppColors.outlineSoft,
      error: AppColors.errorRed,
      onError: Colors.white,
    );
  }

  static ThemeData light() {
    final scheme = _scheme();
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme;

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ivory,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.deepEmerald,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: AppColors.deepEmerald,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.warmWhite,
        elevation: 2,
        shadowColor: const Color(0x1A0F5C4C),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.deepEmerald,
          foregroundColor: AppColors.warmWhite,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.deepEmerald,
          side: const BorderSide(color: AppColors.deepEmerald),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.deepEmerald),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.warmStone),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.warmStone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.deepEmerald, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.warmStone,
        thickness: 1,
      ),
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.deepEmerald,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.deepEmerald,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16.5, height: 1.35),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.35),
      ),
    );
  }
}
