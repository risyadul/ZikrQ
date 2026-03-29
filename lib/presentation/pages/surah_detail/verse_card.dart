// lib/presentation/pages/surah_detail/verse_card.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/verse_with_mark.dart';

class VerseCard extends StatelessWidget {
  const VerseCard({
    required this.verseWithMark,
    required this.onToggleMark,
    super.key,
  });

  final VerseWithMark verseWithMark;
  final VoidCallback onToggleMark;

  @override
  Widget build(BuildContext context) {
    final verse = verseWithMark.verse;
    final isMarked = verseWithMark.isMarked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isMarked ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        border: isMarked
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
            : Border.all(color: AppColors.outlineBase.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: verse number badge + bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${verse.number}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggleMark,
                child: Icon(
                  isMarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isMarked
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Arabic text — RTL right-aligned
          Text(
            verse.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabicVerse,
          ),
          const SizedBox(height: 24),
          // Horizontal divider (gradient fade)
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0),
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Translation
          Text(verse.translation, style: AppTextStyles.translation),
        ],
      ),
    );
  }
}
