// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      onSurface: AppColors.onSurface,
      secondary: AppColors.secondary,
      error: AppColors.needsReview,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      iconTheme: IconThemeData(color: AppColors.secondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: TextTheme(bodyMedium: AppTextStyles.translation),
  );
}
