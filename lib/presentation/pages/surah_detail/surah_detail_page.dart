// lib/presentation/pages/surah_detail/surah_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/pages/surah_detail/verse_card.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/surah_detail_provider.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';
import 'package:zikrq/presentation/widgets/status_bottom_sheet.dart';

class SurahDetailPage extends ConsumerStatefulWidget {
  const SurahDetailPage({required this.surahId, super.key});
  final int surahId;

  @override
  ConsumerState<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends ConsumerState<SurahDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(memorizationLocalDatasourceProvider)
          .updateLastAccessed(widget.surahId);
    });
  }

  void _showStatusSheet(
    BuildContext context,
    MemorizationStatus currentStatus,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatusBottomSheet(
        surahId: widget.surahId,
        currentStatus: currentStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(surahDetailProvider(widget.surahId));
    final surahListAsync = ref.watch(surahListProvider);

    // Find the current surah for title and status display
    Surah? surah;
    final surahList = surahListAsync.valueOrNull;
    if (surahList != null) {
      final matches = surahList.where((s) => s.id == widget.surahId);
      surah = matches.isNotEmpty ? matches.first : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: surah == null
            ? const Text('Surah')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name),
                  Text(
                    surah.nameArabic,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondary,
                      fontFamily: 'Scheherazade New',
                    ),
                  ),
                ],
              ),
        actions: [
          if (surah != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _showStatusSheet(context, surah!.status),
                child: StatusBadge(status: surah.status),
              ),
            ),
        ],
      ),
      body: versesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: AppTextStyles.surahMeta)),
        data: (versesWithMark) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: versesWithMark.length + 1, // +1 for bismillah header
          itemBuilder: (context, index) {
            // Bismillah header (skip for Surah 1 and Surah 9)
            if (index == 0) {
              if (widget.surahId == 9 || widget.surahId == 1) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arabicVerse.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
              );
            }

            final verseWithMark = versesWithMark[index - 1];
            return VerseCard(
              verseWithMark: verseWithMark,
              onToggleMark: () async {
                await ref
                    .read(toggleVerseMarkUseCaseProvider)
                    .call(widget.surahId, verseWithMark.verse.number);
                ref.invalidate(surahDetailProvider(widget.surahId));
              },
            );
          },
        ),
      ),
    );
  }
}
