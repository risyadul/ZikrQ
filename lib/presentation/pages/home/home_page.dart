// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);
    final recentAsync = ref.watch(recentlyAccessedProvider);
    final needsReviewAsync = ref.watch(needsReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref
            ..invalidate(memorizationStatsProvider)
            ..invalidate(recentlyAccessedProvider)
            ..invalidate(needsReviewProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress card
            statsAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Gagal memuat statistik',
                  style: AppTextStyles.surahMeta,
                ),
              ),
              data: (stats) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress Hafalan', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${stats.memorized}',
                            style: AppTextStyles.headline,
                          ),
                          TextSpan(
                            text: ' / ${AppConstants.totalSurahs} Surah',
                            style: AppTextStyles.surahMeta,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    MemorizationProgressBar(value: stats.memorizedPercent),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatChip(
                          label: 'Sudah Hafal',
                          count: stats.memorized,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Sedang',
                          count: stats.inProgress,
                          color: AppColors.inProgress,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Review',
                          count: stats.needsReview,
                          color: AppColors.needsReview,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recently accessed
            recentAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (surahs) {
                if (surahs.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terakhir Dibuka', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 10),
                    ...surahs.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SurahTile(
                          surah: s,
                          onTap: () => context.push('/surahs/${s.id}'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

            // Needs review
            needsReviewAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (surahs) {
                if (surahs.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perlu Murojaah', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 10),
                    ...surahs.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SurahTile(
                          surah: s,
                          onTap: () => context.push('/surahs/${s.id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
