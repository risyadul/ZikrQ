// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Background hierarchy
  static const background = Color(0xFF111125);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF0C0C1F);
  static const surfaceElevated = Color(0xFF28283D);
  static const surfaceMuted = Color(0xFF333348);

  // Accent purple
  static const primary = Color(0xFFBFC4ED);
  static const primaryBright = Color(0xFFC0C2F9);

  // Text
  static const onSurface = Color(0xFFE2E0FC);
  static const onSurfaceVariant = Color(0xFFC8C5CD);

  // Status
  static const secondary = Color(0xFFBFC4ED); // memorized
  static const inProgress = Color(0xFFC0C2F9);
  static const needsReview = Color(0xFFFFB4AB);
  static const notStarted = Color(0xFF929097);

  // Nav surfaces (use with .withValues at call site)
  // navBar rgba(26,26,46,0.7) → Color(0xFF1A1A2E) withValues(alpha: 0.7)
  static const navBarBase = Color(0xFF1A1A2E);

  // Card stroke rgba(71,70,76,0.15)
  static const outlineBase = Color(0xFF47464C);
}
