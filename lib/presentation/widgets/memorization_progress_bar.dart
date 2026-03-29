// lib/presentation/widgets/memorization_progress_bar.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';

class MemorizationProgressBar extends StatelessWidget {
  const MemorizationProgressBar({
    required this.value, // 0.0 to 1.0
    super.key,
    this.height = 12,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clampedValue = value.clamp(0.0, 1.0);
        final filledWidth = constraints.maxWidth * clampedValue;
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Track
                Container(
                  width: double.infinity,
                  color: AppColors.surfaceElevated,
                ),
                // Fill with gradient
                Container(
                  width: filledWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC6C6C6), AppColors.primary],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
