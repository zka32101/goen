import 'package:flutter/material.dart';

/// App color palette - premium Japanese aesthetic
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1a1a1a); // Deep black (和紙基調)
  static const Color primaryLight = Color(0xFF2d2d2d);
  static const Color primaryDark = Color(0xFF0d0d0d);

  // Accent colors
  static const Color accent = Color(0xFFD4AF37); // Gold (碁盤の象徴)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  // Neutral colors
  static const Color white = Color(0xFFFFFBF0); // Warm white (和紙)
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);

  // Background - Japanese washi paper texture
  static const Color bgDark = Color(0xFF1a1a1a);
  static const Color bgLight = Color(0xFFFFFBF0);
}

/// App Theme configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.primaryLight,
        surface: AppColors.primaryLight,
        background: AppColors.bgDark,
        error: AppColors.error,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.grey300,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.grey500,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.grey500,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(color: AppColors.grey500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.white,
      scaffoldBackgroundColor: AppColors.bgLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.grey100,
        surface: AppColors.white,
        background: AppColors.bgLight,
        error: AppColors.error,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
