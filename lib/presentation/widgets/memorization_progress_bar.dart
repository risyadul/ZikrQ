// lib/presentation/widgets/memorization_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';

class MemorizationProgressBar extends StatelessWidget {
  const MemorizationProgressBar({
    required this.value, // 0.0 to 1.0
    super.key,
    this.height = 6,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: AppColors.notStarted.withValues(alpha: 0.4),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: height,
      ),
    );
  }
}
