// lib/presentation/pages/surah_list/surah_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/quick_action_provider.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class SurahListPage extends ConsumerStatefulWidget {
  const SurahListPage({super.key});

  @override
  ConsumerState<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends ConsumerState<SurahListPage> {
  final Set<int> _selectedSurahIds = <int>{};
  bool _isBulkMode = false;

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

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      _selectedSurahIds.clear();
    });
  }

  void _toggleSelection(int surahId) {
    setState(() {
      if (_selectedSurahIds.contains(surahId)) {
        _selectedSurahIds.remove(surahId);
      } else {
        _selectedSurahIds.add(surahId);
      }
    });
  }

  Future<void> _applyBulkMemorized() async {
    if (ref.read(quickActionProvider).isLoading || _selectedSurahIds.isEmpty) {
      return;
    }

    final selectedIds = _selectedSurahIds.toList()..sort();
    await ref
        .read(quickActionProvider.notifier)
        .updateBulk(
          surahIds: selectedIds,
          status: MemorizationStatus.memorized,
        );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(surahStatusFilterProvider);
    final surahListAsync = ref.watch(surahListProvider);
    final quickActionState = ref.watch(quickActionProvider);

    ref.listen<QuickActionOperationState>(quickActionProvider, (prev, next) {
      if (_isBulkMode &&
          (prev?.isLoading ?? false) &&
          !next.isLoading &&
          next.error == null) {
        setState(_selectedSurahIds.clear);
      }

      if (_isBulkMode && prev?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quick action failed: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Surah'),
        actions: [
          IconButton(
            key: const Key('toggle-bulk-mode'),
            icon: Icon(
              _isBulkMode ? Icons.close_rounded : Icons.checklist_rounded,
              color: AppColors.onSurface,
            ),
            onPressed: _toggleBulkMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _ListToolbar(
              activeFilter: activeFilter,
              isBulkMode: _isBulkMode,
              onFilterSelected: (filter) {
                HapticFeedback.lightImpact();
                ref.read(surahStatusFilterProvider.notifier).state = filter;
              },
            ),
          ),
          Expanded(
            child: surahListAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: AppTextStyles.surahMeta),
              ),
              data: (surahs) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: surahs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  final isSelected = _selectedSurahIds.contains(surah.id);

                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: SurahTile(
                          surah: surah,
                          enableQuickActions: !_isBulkMode,
                          onTap: () {
                            if (_isBulkMode) {
                              _toggleSelection(surah.id);
                              return;
                            }
                            context.push('/surahs/${surah.id}');
                          },
                        ),
                      ),
                      if (_isBulkMode)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 10,
                          child: Center(
                            child: InkWell(
                              key: Key('surah-select-${surah.id}'),
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => _toggleSelection(surah.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.14,
                                        )
                                      : AppColors.surface.withValues(
                                          alpha: 0.9,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isBulkMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mode bulk aktif',
                              style: AppTextStyles.surahName.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedSurahIds.length} selected',
                              style: AppTextStyles.surahMeta,
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        key: const Key('bulk-action-memorized'),
                        onPressed:
                            _selectedSurahIds.isEmpty ||
                                quickActionState.isLoading
                            ? null
                            : _applyBulkMemorized,
                        icon: quickActionState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.done_all_rounded),
                        label: const Text('Memorized'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _ListToolbar extends ConsumerWidget {
  const _ListToolbar({
    required this.activeFilter,
    required this.isBulkMode,
    required this.onFilterSelected,
  });

  final MemorizationStatus? activeFilter;
  final bool isBulkMode;
  final ValueChanged<MemorizationStatus?> onFilterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            isBulkMode
                ? 'Pilih beberapa surah untuk update massal.'
                : 'Cari dan filter surah dengan lebih cepat.',
            style: AppTextStyles.translation.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) =>
                ref.read(surahSearchQueryProvider.notifier).state = value,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: const InputDecoration(
              hintText: 'Cari surah...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _SurahListPageState._filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _SurahListPageState._filters[index];
                final isActive = activeFilter == filter;
                return ChoiceChip(
                  label: Text(_SurahListPageState._filterLabels[index]),
                  selected: isActive,
                  onSelected: (_) => onFilterSelected(filter),
                  selectedColor: AppColors.primary.withValues(alpha: 0.18),
                  backgroundColor: AppColors.surfaceRaised,
                  labelStyle: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: isActive ? AppColors.primary : AppColors.outline,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
