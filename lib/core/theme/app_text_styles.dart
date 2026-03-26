// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const String _arabicFamily = 'Scheherazade New';
  static const String _latinFamily = 'Poppins';

  static TextStyle get arabicVerse => const TextStyle(
    fontFamily: _arabicFamily,
    fontSize: 22,
    height: 2,
    color: AppColors.onSurface,
  );

  static TextStyle get translation => const TextStyle(
    fontFamily: _latinFamily,
    fontSize: 13,
    color: AppColors.secondary,
    height: 1.5,
  );

  static TextStyle get surahName => const TextStyle(
    fontFamily: _latinFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get surahMeta => const TextStyle(
    fontFamily: _latinFamily,
    fontSize: 12,
    color: AppColors.secondary,
  );

  static TextStyle get sectionLabel => const TextStyle(
    fontFamily: _latinFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.secondary,
  );

  static TextStyle get headline => const TextStyle(
    fontFamily: _latinFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
