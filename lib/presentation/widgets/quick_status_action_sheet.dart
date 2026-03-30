import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Quick Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(color: AppColors.notStarted),
            ...statuses.map(
              (status) => ListTile(
                key: Key('quick-status-${status.name}'),
                enabled: !operationState.isLoading,
                title: Text(
                  _labelFor(status),
                  style: TextStyle(
                    color: status == lastUsedStatus
                        ? AppColors.primary
                        : AppColors.onSurface,
                    fontWeight: status == lastUsedStatus
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
                subtitle: status == currentStatus
                    ? const Text('Current status')
                    : null,
                trailing: status == lastUsedStatus
                    ? const Icon(Icons.flash_on, color: AppColors.primary)
                    : null,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await ref
                      .read(quickActionProvider.notifier)
                      .updateSingle(surahId: surahId, status: status);
                  final nextState = ref.read(quickActionProvider);
                  if (context.mounted) {
                    if (nextState.error == null) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Quick action failed: ${nextState.error}',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(MemorizationStatus status) => switch (status) {
    MemorizationStatus.notStarted => 'Not Started',
    MemorizationStatus.inProgress => 'In Progress',
    MemorizationStatus.memorized => 'Memorized',
    MemorizationStatus.needsReview => 'Needs Review',
  };
}
