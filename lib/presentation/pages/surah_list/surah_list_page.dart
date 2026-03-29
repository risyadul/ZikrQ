// lib/presentation/pages/surah_list/surah_list_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class SurahListPage extends ConsumerWidget {
  const SurahListPage({super.key});

  static const _filters = <MemorizationStatus?>[
    null,
    MemorizationStatus.memorized,
    MemorizationStatus.inProgress,
    MemorizationStatus.needsReview,
    MemorizationStatus.notStarted,
  ];

  static const _filterLabels = [
    'Semua',
    'Sudah Hafal',
    'Sedang Dihafal',
    'Perlu Murojaah',
    'Belum Mulai',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(surahStatusFilterProvider);
    final surahListAsync = ref.watch(surahListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Glass AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            title: const Text(
              'ZIKRQ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppColors.onSurface,
              ),
            ),
            centerTitle: false,
          ),

          // Page title + subtitle
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftar Surah', style: AppTextStyles.displayMedium),
                  SizedBox(height: 8),
                  Text(
                    'Lanjutkan perjalanan hafalanmu.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: (value) =>
                    ref.read(surahSearchQueryProvider.notifier).state = value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari surah...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineBase.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = activeFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(surahStatusFilterProvider.notifier).state =
                          filter;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.onSurface
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _filterLabels[index],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isActive
                              ? AppColors.background
                              : AppColors.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Surah list
          surahListAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e', style: AppTextStyles.bodySmall),
              ),
            ),
            data: (surahs) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // First inProgress surah gets the featured card
                  if (index == 0 &&
                      surahs.isNotEmpty &&
                      surahs.first.status == MemorizationStatus.inProgress) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _FeaturedSurahCard(
                        surah: surahs.first,
                        onTap: () => context.push('/surahs/${surahs.first.id}'),
                      ),
                    );
                  }
                  final surah = surahs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SurahTile(
                      surah: surah,
                      onTap: () => context.push('/surahs/${surah.id}'),
                    ),
                  );
                }, childCount: surahs.length),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSurahCard extends StatelessWidget {
  const _FeaturedSurahCard({required this.surah, required this.onTap});
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
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Number badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.id}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(surah.name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${surah.totalVerses} Ayat',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.inProgress,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(surah.nameArabic, style: AppTextStyles.arabicFeatured),
              ],
            ),
            const SizedBox(height: 20),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.inProgress.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Sedang Dihafal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.inProgress,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const MemorizationProgressBar(value: 0.45),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '45% Hafal',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${surah.totalVerses} Ayat',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
