// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const String _latin = 'Poppins';
  static const String _arabic = 'Scheherazade New';

  // --- Display ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1.1,
  );

  // --- Headline ---
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _latin,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // --- Title ---
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // --- Body ---
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _latin,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );

  // --- Label ---
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _latin,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.8,
  );

  // --- Compat aliases ---
  static const TextStyle surahName = titleMedium;
  static const TextStyle surahMeta = bodySmall;
  static const TextStyle sectionLabel = bodySmall;
  static const TextStyle headline = headlineSmall;
  static const TextStyle translation = TextStyle(
    fontFamily: _latin,
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.onSurfaceVariant,
    height: 1.6,
  );

  // --- Arabic ---
  static const TextStyle arabicBismillah = TextStyle(
    fontFamily: _arabic,
    fontSize: 48,
    color: AppColors.onSurface,
    height: 1.8,
  );
  static const TextStyle arabicVerse = TextStyle(
    fontFamily: _arabic,
    fontSize: 36,
    color: AppColors.onSurface,
    height: 2,
  );
  static const TextStyle arabicFeatured = TextStyle(
    fontFamily: _arabic,
    fontSize: 30,
    color: AppColors.onSurfaceVariant,
    height: 1.6,
  );
  static const TextStyle arabicInline = TextStyle(
    fontFamily: _arabic,
    fontSize: 24,
    color: AppColors.onSurfaceVariant,
  );
  static const TextStyle arabicList = TextStyle(
    fontFamily: _arabic,
    fontSize: 20,
    color: AppColors.onSurfaceVariant,
  );
  static const TextStyle arabicAppBar = TextStyle(
    fontFamily: _arabic,
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );
}
