// lib/presentation/widgets/status_bottom_sheet.dart
import 'dart:async';

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

  Color _statusColor(MemorizationStatus status) => switch (status) {
    MemorizationStatus.memorized => AppColors.secondary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ubah Status', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              ...MemorizationStatus.values.map((status) {
                final color = _statusColor(status);
                final isActive = status == currentStatus;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.circle, color: color, size: 12),
                  ),
                  title: Text(
                    status.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isActive ? color : AppColors.onSurface,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check_rounded, color: color, size: 18)
                      : null,
                  onTap: () async {
                    unawaited(HapticFeedback.lightImpact());
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
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
