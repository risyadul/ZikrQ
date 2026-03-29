// lib/presentation/widgets/surah_tile.dart
import 'dart:async';

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
      unawaited(HapticFeedback.lightImpact());
      _resetDrag();
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => StatusBottomSheet(
          surahId: widget.surah.id,
          currentStatus: widget.surah.status,
        ),
      );
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() => setState(() => _dragOffset = 0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Swipe hint icon
          Opacity(
            opacity: (-_dragOffset / _swipeThreshold).clamp(0.0, 1.0),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          // Main tile
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Number badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.surah.id}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.surah.name,
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${widget.surah.totalVerses} Ayat',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: AppColors.onSurfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: widget.surah.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Arabic name
                      Text(
                        widget.surah.nameArabic,
                        style: AppTextStyles.arabicList,
                      ),
                      const SizedBox(width: 12),
                      // Status icon (bookmark-style)
                      Icon(
                        Icons.bookmark_outline,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        size: 18,
                      ),
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
