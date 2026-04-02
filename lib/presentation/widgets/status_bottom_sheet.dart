// lib/presentation/widgets/status_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';

class StatusBottomSheet extends ConsumerWidget {
  const StatusBottomSheet({
    required this.surahId,
    required this.currentStatus,
    super.key,
  });

  final int surahId;
  final MemorizationStatus currentStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const statuses = MemorizationStatus.values;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text('Ubah Status Hafalan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Geser untuk akses cepat atau pilih status secara manual di sini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.translation,
              ),
              const SizedBox(height: 16),
              ...statuses.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StatusOption(
                    status: status,
                    isCurrent: status == currentStatus,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(updateMemorizationStatusUseCaseProvider)
                          .call(surahId, status);
                      if (context.mounted) {
                        ref
                          ..invalidate(surahListProvider)
                          ..invalidate(memorizationStatsProvider)
                          ..invalidate(recentlyAccessedProvider)
                          ..invalidate(needsReviewProvider);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.isCurrent,
    required this.onTap,
  });

  final MemorizationStatus status;
  final bool isCurrent;
  final VoidCallback onTap;

  Color get _accent => switch (status) {
    MemorizationStatus.memorized => AppColors.primary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  IconData get _icon => switch (status) {
    MemorizationStatus.notStarted => Icons.radio_button_unchecked_rounded,
    MemorizationStatus.inProgress => Icons.timelapse_rounded,
    MemorizationStatus.memorized => Icons.check_circle_rounded,
    MemorizationStatus.needsReview => Icons.priority_high_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isCurrent ? accent : AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.label,
                  style: AppTextStyles.surahName.copyWith(
                    color: isCurrent ? accent : AppColors.onSurface,
                  ),
                ),
              ),
              if (isCurrent)
                const Icon(Icons.check_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
