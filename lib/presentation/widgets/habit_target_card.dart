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
    final remainingAyat = (safeTarget - completedAyat).clamp(0, safeTarget);
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.surfaceRaised,
            AppColors.surface,
            AppColors.surfaceMuted,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Hari Ini', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          Text(
            '$completedAyat / $safeTarget ayat',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remainingAyat == 0
                ? 'Target hari ini sudah tercapai.'
                : 'Tinggal $remainingAyat ayat untuk menutup target hari ini.',
            style: AppTextStyles.translation.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '$streakDays hari',
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  icon: Icons.track_changes_rounded,
                  label: 'Progress',
                  value: '$progressPercent%',
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MemorizationProgressBar(value: progress),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onContinueMurajaah,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Lanjut Murajaah'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.surahMeta),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.surahName.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
