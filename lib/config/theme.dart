import 'package:flutter/material.dart';

/// App color palette - 和風 (墨・金茶・朱・藍)
class AppColors {
  // 墨 (sumi) - backgrounds
  static const Color sumi = Color(0xFF12100E);
  static const Color sumiSurface = Color(0xFF1C1915);
  static const Color sumiCard = Color(0xFF26211A);
  static const Color sumiLine = Color(0xFF3D362B);

  // 生成り (kinari) - text on dark
  static const Color washi = Color(0xFFF2EADB);
  static const Color washiDim = Color(0xFFB9AE9B);

  // 金茶 (kincha) - main accent
  static const Color kin = Color(0xFFC9A24D);
  static const Color kinLight = Color(0xFFE6CB86);

  // 朱 (shu) / 藍 (ai) / 藤 (fuji) / 若竹 (wakatake)
  static const Color shu = Color(0xFFC1442E);
  static const Color shuLight = Color(0xFFDB6A55);
  static const Color shuDark = Color(0xFF7A2618);
  static const Color ai = Color(0xFF3F6289);
  static const Color aiLight = Color(0xFF6F98C2);
  static const Color fuji = Color(0xFF9382B8);
  static const Color wakatake = Color(0xFF7FA463);
  static const Color wakatakeDark = Color(0xFF3B5A2A);

  // Legacy names (kept so existing references keep working)
  static const Color primary = sumi;
  static const Color primaryLight = sumiSurface;
  static const Color primaryDark = Color(0xFF0A0908);
  static const Color accent = kin;
  static const Color success = wakatake;
  static const Color warning = Color(0xFFE0A030);
  static const Color error = shuLight;
  static const Color white = washi;
  static const Color grey100 = Color(0xFFF2EADB);
  static const Color grey300 = Color(0xFFD8CDB8);
  static const Color grey500 = Color(0xFF8C8272);
  static const Color grey700 = Color(0xFF5A5246);
  static const Color grey900 = sumiCard;
  static const Color bgDark = sumi;
  static const Color bgLight = Color(0xFFF5EEDF);
}

/// App Theme configuration
class AppTheme {
  // 明朝系。端末に入っている日本語セリフ体へ順にフォールバックする。
  static const String _fontFamily = 'serif';
  static const List<String> _fontFallback = [
    'Noto Serif CJK JP',
    'Noto Serif JP',
    'Hiragino Mincho ProN',
    'Yu Mincho',
    'serif',
  ];

  static const double _radius = 6;

  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final textTheme = base.textTheme
        .apply(
          bodyColor: AppColors.washi,
          displayColor: AppColors.washi,
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFallback,
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.washi,
          ),
          displayMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.washi,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.washi,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.washi,
          ),
          bodyLarge: const TextStyle(fontSize: 16, color: AppColors.washi),
          bodyMedium: const TextStyle(fontSize: 14, color: AppColors.washiDim),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.washi,
          ),
        );

    const roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radius)),
    );
    final hairline = BorderSide(
      color: AppColors.kin.withOpacity(0.35),
      width: 1,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      primaryColor: AppColors.sumi,
      scaffoldBackgroundColor: AppColors.sumi,
      canvasColor: AppColors.sumi,
      dividerColor: AppColors.sumiLine,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.kin,
        onPrimary: AppColors.sumi,
        secondary: AppColors.shu,
        onSecondary: AppColors.washi,
        tertiary: AppColors.ai,
        surface: AppColors.sumiSurface,
        onSurface: AppColors.washi,
        error: AppColors.shuLight,
        outline: AppColors.sumiLine,
      ),

      textTheme: textTheme,

      cardTheme: CardThemeData(
        color: AppColors.sumiCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: hairline,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kin,
          foregroundColor: AppColors.sumi,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: roundedShape,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kin,
          side: const BorderSide(color: AppColors.kin, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: roundedShape,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.kin),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sumiSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.sumiLine, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.sumiLine, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.kin, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.grey500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sumi,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFallback,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
          color: AppColors.washi,
        ),
        iconTheme: const IconThemeData(color: AppColors.kin),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.kin.withOpacity(0.25),
            width: 1,
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.sumiSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: hairline,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFallback,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: AppColors.washi,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sumiSurface,
        modalBackgroundColor: AppColors.sumiSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.sumiCard,
        contentTextStyle: const TextStyle(color: AppColors.washi),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: hairline,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.sumiLine,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sumiCard,
        selectedColor: AppColors.kin.withOpacity(0.25),
        labelStyle: const TextStyle(color: AppColors.washi),
        side: hairline,
        shape: roundedShape,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.kin,
        textColor: AppColors.washi,
      ),

      iconTheme: const IconThemeData(color: AppColors.washi),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kin,
        linearTrackColor: AppColors.sumiLine,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.kin
              : AppColors.washiDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.kin.withOpacity(0.35)
              : AppColors.sumiLine,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      primaryColor: AppColors.bgLight,
      scaffoldBackgroundColor: AppColors.bgLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.kin,
        secondary: AppColors.shu,
        surface: AppColors.bgLight,
        error: AppColors.shu,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.sumi,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
