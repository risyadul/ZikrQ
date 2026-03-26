// lib/presentation/widgets/status_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Ubah Status Hafalan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(color: AppColors.notStarted),
            ...MemorizationStatus.values.map(
              (status) => ListTile(
                title: Text(
                  status.label,
                  style: TextStyle(
                    color: status == currentStatus
                        ? AppColors.primary
                        : AppColors.onSurface,
                    fontWeight: status == currentStatus
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
                trailing: status == currentStatus
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await ref
                      .read(updateMemorizationStatusUseCaseProvider)
                      .call(surahId, status);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
