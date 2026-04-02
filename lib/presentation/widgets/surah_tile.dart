// lib/presentation/widgets/surah_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/widgets/quick_status_action_sheet.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';
import 'package:zikrq/presentation/widgets/status_bottom_sheet.dart';

class SurahTile extends StatefulWidget {
  const SurahTile({
    required this.surah,
    required this.onTap,
    this.enableQuickActions = true,
    super.key,
  });
  final Surah surah;
  final VoidCallback onTap;
  final bool enableQuickActions;

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
    if (!widget.enableQuickActions) {
      _resetDrag();
      return;
    }

    if (_dragOffset <= -_swipeThreshold) {
      HapticFeedback.lightImpact();
      _resetDrag();
      _showStatusBottomSheet();
    } else {
      _resetDrag();
    }
  }

  void _showStatusBottomSheet() {
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
  }

  void _showQuickStatusActionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => QuickStatusActionSheet(
        surahId: widget.surah.id,
        currentStatus: widget.surah.status,
      ),
    );
  }

  void _resetDrag() {
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final swipeProgress = (-_dragOffset / _swipeThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(left: 28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.12 * swipeProgress,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Opacity(
            opacity: swipeProgress,
            child: Container(
              width: 116,
              padding: const EdgeInsets.only(right: 18),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swipe_left_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ubah status',
                    style: AppTextStyles.surahMeta.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: widget.onTap,
                onLongPress: widget.enableQuickActions
                    ? _showQuickStatusActionSheet
                    : null,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.18),
                                AppColors.primary.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.surah.id}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.surah.name,
                                      style: AppTextStyles.surahName.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (widget.enableQuickActions) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.bolt_rounded,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.surah.totalVerses} ayat · Juz ${widget.surah.juzStart}',
                                style: AppTextStyles.surahMeta,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.surah.nameArabic,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: AppColors.onSurface,
                                        fontFamily: 'Scheherazade New',
                                        height: 1.1,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: StatusBadge(
                                      status: widget.surah.status,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
