# ZikrQ Polish Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply four UX/polish improvements to ZikrQ: fix stale state after status change, fix filter chip vertical alignment, switch to Poppins font, and add haptic feedback + animations + swipe-left gesture on surah tiles.

**Architecture:** All changes are in `lib/` — no new architecture layers. State fix adds provider invalidation to the existing bottom sheet. Font change registers TTF assets and updates `app_text_styles.dart` + `app_theme.dart`. Interactivity converts `SurahTile` to `StatefulWidget` and wraps it in a `GestureDetector`.

**Tech Stack:** Flutter, Riverpod, `google_fonts` (already in pubspec), `HapticFeedback` (flutter/services.dart)

---

## File Map

| File | Change |
|------|--------|
| `lib/presentation/widgets/status_bottom_sheet.dart` | + provider invalidation, + haptic on tap |
| `lib/presentation/pages/surah_list/surah_list_page.dart` | fix SizedBox height + padding, + haptic on chip tap |
| `pubspec.yaml` | + font assets declaration |
| `assets/fonts/Poppins/` | new — Poppins TTF files |
| `assets/fonts/SchmaherazadeNew/` | new — Scheherazade New TTF file |
| `lib/core/theme/app_text_styles.dart` | use fontFamily: 'Poppins' + remove google_fonts for Poppins |
| `lib/core/theme/app_theme.dart` | add fontFamily: 'Poppins' to ThemeData |
| `lib/presentation/widgets/status_badge.dart` | AnimatedContainer for color |
| `lib/presentation/widgets/memorization_progress_bar.dart` | TweenAnimationBuilder for value |
| `lib/presentation/widgets/surah_tile.dart` | StatefulWidget + GestureDetector swipe + drag reveal |

---

## Task 1: Fix State Refresh Bug + Haptic in StatusBottomSheet

**Files:**
- Modify: `lib/presentation/widgets/status_bottom_sheet.dart`

- [ ] **Step 1: Add missing imports**

  In `status_bottom_sheet.dart`, add these imports at the top (after existing imports):

  ```dart
  import 'package:flutter/services.dart';
  import 'package:zikrq/presentation/providers/home_provider.dart';
  import 'package:zikrq/presentation/providers/stats_provider.dart';
  import 'package:zikrq/presentation/providers/surah_list_provider.dart';
  ```

- [ ] **Step 2: Add haptic + provider invalidation to onTap**

  Replace the existing `onTap` callback (lines 53–58) with:

  ```dart
  onTap: () async {
    HapticFeedback.lightImpact();
    await ref
        .read(updateMemorizationStatusUseCaseProvider)
        .call(surahId, status);
    if (context.mounted) {
      ref.invalidate(surahListProvider);
      ref.invalidate(memorizationStatsProvider);
      ref.invalidate(recentlyAccessedProvider);
      ref.invalidate(needsReviewProvider);
      Navigator.of(context).pop();
    }
  },
  ```

- [ ] **Step 3: Run the app and verify**

  Hot-restart. Open the surah list, tap a surah tile to open its detail page, change the status via the bottom sheet, navigate back — the surah list and home page should immediately reflect the new status without needing to restart.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/presentation/widgets/status_bottom_sheet.dart
  git commit -m "fix: invalidate providers and add haptic after status change"
  ```

---

## Task 2: Fix Filter Tab Vertical Alignment + Haptic on Chip Tap

**Files:**
- Modify: `lib/presentation/pages/surah_list/surah_list_page.dart`

- [ ] **Step 1: Fix SizedBox height and ListView padding**

  In `surah_list_page.dart`, find the filter chips block (around line 70). Make two changes:

  1. Change `SizedBox(height: 44,` → `SizedBox(height: 48,`
  2. Change `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6,)` → `padding: const EdgeInsets.symmetric(horizontal: 16)`

- [ ] **Step 2: Add import for HapticFeedback**

  Add to imports:
  ```dart
  import 'package:flutter/services.dart';
  ```

- [ ] **Step 3: Add haptic on chip tap**

  Find `onSelected` callback on the `ChoiceChip`. Replace:
  ```dart
  onSelected: (_) =>
      ref.read(surahStatusFilterProvider.notifier).state = filter,
  ```
  with:
  ```dart
  onSelected: (_) {
    HapticFeedback.lightImpact();
    ref.read(surahStatusFilterProvider.notifier).state = filter;
  },
  ```

- [ ] **Step 4: Verify visually**

  Hot-reload. The filter chips should appear centered and symmetrical within their row.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/presentation/pages/surah_list/surah_list_page.dart
  git commit -m "fix: center filter chips and add haptic feedback on tap"
  ```

---

## Task 3: Poppins Font

**Files:**
- `pubspec.yaml`
- `assets/fonts/Poppins/` (new directory)
- `assets/fonts/SchmaherazadeNew/` (new directory)
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Download Poppins from Google Fonts**

  Go to https://fonts.google.com/specimen/Poppins and download the family.
  From the zip, copy these TTF files into `assets/fonts/Poppins/`:
  - `Poppins-Regular.ttf`
  - `Poppins-Italic.ttf`
  - `Poppins-Medium.ttf`
  - `Poppins-MediumItalic.ttf`
  - `Poppins-SemiBold.ttf`
  - `Poppins-SemiBoldItalic.ttf`
  - `Poppins-Bold.ttf`
  - `Poppins-BoldItalic.ttf`

  ```bash
  mkdir -p assets/fonts/Poppins
  ```

- [ ] **Step 2: Download Scheherazade New from Google Fonts**

  Go to https://fonts.google.com/specimen/Scheherazade+New and download the family.
  From the zip, copy into `assets/fonts/SchmaherazadeNew/`:
  - `SchmaherazadeNew-Regular.ttf`
  - `SchmaherazadeNew-Bold.ttf` (if available)

  ```bash
  mkdir -p assets/fonts/SchmaherazadeNew
  ```

  > Note: The exact file names from Google Fonts may vary slightly. Use whatever `*.ttf` files are in the downloaded zip.

- [ ] **Step 3: Register fonts in pubspec.yaml**

  In `pubspec.yaml`, replace the `flutter:` section (currently just `uses-material-design: true` and `assets:`) with:

  ```yaml
  flutter:
    uses-material-design: true

    assets:
      - assets/data/quran_id.json

    fonts:
      - family: Poppins
        fonts:
          - asset: assets/fonts/Poppins/Poppins-Regular.ttf
          - asset: assets/fonts/Poppins/Poppins-Italic.ttf
            style: italic
          - asset: assets/fonts/Poppins/Poppins-Medium.ttf
            weight: 500
          - asset: assets/fonts/Poppins/Poppins-MediumItalic.ttf
            weight: 500
            style: italic
          - asset: assets/fonts/Poppins/Poppins-SemiBold.ttf
            weight: 600
          - asset: assets/fonts/Poppins/Poppins-SemiBoldItalic.ttf
            weight: 600
            style: italic
          - asset: assets/fonts/Poppins/Poppins-Bold.ttf
            weight: 700
          - asset: assets/fonts/Poppins/Poppins-BoldItalic.ttf
            weight: 700
            style: italic
      - family: Scheherazade New
        fonts:
          - asset: assets/fonts/SchmaherazadeNew/SchmaherazadeNew-Regular.ttf
  ```

  > Adjust the Scheherazade New filename to match the actual file you downloaded.

- [ ] **Step 4: Update app_text_styles.dart**

  Replace the entire content of `lib/core/theme/app_text_styles.dart` with:

  ```dart
  // lib/core/theme/app_text_styles.dart
  import 'package:flutter/material.dart';
  import 'package:zikrq/core/theme/app_colors.dart';

  abstract final class AppTextStyles {
    static const String _arabicFamily = 'Scheherazade New';
    static const String _latinFamily = 'Poppins';

    static TextStyle get arabicVerse => const TextStyle(
      fontFamily: _arabicFamily,
      fontSize: 22,
      height: 2,
      color: AppColors.onSurface,
    );

    static TextStyle get translation => const TextStyle(
      fontFamily: _latinFamily,
      fontSize: 13,
      color: AppColors.secondary,
      height: 1.5,
    );

    static TextStyle get surahName => const TextStyle(
      fontFamily: _latinFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    );

    static TextStyle get surahMeta => const TextStyle(
      fontFamily: _latinFamily,
      fontSize: 12,
      color: AppColors.secondary,
    );

    static TextStyle get sectionLabel => const TextStyle(
      fontFamily: _latinFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.secondary,
    );

    static TextStyle get headline => const TextStyle(
      fontFamily: _latinFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );
  }
  ```

- [ ] **Step 5: Update app_theme.dart to use Poppins as default font**

  In `lib/core/theme/app_theme.dart`, add `fontFamily: 'Poppins'` to `ThemeData` and update the AppBar title style. Replace the existing `AppTheme.dark` getter with:

  ```dart
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      onSurface: AppColors.onSurface,
      secondary: AppColors.secondary,
      error: AppColors.needsReview,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      iconTheme: IconThemeData(color: AppColors.secondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: TextTheme(bodyMedium: AppTextStyles.translation),
  );
  ```

  Also remove the `app_text_styles.dart` import if it triggers an unused import warning (it's still needed for `textTheme`).

- [ ] **Step 6: Run flutter pub get and hot-restart**

  ```bash
  flutter pub get
  ```

  Then run the app. All Latin text should now appear in Poppins. Arabic text (verse display) should still appear in Scheherazade New.

- [ ] **Step 7: Commit**

  ```bash
  git add pubspec.yaml assets/fonts/ lib/core/theme/app_text_styles.dart lib/core/theme/app_theme.dart
  git commit -m "feat: bundle Poppins and Scheherazade New fonts for offline use"
  ```

---

## Task 4: Animate StatusBadge Color

**Files:**
- Modify: `lib/presentation/widgets/status_badge.dart`

- [ ] **Step 1: Replace Container with AnimatedContainer**

  Replace the entire content of `lib/presentation/widgets/status_badge.dart` with:

  ```dart
  // lib/presentation/widgets/status_badge.dart
  import 'package:flutter/material.dart';
  import 'package:zikrq/core/theme/app_colors.dart';
  import 'package:zikrq/domain/entities/memorization_status.dart';

  class StatusBadge extends StatelessWidget {
    const StatusBadge({required this.status, super.key});
    final MemorizationStatus status;

    Color get _color => switch (status) {
      MemorizationStatus.memorized => AppColors.primary,
      MemorizationStatus.inProgress => AppColors.inProgress,
      MemorizationStatus.needsReview => AppColors.needsReview,
      MemorizationStatus.notStarted => AppColors.notStarted,
    };

    @override
    Widget build(BuildContext context) {
      final color = _color;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          child: Text(status.label),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Verify**

  Hot-reload and change a surah's status — the badge color should animate smoothly over 200ms.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/presentation/widgets/status_badge.dart
  git commit -m "feat: animate StatusBadge color transition on status change"
  ```

---

## Task 5: Animate MemorizationProgressBar Value

**Files:**
- Modify: `lib/presentation/widgets/memorization_progress_bar.dart`

- [ ] **Step 1: Wrap with TweenAnimationBuilder**

  Replace the entire content of `lib/presentation/widgets/memorization_progress_bar.dart` with:

  ```dart
  // lib/presentation/widgets/memorization_progress_bar.dart
  import 'package:flutter/material.dart';
  import 'package:zikrq/core/theme/app_colors.dart';

  class MemorizationProgressBar extends StatelessWidget {
    const MemorizationProgressBar({
      required this.value, // 0.0 to 1.0
      super.key,
      this.height = 6,
    });

    final double value;
    final double height;

    @override
    Widget build(BuildContext context) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, animatedValue, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: LinearProgressIndicator(
              value: animatedValue,
              backgroundColor: AppColors.notStarted.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: height,
            ),
          );
        },
      );
    }
  }
  ```

- [ ] **Step 2: Verify**

  The progress bar animates its fill from 0 to the target value on first render and re-animates when the value changes.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/presentation/widgets/memorization_progress_bar.dart
  git commit -m "feat: animate MemorizationProgressBar value with easeOut tween"
  ```

---

## Task 6: Swipe-Left Gesture on SurahTile

**Files:**
- Modify: `lib/presentation/widgets/surah_tile.dart`

This task converts `SurahTile` from `StatelessWidget` to `StatefulWidget` and adds a horizontal swipe gesture that reveals the current status icon and opens `StatusBottomSheet`.

- [ ] **Step 1: Replace surah_tile.dart entirely**

  Replace the full content of `lib/presentation/widgets/surah_tile.dart` with:

  ```dart
  // lib/presentation/widgets/surah_tile.dart
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:zikrq/core/theme/app_colors.dart';
  import 'package:zikrq/core/theme/app_text_styles.dart';
  import 'package:zikrq/domain/entities/memorization_status.dart';
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
    bool _swipeTriggered = false;

    static const double _swipeThreshold = 60.0;
    static const double _maxDrag = 80.0;

    void _onHorizontalDragUpdate(DragUpdateDetails details) {
      if (_swipeTriggered) return;
      final delta = details.delta.dx;
      if (delta < 0) {
        setState(() {
          _dragOffset = (_dragOffset + delta).clamp(-_maxDrag, 0.0);
        });
        // Trigger when threshold reached mid-drag
        if (_dragOffset <= -_swipeThreshold) {
          _triggerSwipe();
        }
      }
    }

    void _onHorizontalDragEnd(DragEndDetails details) {
      if (_swipeTriggered) return;
      setState(() => _dragOffset = 0);
    }

    Future<void> _triggerSwipe() async {
      if (_swipeTriggered) return;
      setState(() {
        _swipeTriggered = true;
        _dragOffset = 0;
      });
      HapticFeedback.lightImpact();
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => StatusBottomSheet(
          surahId: widget.surah.id,
          currentStatus: widget.surah.status,
        ),
      );
      if (mounted) {
        setState(() => _swipeTriggered = false);
      }
    }

    Color _statusColor(MemorizationStatus status) => switch (status) {
      MemorizationStatus.memorized => AppColors.primary,
      MemorizationStatus.inProgress => AppColors.inProgress,
      MemorizationStatus.needsReview => AppColors.needsReview,
      MemorizationStatus.notStarted => AppColors.notStarted,
    };

    IconData _statusIcon(MemorizationStatus status) => switch (status) {
      MemorizationStatus.memorized => Icons.check_circle_outline,
      MemorizationStatus.inProgress => Icons.hourglass_empty,
      MemorizationStatus.needsReview => Icons.refresh,
      MemorizationStatus.notStarted => Icons.radio_button_unchecked,
    };

    @override
    Widget build(BuildContext context) {
      final revealProgress =
          (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0);
      final color = _statusColor(widget.surah.status);

      return GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: ClipRect(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              // Swipe reveal: current status icon slides in from right
              Opacity(
                opacity: revealProgress,
                child: Transform.translate(
                  offset: Offset(16 * (1 - revealProgress), 0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      _statusIcon(widget.surah.status),
                      color: color,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Main tile slides left
              Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: _buildTileContent(),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTileContent() {
      return Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
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
                      Text(widget.surah.name, style: AppTextStyles.surahName),
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
      );
    }
  }
  ```

- [ ] **Step 2: Verify**

  Hot-restart. In the surah list, slowly swipe left on any tile — the current status icon should fade in from the right. When the drag exceeds 60px, haptic fires, the tile snaps back, and the `StatusBottomSheet` opens. After changing status, the list refreshes automatically (Task 1).

- [ ] **Step 3: Commit**

  ```bash
  git add lib/presentation/widgets/surah_tile.dart
  git commit -m "feat: add swipe-left gesture on SurahTile to open status sheet"
  ```

---

## Final Verification

- [ ] **Run the full app and test all 4 improvements end-to-end**

  1. Change a surah's status via the bottom sheet → surah list, stats page, and home page all update immediately
  2. Filter chips on the surah list page are vertically centered
  3. All Latin text uses Poppins; Arabic verse text uses Scheherazade New
  4. Tapping a filter chip produces light haptic
  5. Opening the status bottom sheet and tapping a status option produces light haptic
  6. Swiping left on a surah tile reveals the status icon and triggers haptic + bottom sheet
  7. Status badge color change animates smoothly on status update
  8. Progress bars animate their fill value

- [ ] **Final commit**

  ```bash
  git add -A
  git commit -m "chore: final polish improvements verification"
  ```
