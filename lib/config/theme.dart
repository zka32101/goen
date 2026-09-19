import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette - premium Japanese aesthetic (和風)
class AppColors {
  // Primary colors - Japanese ink (墨)
  static const Color primary = Color(0xFF2B2B2B); // 墨色 (sumi-iro)
  static const Color primaryLight = Color(0xFF3D3D3D);
  static const Color primaryDark = Color(0xFF1a1a1a);

  // Accent colors - Japanese gold (金) + bamboo (竹)
  static const Color accent = Color(0xFFD4AF37); // 金 (kin) - Gold
  static const Color bambooGreen = Color(0xFF008000); // 竹色 (takeniro) - Bamboo green
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

      // Typography - Japanese serif fonts via Google Fonts
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerifJp(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displayMedium: GoogleFonts.notoSerifJp(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        // headlineSmall is the most-referenced variant across the app
        // (33 call sites) — was missing entirely, so it silently fell
        // back to Flutter's default font on every screen using it.
        headlineLarge: GoogleFonts.notoSerifJp(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.notoSerifJp(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineSmall: GoogleFonts.notoSerifJp(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.notoSerifJp(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.notoSerifJp(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.notoSerifJp(
          fontSize: 16,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.notoSerifJp(
          fontSize: 14,
          color: AppColors.grey300,
        ),
        labelLarge: GoogleFonts.notoSerifJp(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        // 以前はここで未定義だったバリアント（多くの画面がbodySmall/
        // titleSmall等を直接参照している）は、Flutter標準の
        // デフォルトフォントにフォールバックしてしまい、和文明朝体が
        // 適用されない箇所があったため追加する。
        displaySmall: GoogleFonts.notoSerifJp(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleSmall: GoogleFonts.notoSerifJp(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodySmall: GoogleFonts.notoSerifJp(
          fontSize: 12,
          color: AppColors.grey300,
        ),
        labelMedium: GoogleFonts.notoSerifJp(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        labelSmall: GoogleFonts.notoSerifJp(
          fontSize: 11,
          color: AppColors.grey300,
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
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
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

      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerifJp(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bodyMedium: GoogleFonts.notoSerifJp(
          fontSize: 14,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
