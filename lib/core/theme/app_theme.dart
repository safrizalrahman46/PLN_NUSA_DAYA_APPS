import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      brightness: Brightness.light,
      surface: AppColors.card,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: TextStyles.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyles.titleLarge(AppColors.text),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyles.headlineLarge(AppColors.text),
        displayMedium: TextStyles.headlineMedium(AppColors.text),
        titleLarge: TextStyles.titleLarge(AppColors.text),
        titleMedium: TextStyles.titleMedium(AppColors.text),
        bodyLarge: TextStyles.bodyLarge(AppColors.text),
        bodyMedium: TextStyles.bodyMedium(AppColors.textSoft),
        bodySmall: TextStyles.bodySmall(AppColors.textSoft),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      secondary: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: TextStyles.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyles.titleLarge(Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyles.headlineLarge(Colors.white),
        displayMedium: TextStyles.headlineMedium(Colors.white),
        titleLarge: TextStyles.titleLarge(Colors.white),
        titleMedium: TextStyles.titleMedium(Colors.white),
        bodyLarge: TextStyles.bodyLarge(Colors.white),
        bodyMedium: TextStyles.bodyMedium(const Color(0xFFC8D4E8)),
        bodySmall: TextStyles.bodySmall(const Color(0xFF92A7C5)),
      ),
    );
  }
}
