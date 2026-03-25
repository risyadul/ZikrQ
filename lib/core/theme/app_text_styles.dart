// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get arabicVerse => GoogleFonts.scheherazadeNew(
    fontSize: 22,
    height: 2.0,
    color: AppColors.onSurface,
  );

  static TextStyle get translation =>
      const TextStyle(fontSize: 13, color: AppColors.secondary, height: 1.5);

  static TextStyle get surahName => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get surahMeta =>
      const TextStyle(fontSize: 12, color: AppColors.secondary);

  static TextStyle get sectionLabel => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.secondary,
  );

  static TextStyle get headline => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
