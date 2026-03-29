// lib/presentation/pages/home/home_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);
    final recentAsync = ref.watch(recentlyAccessedProvider);
    final needsReviewAsync = ref.watch(needsReviewProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref
            ..invalidate(memorizationStatsProvider)
            ..invalidate(recentlyAccessedProvider)
            ..invalidate(needsReviewProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Frosted glass AppBar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppConstants.appName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.onSurface,
                ),
              ),
              centerTitle: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero progress card
                  statsAsync.when(
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stats) => _HeroProgressCard(stats: stats),
                  ),
                  const SizedBox(height: 40),

                  // Terakhir Dibuka — bento grid
                  recentAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (surahs) {
                      if (surahs.isEmpty) return const SizedBox.shrink();
                      return _RecentlyAccessedSection(
                        surahs: surahs,
                        onTap: (s) => context.push('/surahs/${s.id}'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Perlu Murojaah
                  needsReviewAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (surahs) {
                      if (surahs.isEmpty) return const SizedBox.shrink();
                      return _MurojaahSection(
                        surahs: surahs,
                        onTap: (s) => context.push('/surahs/${s.id}'),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero progress card ───────────────────────────────────────────────────────

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({required this.stats});
  final MemorizationStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.outlineBase.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OVERVIEW label
          Text(
            'OVERVIEW',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryBright.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // "Progress\nHafalan" heading
          const Text('Progress\nHafalan', style: AppTextStyles.displayMedium),
          const SizedBox(height: 24),
          // Big number row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${stats.memorized}', style: AppTextStyles.displayLarge),
              const SizedBox(width: 8),
              Text(
                '/ ${AppConstants.totalSurahs} Surah',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MemorizationProgressBar(value: stats.memorizedPercent),
          const SizedBox(height: 20),
          // Status chips
          Row(
            children: [
              _StatChip(
                label: 'Sudah Hafal',
                count: stats.memorized,
                color: AppColors.secondary,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Terakhir Dibuka — Bento Grid ─────────────────────────────────────────────

class _RecentlyAccessedSection extends StatelessWidget {
  const _RecentlyAccessedSection({required this.surahs, required this.onTap});
  final List<Surah> surahs;
  final void Function(Surah) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Terakhir Dibuka', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 20),
        // Featured card (first surah)
        _BentoFeaturedCard(
          surah: surahs.first,
          onTap: () => onTap(surahs.first),
        ),
        if (surahs.length > 1) ...[
          const SizedBox(height: 16),
          // Companion cards (2nd and 3rd)
          Row(
            children: [
              for (int i = 1; i < surahs.length.clamp(0, 3); i++) ...[
                if (i > 1) const SizedBox(width: 16),
                Expanded(
                  child: _BentoCompanionCard(
                    surah: surahs[i],
                    onTap: () => onTap(surahs[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _BentoFeaturedCard extends StatelessWidget {
  const _BentoFeaturedCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            // Left: surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SURAH ${surah.id}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(surah.name, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.totalVerses} Ayat · Juz ${surah.juzStart}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right: Arabic name
            Text(surah.nameArabic, style: AppTextStyles.arabicFeatured),
          ],
        ),
      ),
    );
  }
}

class _BentoCompanionCard extends StatelessWidget {
  const _BentoCompanionCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(surah.nameArabic, style: AppTextStyles.arabicInline),
            const SizedBox(height: 8),
            Text(surah.name, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text('${surah.totalVerses} Ayat', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ─── Perlu Murojaah ───────────────────────────────────────────────────────────

class _MurojaahSection extends StatelessWidget {
  const _MurojaahSection({required this.surahs, required this.onTap});
  final List<Surah> surahs;
  final void Function(Surah) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.needsReview.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Perlu Murojaah',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.needsReview,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...surahs.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MurojaahCard(surah: s, onTap: () => onTap(s)),
          ),
        ),
      ],
    );
  }
}

class _MurojaahCard extends StatelessWidget {
  const _MurojaahCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.needsReview.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Circle number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.needsReview.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.id}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.needsReview,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.totalVerses} Ayat',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(surah.nameArabic, style: AppTextStyles.arabicInline),
          ],
        ),
      ),
    );
  }
}
