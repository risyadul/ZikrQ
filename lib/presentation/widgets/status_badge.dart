// lib/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});
  final MemorizationStatus status;

  Color get _color => switch (status) {
    MemorizationStatus.memorized => AppColors.secondary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  String get _label => switch (status) {
    MemorizationStatus.memorized => 'HAFAL',
    MemorizationStatus.inProgress => 'SEDANG',
    MemorizationStatus.needsReview => 'MUROJAAH',
    MemorizationStatus.notStarted => 'BELUM',
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontFamily: 'Poppins',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        child: Text(_label),
      ),
    );
  }
}
