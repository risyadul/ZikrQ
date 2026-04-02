import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/quick_action_provider.dart';

class QuickStatusActionSheet extends ConsumerWidget {
  const QuickStatusActionSheet({
    required this.surahId,
    required this.currentStatus,
    super.key,
  });

  final int surahId;
  final MemorizationStatus currentStatus;

  static const _allActions = <MemorizationStatus>[
    MemorizationStatus.notStarted,
    MemorizationStatus.inProgress,
    MemorizationStatus.memorized,
    MemorizationStatus.needsReview,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operationState = ref.watch(quickActionProvider);
    final lastUsedAsync = ref.watch(lastUsedStatusActionProvider);
    final lastUsedStatus = lastUsedAsync.valueOrNull;

    final statuses = [..._allActions];
    if (lastUsedStatus != null) {
      statuses
        ..remove(lastUsedStatus)
        ..insert(0, lastUsedStatus);
    }

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
              Text('Aksi Cepat', style: AppTextStyles.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Pilih status yang ingin diterapkan dengan sekali tap.',
                textAlign: TextAlign.center,
                style: AppTextStyles.translation,
              ),
              if (operationState.error != null) ...[
                const SizedBox(height: 14),
                _QuickActionErrorBanner(message: operationState.error!),
              ],
              const SizedBox(height: 16),
              ...statuses.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QuickStatusOption(
                    itemKey: Key('quick-status-${status.name}'),
                    status: status,
                    currentStatus: currentStatus,
                    isLastUsed: status == lastUsedStatus,
                    enabled: !operationState.isLoading,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(quickActionProvider.notifier)
                          .updateSingle(surahId: surahId, status: status);
                      final nextState = ref.read(quickActionProvider);
                      if (context.mounted) {
                        if (nextState.error == null) {
                          Navigator.of(context).pop();
                        }
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

class _QuickActionErrorBanner extends StatelessWidget {
  const _QuickActionErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.needsReview.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.needsReview.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.needsReview,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Quick action failed: $message',
              style: AppTextStyles.translation.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatusOption extends StatelessWidget {
  const _QuickStatusOption({
    required this.status,
    required this.currentStatus,
    required this.isLastUsed,
    required this.enabled,
    required this.itemKey,
    required this.onTap,
  });

  final MemorizationStatus status;
  final MemorizationStatus currentStatus;
  final bool isLastUsed;
  final bool enabled;
  final Key itemKey;
  final VoidCallback onTap;

  Color get _accent => switch (status) {
    MemorizationStatus.notStarted => AppColors.notStarted,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.memorized => AppColors.primary,
    MemorizationStatus.needsReview => AppColors.needsReview,
  };

  IconData get _icon => switch (status) {
    MemorizationStatus.notStarted => Icons.radio_button_unchecked_rounded,
    MemorizationStatus.inProgress => Icons.timelapse_rounded,
    MemorizationStatus.memorized => Icons.check_circle_rounded,
    MemorizationStatus.needsReview => Icons.priority_high_rounded,
  };

  String get _supportingText => switch (status) {
    MemorizationStatus.notStarted =>
      'Belum mulai sesi hafalan untuk surah ini.',
    MemorizationStatus.inProgress => 'Masih aktif diulang dan disetorkan.',
    MemorizationStatus.memorized => 'Sudah kuat dan masuk capaian hafal.',
    MemorizationStatus.needsReview => 'Perlu diprioritaskan untuk murojaah.',
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Material(
      key: itemKey,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: status == currentStatus ? accent : AppColors.outline,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            status.label,
                            style: AppTextStyles.surahName.copyWith(
                              color: status == currentStatus
                                  ? accent
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isLastUsed)
                          const Icon(
                            Icons.flash_on_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == currentStatus
                          ? 'Status saat ini'
                          : _supportingText,
                      style: AppTextStyles.translation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
