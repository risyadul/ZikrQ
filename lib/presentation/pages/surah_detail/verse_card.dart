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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: isMarked
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text
          Text(
            verse.arabic,
            textAlign: TextAlign.right,
            style: AppTextStyles.arabicVerse,
          ),
          const SizedBox(height: 10),
          // Divider
          const Divider(color: AppColors.notStarted, height: 1),
          const SizedBox(height: 10),
          // Translation + controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.notStarted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${verse.number}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Translation
              Expanded(
                child: Text(
                  verse.translation,
                  style: AppTextStyles.translation,
                ),
              ),
              const SizedBox(width: 8),
              // Mark toggle
              GestureDetector(
                onTap: onToggleMark,
                child: Icon(
                  isMarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isMarked ? AppColors.primary : AppColors.secondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
