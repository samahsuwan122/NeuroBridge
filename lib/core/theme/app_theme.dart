import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
      primary: AppColors.green,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: scheme,

      scaffoldBackgroundColor: AppColors.background,

      fontFamily: 'Arial',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.brown,
        elevation: 0,
        centerTitle: false,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.brown,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          color: AppColors.brown,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.brown,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.brown,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.brown,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.brown,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: AppColors.brown,
          fontSize: 14,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF89736F),
          fontSize: 12,
          height: 1.5,
        ),
      ),

      // مهم جدًا:
      // لا نستخدم double.infinity هنا.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            0,
            56,
          ),
          backgroundColor: const Color(
            0xFFB87585,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            0,
            54,
          ),
          foregroundColor: const Color(
            0xFF95606D,
          ),
          side: const BorderSide(
            color: Color(0xFFE0C6CC),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.85,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: const BorderSide(
            color: Color(0xFFEAD8DD),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: const BorderSide(
            color: Color(0xFFEAD8DD),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: const BorderSide(
            color: Color(0xFFB87585),
            width: 1.5,
          ),
        ),
      ),

      navigationBarTheme:
          const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(
          0xFFFFE7ED,
        ),
        height: 72,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }
}