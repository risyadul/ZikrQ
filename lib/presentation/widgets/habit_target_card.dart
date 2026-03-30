import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';

class HabitTargetCard extends StatelessWidget {
  const HabitTargetCard({
    required this.targetAyat,
    required this.completedAyat,
    required this.streakDays,
    required this.onContinueMurajaah,
    super.key,
  });

  final int targetAyat;
  final int completedAyat;
  final int streakDays;
  final VoidCallback onContinueMurajaah;

  @override
  Widget build(BuildContext context) {
    final safeTarget = targetAyat <= 0 ? 1 : targetAyat;
    final progress = (completedAyat / safeTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Hari Ini', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedAyat / $safeTarget ayat',
                  style: AppTextStyles.headline.copyWith(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$streakDays hari',
                  style: AppTextStyles.surahMeta.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MemorizationProgressBar(value: progress),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinueMurajaah,
              child: const Text('Lanjut Murajaah'),
            ),
          ),
        ],
      ),
    );
  }
}
