// lib/presentation/widgets/surah_tile.dart
import 'package:flutter/material.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';

class SurahTile extends StatelessWidget {
  const SurahTile({required this.surah, required this.onTap, super.key});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Surah number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${surah.id}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surah.name, style: AppTextStyles.surahName),
                    const SizedBox(height: 2),
                    Text(
                      '${surah.totalVerses} ayat · Juz ${surah.juzStart}',
                      style: AppTextStyles.surahMeta,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arabic name
              Text(
                surah.nameArabic,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurface,
                  fontFamily: 'Scheherazade New',
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(status: surah.status),
            ],
          ),
        ),
      ),
    );
  }
}
