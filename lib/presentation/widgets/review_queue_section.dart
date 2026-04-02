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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Antrean Murajaah', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 6),
                    Text(
                      'Prioritas hafalan untuk sesi hari ini',
                      style: AppTextStyles.translation,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${queue.length} tugas',
                  style: AppTextStyles.surahMeta.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...queue.asMap().entries.map((entry) {
            final task = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == queue.length - 1 ? 0 : 10,
              ),
              child: _ReviewQueueItem(
                task: task,
                title: titleBuilder?.call(task) ?? 'Surah ${task.surahId}',
                onQuickActionPressed: onQuickActionPressed,
                isActionEnabled: isActionEnabled,
              ),
            );
          }),
        ],
      ),
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
    final sourceLabel = switch (task.source) {
      ReviewTaskSource.needsReview => 'Perlu review',
      ReviewTaskSource.streakRecovery => 'Recovery',
      ReviewTaskSource.manual => 'Manual',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedAction = constraints.maxWidth < 360;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: useStackedAction
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewQueueContent(
                      title: title,
                      sourceLabel: sourceLabel,
                      priorityScore: task.priorityScore,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: ValueKey('review-quick-action-${task.id}'),
                        onPressed: isActionEnabled
                            ? () => onQuickActionPressed(task)
                            : null,
                        child: const Text('Aksi Cepat'),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ReviewQueueContent(
                        title: title,
                        sourceLabel: sourceLabel,
                        priorityScore: task.priorityScore,
                      ),
                    ),
                    const SizedBox(width: 12),
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
      },
    );
  }
}

class _ReviewQueueContent extends StatelessWidget {
  const _ReviewQueueContent({
    required this.title,
    required this.sourceLabel,
    required this.priorityScore,
  });

  final String title;
  final String sourceLabel;
  final int priorityScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.surahName),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaTag(
                    icon: Icons.bolt_rounded,
                    label: 'Prioritas $priorityScore',
                    accent: AppColors.primary,
                  ),
                  _MetaTag(
                    icon: Icons.flag_rounded,
                    label: sourceLabel,
                    accent: AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.surahMeta.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
