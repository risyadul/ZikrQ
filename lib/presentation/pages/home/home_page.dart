// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/habit_provider.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/quick_action_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/habit_target_card.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';
import 'package:zikrq/presentation/widgets/review_queue_section.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);
    final recentAsync = ref.watch(recentlyAccessedProvider);
    final needsReviewAsync = ref.watch(needsReviewProvider);
    final dashboardAsync = ref.watch(todayDashboardProvider);
    final quickActionState = ref.watch(quickActionProvider);

    ref.listen<QuickActionOperationState>(quickActionProvider, (
      previous,
      next,
    ) {
      final error = next.error;
      if (error == null || error == previous?.error) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aksi cepat gagal: $error')));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait<void>([
            ref.refresh(memorizationStatsProvider.future).then((_) {}),
            ref.refresh(recentlyAccessedProvider.future).then((_) {}),
            ref.refresh(needsReviewProvider.future).then((_) {}),
            ref.refresh(todayDashboardProvider.future).then((_) {}),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HomeHero(
              queueCount: dashboardAsync.valueOrNull?.reviewQueue.length ?? 0,
              completedAyat: dashboardAsync.valueOrNull?.completedAyat ?? 0,
            ),
            const SizedBox(height: 20),
            dashboardAsync.when(
              loading: () => const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) =>
                  const _ErrorCard(message: 'Gagal memuat dashboard harian'),
              data: (dashboard) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitTargetCard(
                    targetAyat: dashboard.targetAyat,
                    completedAyat: dashboard.completedAyat,
                    streakDays: dashboard.plan.activeDays.length,
                    onContinueMurajaah: () {
                      if (dashboard.reviewQueue.isEmpty) {
                        context.push('/surahs');
                        return;
                      }
                      context.push(
                        '/surahs/${dashboard.reviewQueue.first.surahId}',
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ReviewQueueSection(
                    queue: dashboard.reviewQueue,
                    isActionEnabled: !quickActionState.isLoading,
                    onQuickActionPressed: (task) {
                      ref
                          .read(quickActionProvider.notifier)
                          .updateSingle(
                            surahId: task.surahId,
                            status: MemorizationStatus.inProgress,
                          );
                    },
                  ),
                  if (quickActionState.isLoading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(color: AppColors.primary),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            statsAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) =>
                  const _ErrorCard(message: 'Gagal memuat statistik'),
              data: (stats) => Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress Hafalan', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 6),
                    Text(
                      'Ringkasan perjalanan hafalan saat ini',
                      style: AppTextStyles.translation,
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 12),
                    MemorizationProgressBar(value: stats.memorizedPercent),
                    const SizedBox(height: 14),
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
            recentAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (surahs) {
                if (surahs.isEmpty) return const SizedBox.shrink();
                return _HomeSection(
                  title: 'Terakhir Dibuka',
                  subtitle: 'Lanjutkan dari surah yang terakhir Anda akses.',
                  child: Column(
                    children: surahs
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SurahTile(
                              surah: s,
                              onTap: () => context.push('/surahs/${s.id}'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            needsReviewAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (surahs) {
                if (surahs.isEmpty) return const SizedBox.shrink();
                return _HomeSection(
                  title: 'Perlu Murojaah',
                  subtitle: 'Area yang perlu segera disentuh ulang hari ini.',
                  child: Column(
                    children: surahs
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SurahTile(
                              surah: s,
                              onTap: () => context.push('/surahs/${s.id}'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.queueCount, required this.completedAyat});

  final int queueCount;
  final int completedAyat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surfaceRaised,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkas Hari Ini', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          Text(
            queueCount == 0
                ? 'Semua antrean review hari ini sudah bersih.'
                : '$queueCount antrean review siap dilanjutkan.',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            completedAyat == 0
                ? 'Mulai satu sesi singkat untuk menjaga ritme murajaah.'
                : '$completedAyat ayat sudah diselesaikan hari ini.',
            style: AppTextStyles.translation.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionLabel),
          const SizedBox(height: 6),
          Text(subtitle, style: AppTextStyles.translation),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message, style: AppTextStyles.surahMeta),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
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
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
