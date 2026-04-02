// lib/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});
  final MemorizationStatus status;

  Color get _color => switch (status) {
    MemorizationStatus.memorized => AppColors.primary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        child: Text(status.label),
      ),
    );
  }
}
