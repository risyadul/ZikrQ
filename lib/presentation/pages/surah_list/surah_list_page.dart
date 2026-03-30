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
          prev?.isLoading == true &&
          !next.isLoading &&
          next.error == null) {
        setState(() => _selectedSurahIds.clear());
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
              _isBulkMode ? Icons.close : Icons.checklist,
              color: AppColors.onSurface,
            ),
            onPressed: _toggleBulkMode,
          ),
        ],
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
            final isSelected = _selectedSurahIds.contains(surah.id);

            return Stack(
              children: [
                SurahTile(
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
                if (_isBulkMode)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 8,
                    child: Center(
                      child: InkWell(
                        key: Key('surah-select-${surah.id}'),
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => _toggleSelection(surah.id),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
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
      bottomNavigationBar: _isBulkMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedSurahIds.length} selected',
                        style: AppTextStyles.surahMeta,
                      ),
                    ),
                    FilledButton.icon(
                      key: const Key('bulk-action-memorized'),
                      onPressed:
                          _selectedSurahIds.isEmpty ||
                              quickActionState.isLoading
                          ? null
                          : _applyBulkMemorized,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Memorized'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
