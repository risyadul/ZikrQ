// lib/presentation/widgets/surah_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';
import 'package:zikrq/presentation/widgets/status_bottom_sheet.dart';

class SurahTile extends StatefulWidget {
  const SurahTile({required this.surah, required this.onTap, super.key});
  final Surah surah;
  final VoidCallback onTap;

  @override
  State<SurahTile> createState() => _SurahTileState();
}

class _SurahTileState extends State<SurahTile> {
  double _dragOffset = 0;
  static const double _swipeThreshold = 60;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx;
    if (_dragOffset + delta < 0) {
      setState(() {
        _dragOffset = (_dragOffset + delta).clamp(-_swipeThreshold, 0);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset <= -_swipeThreshold) {
      HapticFeedback.lightImpact();
      _resetDrag();
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => StatusBottomSheet(
          surahId: widget.surah.id,
          currentStatus: widget.surah.status,
        ),
      );
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() {
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Swipe hint icon revealed on the right
          Opacity(
            opacity: (-_dragOffset / _swipeThreshold).clamp(0.0, 1.0),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          // Main tile content, slides left
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
                          '${widget.surah.id}',
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
                            Text(
                              widget.surah.name,
                              style: AppTextStyles.surahName,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.surah.totalVerses} ayat · Juz ${widget.surah.juzStart}',
                              style: AppTextStyles.surahMeta,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arabic name
                      Text(
                        widget.surah.nameArabic,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurface,
                          fontFamily: 'Scheherazade New',
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusBadge(status: widget.surah.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
