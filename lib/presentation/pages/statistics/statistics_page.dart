// lib/presentation/pages/statistics/statistics_page.dart
import 'dart:ui';

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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: AppBar(
              backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text('Statistik', style: AppTextStyles.titleLarge),
              centerTitle: false,
            ),
          ),
        ),
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const Center(
          child: Text('Gagal memuat statistik', style: AppTextStyles.bodySmall),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 120),
          children: [
            const SizedBox(height: 16),

            // Hero summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.outlineBase.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  // Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PENCAPAIAN',
                        style: AppTextStyles.labelSmall.copyWith(
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Total Hafalan',
                        style: AppTextStyles.headlineLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Big number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${stats.memorized}',
                        style: AppTextStyles.displayLarge,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${stats.total} Surah',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MemorizationProgressBar(value: stats.memorizedPercent),
                  const SizedBox(height: 12),
                  Text(
                    '${stats.memorizedVerseCount} ayat telah dihafal',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rincian Status heading
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rincian Status', style: AppTextStyles.headlineSmall),
                Text('Bulan ini', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 20),

            // 2x2 grid
            Row(
              children: [
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.memorized,
                    count: stats.memorized,
                    total: stats.total,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.inProgress,
                    count: stats.inProgress,
                    total: stats.total,
                    color: AppColors.inProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.needsReview,
                    count: stats.needsReview,
                    total: stats.total,
                    color: AppColors.needsReview,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.notStarted,
                    count: stats.notStarted,
                    total: stats.total,
                    color: AppColors.notStarted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Activity section placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wawasan Aktivitas', style: AppTextStyles.headlineSmall),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('7', style: AppTextStyles.headlineLarge),
                      SizedBox(width: 8),
                      Text(
                        'Hari Berturut-turut',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGridCard extends StatelessWidget {
  const _StatusGridCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
