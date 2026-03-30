import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/review_task.dart';

class ReviewQueueSection extends StatelessWidget {
  const ReviewQueueSection({
    required this.queue,
    required this.onQuickActionPressed,
    super.key,
    this.isActionEnabled = true,
    this.titleBuilder,
  });

  final List<ReviewTask> queue;
  final ValueChanged<ReviewTask> onQuickActionPressed;
  final bool isActionEnabled;
  final String Function(ReviewTask task)? titleBuilder;

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Antrean Murajaah', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 10),
        ...queue.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ReviewQueueItem(
              task: task,
              title: titleBuilder?.call(task) ?? 'Surah ${task.surahId}',
              onQuickActionPressed: onQuickActionPressed,
              isActionEnabled: isActionEnabled,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewQueueItem extends StatelessWidget {
  const _ReviewQueueItem({
    required this.task,
    required this.title,
    required this.onQuickActionPressed,
    required this.isActionEnabled,
  });

  final ReviewTask task;
  final String title;
  final ValueChanged<ReviewTask> onQuickActionPressed;
  final bool isActionEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.notStarted.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.surahName),
                const SizedBox(height: 2),
                Text(
                  'Prioritas ${task.priorityScore}',
                  style: AppTextStyles.surahMeta,
                ),
              ],
            ),
          ),
          OutlinedButton(
            key: ValueKey('review-quick-action-${task.id}'),
            onPressed: isActionEnabled
                ? () => onQuickActionPressed(task)
                : null,
            child: const Text('Aksi Cepat'),
          ),
        ],
      ),
    );
  }
}
