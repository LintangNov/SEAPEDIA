import 'package:flutter/material.dart';

class AppColors {
  static const Color oceanBlue = Color(0xFF8CC0EB);
  static const Color lightWater = Color(0xFFBFDDF0);
  static const Color sand = Color(0xFFFFEBCC);
  static const Color paleSun = Color(0xFFFFF9D2);

  static const Color textPrimaryLight = Color(0xFF102A43);
  static const Color textSecondaryLight = Color(0xFF334E68);
  static const Color bgLight = Color(0xFFFFFFFF);

  static const Color deepSpace = Color(0xFF0A0F1D);
  static const Color midnightSea = Color(0xFF161F33);
  static const Color bioluminescence = Color(0xFF70B7FD);
  static const Color starlight = Color(0xFFFCE2A6);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color scaffoldBgLight = Color(0xFFF4F7FA);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.oceanBlue,
        onPrimary: AppColors.textPrimaryLight,
        secondary: AppColors.sand,
        onSecondary: AppColors.textPrimaryLight,
        surface: AppColors.bgLight,
        onSurface: AppColors.textPrimaryLight,
        primaryContainer: AppColors.lightWater,
        onPrimaryContainer: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.paleSun,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.oceanBlue,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.oceanBlue,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, color: AppColors.textPrimaryLight),
        displayMedium: TextStyle(fontSize: 45, color: AppColors.textPrimaryLight),
        displaySmall: TextStyle(fontSize: 36, color: AppColors.textPrimaryLight),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.bioluminescence,
        onPrimary: AppColors.deepSpace,
        secondary: AppColors.starlight,
        onSecondary: AppColors.deepSpace,
        surface: AppColors.midnightSea,
        onSurface: AppColors.textPrimaryDark,
        primaryContainer: Color(0xFF1E2D4A),
        onPrimaryContainer: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.deepSpace,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightSea,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bioluminescence,
          foregroundColor: AppColors.deepSpace,
          elevation: 2,
          shadowColor: AppColors.bioluminescence.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, color: AppColors.textPrimaryDark),
        displayMedium: TextStyle(fontSize: 45, color: AppColors.textPrimaryDark),
        displaySmall: TextStyle(fontSize: 36, color: AppColors.textPrimaryDark),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
      ),
    );
  }
}
