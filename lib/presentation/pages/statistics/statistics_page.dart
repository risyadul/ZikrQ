// lib/presentation/pages/statistics/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Total Hafalan', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${stats.memorized}',
                          style: AppTextStyles.headline,
                        ),
                        TextSpan(
                          text: ' / ${stats.total} Surah',
                          style: AppTextStyles.surahMeta,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  MemorizationProgressBar(value: stats.memorizedPercent),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.memorizedVerseCount} ayat telah dihafal',
                    style: AppTextStyles.surahMeta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Per-status breakdown
            Text('Rincian Status', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 10),

            _StatusCard(
              status: MemorizationStatus.memorized,
              count: stats.memorized,
              total: stats.total,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _StatusCard(
              status: MemorizationStatus.inProgress,
              count: stats.inProgress,
              total: stats.total,
              color: AppColors.inProgress,
            ),
            const SizedBox(height: 8),
            _StatusCard(
              status: MemorizationStatus.needsReview,
              count: stats.needsReview,
              total: stats.total,
              color: AppColors.needsReview,
            ),
            const SizedBox(height: 8),
            _StatusCard(
              status: MemorizationStatus.notStarted,
              count: stats.notStarted,
              total: stats.total,
              color: AppColors.notStarted,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.count,
    required this.total,
    required this.color,
  });

  final MemorizationStatus status;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : count / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
