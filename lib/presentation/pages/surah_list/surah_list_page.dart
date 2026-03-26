// lib/presentation/pages/surah_list/surah_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
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
      appBar: AppBar(
        title: const Text('Daftar Surah'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  onChanged: (value) =>
                      ref.read(surahSearchQueryProvider.notifier).state = value,
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari surah...',
                    hintStyle: const TextStyle(color: AppColors.secondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.secondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              // Filter chips
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isActive = activeFilter == filter;
                    return ChoiceChip(
                      label: Text(_filterLabels[index]),
                      selected: isActive,
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        ref.read(surahStatusFilterProvider.notifier).state =
                            filter;
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.secondary,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.notStarted,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: surahListAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: AppTextStyles.surahMeta)),
        data: (surahs) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: surahs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return SurahTile(
              surah: surah,
              onTap: () => context.push('/surahs/${surah.id}'),
            );
          },
        ),
      ),
    );
  }
}
