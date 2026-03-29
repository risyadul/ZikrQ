// lib/presentation/pages/surah_detail/surah_detail_page.dart
import 'dart:ui';

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

    Surah? surah;
    final surahList = surahListAsync.valueOrNull;
    if (surahList != null) {
      final matches = surahList.where((s) => s.id == widget.surahId);
      surah = matches.isNotEmpty ? matches.first : null;
    }

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
              leading: const BackButton(color: AppColors.onSurface),
              title: surah == null
                  ? const Text('Surah', style: AppTextStyles.titleLarge)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(surah.name, style: AppTextStyles.titleLarge),
                        Text(
                          surah.nameArabic,
                          style: AppTextStyles.arabicAppBar,
                        ),
                      ],
                    ),
              actions: [
                if (surah != null) ...[
                  GestureDetector(
                    onTap: () => _showStatusSheet(context, surah!.status),
                    child: StatusBadge(status: surah.status),
                  ),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ),
      ),
      body: versesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: AppTextStyles.bodySmall)),
        data: (versesWithMark) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 128),
          itemCount: versesWithMark.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Bismillah header — skip for Surah 1 and 9
              if (widget.surahId == 9 || widget.surahId == 1) {
                return const SizedBox(height: 24);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFC6C6C6), AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arabicBismillah.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0),
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'IN THE NAME OF ALLAH, THE MOST GRACIOUS, THE MOST MERCIFUL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
