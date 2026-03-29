# Twilight Sanctuary UI Revamp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the ZikrQ UI with the "Twilight Sanctuary" dark purple-navy theme from the Figma file `w2o2ZIUnHtMmoMSWIUWorH`, across all 4 screens and shared widgets.

**Architecture:** Pure UI layer change — all Riverpod providers, use cases, Isar models, and navigation structure stay completely untouched. Only `lib/core/theme/` and `lib/presentation/` files are modified.

**Tech Stack:** Flutter 3.x · Riverpod · go_router · Poppins + Scheherazade New local TTF fonts · `very_good_analysis` linter

**Font note:** Figma uses Manrope, Plus Jakarta Sans, Inter, FreeMono — none bundled. Flutter implementation substitutes **Poppins** for ALL Latin text, **Scheherazade New** for all Arabic Quranic text.

**Decisions:**
- 3 tabs only (Profile tab deferred)
- No FAB
- Bento grid for "Terakhir Dibuka" on Home
- Asymmetric editorial style for Surah list

---

## Design Token Reference (from Figma)

### Colors

| Token | Value | Source |
|---|---|---|
| `background` | `#111125` | Frame fill all screens |
| `surface` | `#1A1A2E` | Hero/card fill (fill_AT9FF2) |
| `surfaceDark` | `#0C0C1F` | Featured/hero cards, verse card active |
| `surfaceElevated` | `#28283D` | Number badges, elevated elements |
| `surfaceMuted` | `#333348` | Nav active pill, icon containers |
| `primary` | `#BFC4ED` | Main lavender accent, headings, active icons |
| `primaryBright` | `#C0C2F9` | In-progress color, brighter purple |
| `onSurface` | `#E2E0FC` | Primary text on dark surfaces |
| `onSurfaceVariant` | `#C8C5CD` | Secondary / meta text |
| `secondary` | `#BFC4ED` | Memorized status (same as primary) |
| `inProgress` | `#C0C2F9` | In-progress status |
| `needsReview` | `#FFB4AB` | Needs-review status (salmon/coral) |
| `notStarted` | `#929097` | Not-started status (muted gray) |
| `navBar` | `rgba(26,26,46,0.7)` | TopAppBar + BottomNavBar glass |
| `outline` | `rgba(71,70,76,0.15)` | Card strokes |

### Typography (Poppins as universal Latin substitute)

| Scale | Size | Weight | Usage |
|---|---|---|---|
| displayLarge | 48sp | 800 | Big stat number "12" on hero |
| displayMedium | 36sp | 800 | Page titles (Progress Hafalan, Daftar Surah) |
| headlineLarge | 30sp | 800 | Stats "Total Hafalan", streak number |
| headlineMedium | 24sp | 700 | Featured surah name in bento card |
| headlineSmall | 20sp | 700 | Section headings (Terakhir Dibuka) |
| titleLarge | 18sp | 700 | AppBar title |
| titleMedium | 16sp | 700 | Surah list item name, status badge |
| bodyMedium | 14sp | 400 | Subtitle, meta text |
| bodySmall | 12sp | 400 | Sub-meta, status chip text |
| labelSmall | 10sp | 600 | Uppercase labels (OVERVIEW, SURAH 67) |

| Arabic Scale | Size | Weight | Usage |
|---|---|---|---|
| arabicBismillah | 48sp | 400 | Bismillah header |
| arabicVerse | 36sp | 400 | Verse body text |
| arabicFeatured | 30sp | 400 | Arabic name in large bento Card 1 |
| arabicInline | 24sp | 400 | Arabic names in bento Card 2/3 |
| arabicList | 20sp | 400 | Arabic name in surah list items |
| arabicAppBar | 12sp | 400 | Arabic subtitle in AppBar |

### Shape

| Context | Border Radius |
|---|---|
| Hero / stats hero card | 32px |
| Bento cards, list tiles, murojaah cards | 24px |
| Verse cards | 40px |
| Stats 2×2 grid cards | 24px |
| Status badge, filter chip, active nav pill | 12px (not fully round) |
| Surah number badge in list | 8px |
| Status pill in AppBar | 4px |

### Spacing

| Context | Value |
|---|---|
| Screen horizontal padding | 24px |
| Hero card padding | 32px |
| Home main column gap | 40px |
| Section gap (Terakhir Dibuka, Murojaah) | 24px |
| Surah list item gap | 24px |
| Surah list item padding | 20px |
| Verse card padding | 32px |
| Stats card padding | 20px |

---

## Files Changed

| File | Action |
|---|---|
| `lib/core/theme/app_colors.dart` | Replace entirely — new purple-navy palette |
| `lib/core/theme/app_text_styles.dart` | Replace entirely — new type scale |
| `lib/core/theme/app_theme.dart` | Update for new color/font system |
| `lib/presentation/pages/shell/main_shell.dart` | Frosted glass nav bar, curved top corners |
| `lib/presentation/widgets/memorization_progress_bar.dart` | 12px height, lavender fill |
| `lib/presentation/widgets/status_badge.dart` | New colors, 4px radius, uppercase labels |
| `lib/presentation/widgets/status_bottom_sheet.dart` | New colors, status circle icons |
| `lib/presentation/widgets/surah_tile.dart` | Compact editorial list item (24px radius) |
| `lib/presentation/pages/home/home_page.dart` | Full revamp: hero card + bento grid + murojaah cards |
| `lib/presentation/pages/surah_list/surah_list_page.dart` | Asymmetric editorial list (featured card + compact rows) |
| `lib/presentation/pages/surah_detail/surah_detail_page.dart` | New AppBar, bismillah gradient, verse list |
| `lib/presentation/pages/surah_detail/verse_card.dart` | 40px radius, new layout, active glow |
| `lib/presentation/pages/statistics/statistics_page.dart` | Hero card + 2×2 grid + activity card |

---

## Pre-flight

- [ ] Create branch: `git checkout -b feat/ui-revamp`
- [ ] Confirm baseline: `flutter analyze && flutter test` both pass

---

## Task 1: AppColors

**File:** `lib/core/theme/app_colors.dart`

- [ ] **Step 1.1: Replace file**

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Background hierarchy
  static const background = Color(0xFF111125);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF0C0C1F);
  static const surfaceElevated = Color(0xFF28283D);
  static const surfaceMuted = Color(0xFF333348);

  // Accent purple
  static const primary = Color(0xFFBFC4ED);
  static const primaryBright = Color(0xFFC0C2F9);

  // Text
  static const onSurface = Color(0xFFE2E0FC);
  static const onSurfaceVariant = Color(0xFFC8C5CD);

  // Status
  static const secondary = Color(0xFFBFC4ED); // memorized
  static const inProgress = Color(0xFFC0C2F9);
  static const needsReview = Color(0xFFFFB4AB);
  static const notStarted = Color(0xFF929097);

  // Nav surfaces (use with .withValues at call site)
  // navBar rgba(26,26,46,0.7) → Color(0xFF1A1A2E) withValues(alpha: 0.7)
  static const navBarBase = Color(0xFF1A1A2E);

  // Card stroke rgba(71,70,76,0.15)
  static const outlineBase = Color(0xFF47464C);
}
```

- [ ] **Step 1.2:** `flutter analyze` — expect 0 errors.

- [ ] **Step 1.3:** Commit: `git add lib/core/theme/app_colors.dart && git commit -m "feat(theme): new purple-navy AppColors from Figma"`

---

## Task 2: AppTextStyles

**File:** `lib/core/theme/app_text_styles.dart`

- [ ] **Step 2.1: Replace file**

```dart
// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const String _latin = 'Poppins';
  static const String _arabic = 'Scheherazade New';

  // --- Display ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1.1,
  );

  // --- Headline ---
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _latin,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // --- Title ---
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _latin,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // --- Body ---
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _latin,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _latin,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );

  // --- Label ---
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _latin,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.8,
  );

  // --- Compat aliases ---
  static const TextStyle surahName = titleMedium;
  static const TextStyle surahMeta = bodySmall;
  static const TextStyle sectionLabel = bodySmall;
  static const TextStyle headline = headlineSmall;
  static const TextStyle translation = TextStyle(
    fontFamily: _latin,
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.onSurfaceVariant,
    height: 1.6,
  );

  // --- Arabic ---
  static const TextStyle arabicBismillah = TextStyle(
    fontFamily: _arabic,
    fontSize: 48,
    color: AppColors.onSurface,
    height: 1.8,
  );
  static const TextStyle arabicVerse = TextStyle(
    fontFamily: _arabic,
    fontSize: 36,
    color: AppColors.onSurface,
    height: 2,
  );
  static const TextStyle arabicFeatured = TextStyle(
    fontFamily: _arabic,
    fontSize: 30,
    color: AppColors.onSurfaceVariant,
    height: 1.6,
  );
  static const TextStyle arabicInline = TextStyle(
    fontFamily: _arabic,
    fontSize: 24,
    color: AppColors.onSurfaceVariant,
  );
  static const TextStyle arabicList = TextStyle(
    fontFamily: _arabic,
    fontSize: 20,
    color: AppColors.onSurfaceVariant,
  );
  static const TextStyle arabicAppBar = TextStyle(
    fontFamily: _arabic,
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );
}
```

- [ ] **Step 2.2:** `flutter analyze` — 0 errors.
- [ ] **Step 2.3:** Commit: `git add lib/core/theme/app_text_styles.dart && git commit -m "feat(theme): new type scale from Figma"`

---

## Task 3: AppTheme

**File:** `lib/core/theme/app_theme.dart`

- [ ] **Step 3.1: Replace file**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';

abstract final class AppTheme {
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
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.onSurface),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    textTheme: const TextTheme(bodyMedium: AppTextStyles.bodyMedium),
  );
}
```

- [ ] **Step 3.2:** `flutter analyze` — 0 errors.
- [ ] **Step 3.3:** Commit: `git add lib/core/theme/app_theme.dart && git commit -m "feat(theme): update AppTheme for Twilight Sanctuary"`

---

## Task 4: MainShell (Frosted Glass Nav)

**File:** `lib/presentation/pages/shell/main_shell.dart`

From Figma: BottomNavBar `borderRadius: 32px 32px 0px 0px`, height: 80px, gap ~28px, padding: `0 30px 8px 30px`, fill `rgba(26,26,46,0.7)` + `backdropFilter: blur(20px)`, box-shadow `0px -8px 32px 0px rgba(226,224,252,0.06)`. Active tab has `#333348` pill container (`borderRadius: 16px`).

- [ ] **Step 4.1: Replace file**

```dart
// lib/presentation/pages/shell/main_shell.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:zikrq/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});
  final Widget child;

  static const _tabs = ['/', '/surahs', '/stats'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere(
      (t) => location == t || (t != '/' && location.startsWith(t)),
    );
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navBarBase.withValues(alpha: 0.7),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => context.go(_tabs[index]),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Surah',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4.2:** `flutter analyze` — 0 errors.
- [ ] **Step 4.3:** Commit: `git add lib/presentation/pages/shell/main_shell.dart && git commit -m "feat(shell): frosted glass nav bar with Figma spec"`

---

## Task 5: MemorizationProgressBar

**File:** `lib/presentation/widgets/memorization_progress_bar.dart`

From Figma: `minHeight: 12px`, lavender gradient fill (`#C6C6C6 → #BFC4ED`), track = dark surface.

```dart
// lib/presentation/widgets/memorization_progress_bar.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';

class MemorizationProgressBar extends StatelessWidget {
  const MemorizationProgressBar({
    required this.value, // 0.0 to 1.0
    super.key,
    this.height = 12,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clampedValue = value.clamp(0.0, 1.0);
        final filledWidth = constraints.maxWidth * clampedValue;
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Track
                Container(
                  width: double.infinity,
                  color: AppColors.surfaceElevated,
                ),
                // Fill with gradient
                Container(
                  width: filledWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC6C6C6), AppColors.primary],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5.1: Replace file** with code above.
- [ ] **Step 5.2:** `flutter analyze` — 0 errors.
- [ ] **Step 5.3:** Commit: `git add lib/presentation/widgets/memorization_progress_bar.dart && git commit -m "feat(widgets): update MemorizationProgressBar 12px lavender gradient"`

---

## Task 6: StatusBadge

**File:** `lib/presentation/widgets/status_badge.dart`

From Figma: compact badge, `borderRadius: 4px`, uppercase text, `Plus Jakarta Sans 700 10px UPPER` → Poppins 700 10px + letterSpacing.

```dart
// lib/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});
  final MemorizationStatus status;

  Color get _color => switch (status) {
    MemorizationStatus.memorized => AppColors.secondary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  String get _label => switch (status) {
    MemorizationStatus.memorized => 'HAFAL',
    MemorizationStatus.inProgress => 'SEDANG',
    MemorizationStatus.needsReview => 'MUROJAAH',
    MemorizationStatus.notStarted => 'BELUM',
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontFamily: 'Poppins',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        child: Text(_label),
      ),
    );
  }
}
```

- [ ] **Step 6.1: Replace file** with code above.
- [ ] **Step 6.2:** `flutter analyze` — 0 errors.
- [ ] **Step 6.3:** Commit: `git add lib/presentation/widgets/status_badge.dart && git commit -m "feat(widgets): revamp StatusBadge Figma style"`

---

## Task 7: StatusBottomSheet

**File:** `lib/presentation/widgets/status_bottom_sheet.dart`

```dart
// lib/presentation/widgets/status_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';

class StatusBottomSheet extends ConsumerWidget {
  const StatusBottomSheet({
    required this.surahId,
    required this.currentStatus,
    super.key,
  });

  final int surahId;
  final MemorizationStatus currentStatus;

  Color _statusColor(MemorizationStatus status) => switch (status) {
    MemorizationStatus.memorized => AppColors.secondary,
    MemorizationStatus.inProgress => AppColors.inProgress,
    MemorizationStatus.needsReview => AppColors.needsReview,
    MemorizationStatus.notStarted => AppColors.notStarted,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Status', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              ...MemorizationStatus.values.map((status) {
                final color = _statusColor(status);
                final isActive = status == currentStatus;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.circle, color: color, size: 12),
                  ),
                  title: Text(
                    status.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isActive ? color : AppColors.onSurface,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check_rounded, color: color, size: 18)
                      : null,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await ref
                        .read(updateMemorizationStatusUseCaseProvider)
                        .call(surahId, status);
                    if (context.mounted) {
                      ref
                        ..invalidate(surahListProvider)
                        ..invalidate(memorizationStatsProvider)
                        ..invalidate(recentlyAccessedProvider)
                        ..invalidate(needsReviewProvider);
                      Navigator.of(context).pop();
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.1: Replace file** with code above.
- [ ] **Step 7.2:** `flutter analyze` — 0 errors.
- [ ] **Step 7.3:** Commit: `git add lib/presentation/widgets/status_bottom_sheet.dart && git commit -m "feat(widgets): revamp StatusBottomSheet Figma style"`

---

## Task 8: SurahTile (Compact Editorial Item)

**File:** `lib/presentation/widgets/surah_tile.dart`

From Figma surah list items: `fill #1A1A2E, borderRadius: 24px, height ~92px, padding: 20px`. Number badge: `40×40, borderRadius: 8px, fill #28283D`. Surah name: `Manrope 700/16px` → Poppins 700/16. Arabic name: `FreeMono 400/20px` → Scheherazade New 20px.

- [ ] **Step 8.1: Replace `surah_tile.dart`**

```dart
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
                child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
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
                            Text(widget.surah.name, style: AppTextStyles.titleMedium),
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
                      Text(widget.surah.nameArabic, style: AppTextStyles.arabicList),
                      const SizedBox(width: 12),
                      // Status icon (bookmark-style)
                      Icon(
                        Icons.bookmark_outline,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
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
```

- [ ] **Step 8.2:** `flutter analyze` — 0 errors.
- [ ] **Step 8.3:** Commit: `git add lib/presentation/widgets/surah_tile.dart && git commit -m "feat(widgets): revamp SurahTile to editorial list item"`

---

## Task 9: HomePage

**File:** `lib/presentation/pages/home/home_page.dart`

Key Figma layout:
- AppBar: `rgba(26,26,46,0.7)` glass, `backdropFilter: blur(20px)`, "ZIKRQ" label uppercase, user avatar right
- Main content: 24px horizontal padding, 40px column gap
- Hero card: `#1A1A2E`, 32px radius, 32px padding, gap: 32px. Has "OVERVIEW" uppercase label + "Progress\nHafalan" heading (displayMedium), big number "12" (displayLarge) + "/ 114 Surah", progress bar (12px), status chips row
- Section 1: "Terakhir Dibuka" — **bento grid**: full-width featured Card (surfaceDark, 24px radius) + Row of 2 smaller cards
- Section 2: "Perlu Murojaah" — list of murojaah cards (surfaceDark, 24px radius, row layout with number circle + content)

- [ ] **Step 9.1: Replace `home_page.dart`**

```dart
// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';
import 'package:zikrq/presentation/widgets/status_bottom_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);
    final recentAsync = ref.watch(recentlyAccessedProvider);
    final needsReviewAsync = ref.watch(needsReviewProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref
            ..invalidate(memorizationStatsProvider)
            ..invalidate(recentlyAccessedProvider)
            ..invalidate(needsReviewProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Frosted glass AppBar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppConstants.appName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.onSurface,
                ),
              ),
              centerTitle: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: const ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero progress card
                  statsAsync.when(
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stats) => _HeroProgressCard(stats: stats),
                  ),
                  const SizedBox(height: 40),

                  // Terakhir Dibuka — bento grid
                  recentAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (surahs) {
                      if (surahs.isEmpty) return const SizedBox.shrink();
                      return _RecentlyAccessedSection(
                        surahs: surahs,
                        onTap: (s) => context.push('/surahs/${s.id}'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Perlu Murojaah
                  needsReviewAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (surahs) {
                      if (surahs.isEmpty) return const SizedBox.shrink();
                      return _MurojaahSection(
                        surahs: surahs,
                        onTap: (s) => context.push('/surahs/${s.id}'),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import for BackdropFilter in SliverAppBar
// ignore: avoid_classes_with_only_static_members, implementation_imports
import 'dart:ui' as ui;

// ─── Hero progress card ───────────────────────────────────────────────────────

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({required this.stats});
  final MemorizationStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineBase.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OVERVIEW label
          Text(
            'OVERVIEW',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryBright.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // "Progress\nHafalan" heading
          Text('Progress\nHafalan', style: AppTextStyles.displayMedium),
          const SizedBox(height: 24),
          // Big number row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${stats.memorized}', style: AppTextStyles.displayLarge),
              const SizedBox(width: 8),
              Text(
                '/ ${AppConstants.totalSurahs} Surah',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MemorizationProgressBar(value: stats.memorizedPercent),
          const SizedBox(height: 20),
          // Status chips
          Row(
            children: [
              _StatChip(
                label: 'Sudah Hafal',
                count: stats.memorized,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Sedang',
                count: stats.inProgress,
                color: AppColors.inProgress,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Review',
                count: stats.needsReview,
                color: AppColors.needsReview,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Terakhir Dibuka — Bento Grid ─────────────────────────────────────────────

class _RecentlyAccessedSection extends StatelessWidget {
  const _RecentlyAccessedSection({
    required this.surahs,
    required this.onTap,
  });
  final List<Surah> surahs;
  final void Function(Surah) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Terakhir Dibuka', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 20),
        // Featured card (first surah)
        _BentoFeaturedCard(surah: surahs.first, onTap: () => onTap(surahs.first)),
        if (surahs.length > 1) ...[
          const SizedBox(height: 16),
          // Companion cards (2nd and 3rd)
          Row(
            children: [
              for (int i = 1; i < surahs.length.clamp(0, 3); i++) ...[
                if (i > 1) const SizedBox(width: 16),
                Expanded(
                  child: _BentoCompanionCard(
                    surah: surahs[i],
                    onTap: () => onTap(surahs[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _BentoFeaturedCard extends StatelessWidget {
  const _BentoFeaturedCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SURAH ${surah.id}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(surah.name, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.totalVerses} Ayat · Juz ${surah.juzStart}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right: Arabic name
            Text(surah.nameArabic, style: AppTextStyles.arabicFeatured),
          ],
        ),
      ),
    );
  }
}

class _BentoCompanionCard extends StatelessWidget {
  const _BentoCompanionCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              surah.nameArabic,
              style: AppTextStyles.arabicInline,
            ),
            const SizedBox(height: 8),
            Text(surah.name, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${surah.totalVerses} Ayat',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Perlu Murojaah ───────────────────────────────────────────────────────────

class _MurojaahSection extends StatelessWidget {
  const _MurojaahSection({required this.surahs, required this.onTap});
  final List<Surah> surahs;
  final void Function(Surah) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.needsReview.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Perlu Murojaah',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.needsReview,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...surahs.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MurojaahCard(surah: s, onTap: () => onTap(s)),
          ),
        ),
      ],
    );
  }
}

class _MurojaahCard extends StatelessWidget {
  const _MurojaahCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.needsReview.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Circle number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.needsReview.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.id}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.needsReview,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.totalVerses} Ayat',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(surah.nameArabic, style: AppTextStyles.arabicInline),
          ],
        ),
      ),
    );
  }
}
```

> **Note:** The `import 'dart:ui' as ui;` for `ui.ImageFilter` must be placed at the top of the file (before `class HomePage`), not after it. Restructure the imports correctly when writing the file.

- [ ] **Step 9.2:** `flutter analyze` — 0 errors. If the `dart:ui` import causes an `import_of_legacy_library_into_null_safe` issue, replace `ui.ImageFilter.blur` with `ImageFilter.blur` from `dart:ui` imported directly at the top.

- [ ] **Step 9.3:** Commit: `git add lib/presentation/pages/home/home_page.dart && git commit -m "feat(home): revamp HomePage bento layout from Figma"`

---

## Task 10: SurahListPage (Asymmetric Editorial)

**File:** `lib/presentation/pages/surah_list/surah_list_page.dart`

From Figma:
- Page title at top (displayMedium + bodyMedium subtitle), y: 80
- Search bar: `#1A1A2E` fill, 12px radius, Plus Jakarta Sans placeholder → Poppins
- Filter chips: active = `#C6C6C6` filled button; inactive = `#333348` ghost button. 12px radius.
- Surah list: first item (if `inProgress`) gets the featured "Sunken Well" card (surfaceDark, 32px radius, 180px, status badge, mini progress bar). Rest are compact SurahTile.

- [ ] **Step 10.1: Replace `surah_list_page.dart`**

```dart
// lib/presentation/pages/surah_list/surah_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';
import 'package:zikrq/presentation/widgets/status_bottom_sheet.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class SurahListPage extends ConsumerWidget {
  const SurahListPage({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(surahStatusFilterProvider);
    final surahListAsync = ref.watch(surahListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Glass AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navBarBase.withValues(alpha: 0.7),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            title: const Text(
              'ZIKRQ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppColors.onSurface,
              ),
            ),
            centerTitle: false,
          ),

          // Page title + subtitle
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftar Surah', style: AppTextStyles.displayMedium),
                  SizedBox(height: 8),
                  Text(
                    'Lanjutkan perjalanan hafalanmu.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: (value) =>
                    ref.read(surahSearchQueryProvider.notifier).state = value,
                style: const TextStyle(fontFamily: 'Poppins', color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari surah...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineBase.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = activeFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(surahStatusFilterProvider.notifier).state = filter;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.onSurface : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _filterLabels[index],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isActive
                              ? AppColors.background
                              : AppColors.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Surah list
          surahListAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e', style: AppTextStyles.bodySmall)),
            ),
            data: (surahs) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // First inProgress surah gets the featured card
                    if (index == 0 &&
                        surahs.isNotEmpty &&
                        surahs.first.status == MemorizationStatus.inProgress) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _FeaturedSurahCard(
                          surah: surahs.first,
                          onTap: () => context.push('/surahs/${surahs.first.id}'),
                        ),
                      );
                    }
                    final surah = surahs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SurahTile(
                        surah: surah,
                        onTap: () => context.push('/surahs/${surah.id}'),
                      ),
                    );
                  },
                  childCount: surahs.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSurahCard extends StatelessWidget {
  const _FeaturedSurahCard({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.outlineBase.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Number badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.id}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(surah.name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${surah.totalVerses} Ayat',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.inProgress,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(surah.nameArabic, style: AppTextStyles.arabicFeatured),
              ],
            ),
            const SizedBox(height: 20),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.inProgress.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Sedang Dihafal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.inProgress,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            MemorizationProgressBar(value: 0.45),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '45% Hafal',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${surah.totalVerses} Ayat',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Note:** `import 'dart:ui'` for `ImageFilter` must be at the top of the file. Add it.

- [ ] **Step 10.2:** `flutter analyze` — 0 errors.
- [ ] **Step 10.3:** Commit: `git add lib/presentation/pages/surah_list/surah_list_page.dart && git commit -m "feat(surah-list): asymmetric editorial layout from Figma"`

---

## Task 11: VerseCard

**File:** `lib/presentation/pages/surah_detail/verse_card.dart`

From Figma: `borderRadius: 40px`, padding: 32px, verse number badge: 48×48, borderRadius: 12px, fill `#28283D`. Arabic: Scheherazade New 36px, right-aligned. Translation: Poppins 300/18px. Bookmark button top-right. Active card: fill `#0C0C1F`, stroke `rgba(192,194,249,0.2)`.

- [ ] **Step 11.1: Replace `verse_card.dart`**

```dart
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
                  color: isMarked ? AppColors.primary : AppColors.onSurfaceVariant,
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
```

- [ ] **Step 11.2:** `flutter analyze` — 0 errors.
- [ ] **Step 11.3:** Commit: `git add lib/presentation/pages/surah_detail/verse_card.dart && git commit -m "feat(verse): revamp VerseCard 40px radius Figma spec"`

---

## Task 12: SurahDetailPage

**File:** `lib/presentation/pages/surah_detail/surah_detail_page.dart`

From Figma: glass AppBar with back button, center title "Al-Mulk" (titleLarge) + Arabic subtitle (arabicAppBar), right: status badge + user avatar. Bismillah: Scheherazade New 48px, gradient text + horizontal fade divider + English translation. Body padding: 96px top, 24px sides, 128px bottom.

- [ ] **Step 12.1: Replace `surah_detail_page.dart`**

```dart
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

  void _showStatusSheet(BuildContext context, MemorizationStatus currentStatus) {
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
                        Text(surah.nameArabic, style: AppTextStyles.arabicAppBar),
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
              // Bismillah header
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
                    Text(
                      'IN THE NAME OF ALLAH, THE MOST GRACIOUS, THE MOST MERCIFUL',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
```

- [ ] **Step 12.2:** `flutter analyze` — 0 errors.
- [ ] **Step 12.3:** Commit: `git add lib/presentation/pages/surah_detail/surah_detail_page.dart && git commit -m "feat(surah-detail): revamp SurahDetailPage from Figma"`

---

## Task 13: StatisticsPage (2×2 Grid)

**File:** `lib/presentation/pages/statistics/statistics_page.dart`

From Figma: Hero card (surface, 32px radius, 20px padding, centered). Stats "Rincian Status" uses 2×2 grid of cards (24px radius, 20px padding) — each card shows label + big number + progress bar. Activity section (surfaceDark, 32px radius) shows streak. Padding: `96px top / 24px sides / 96px bottom`.

- [ ] **Step 13.1: Replace `statistics_page.dart`**

```dart
// lib/presentation/pages/statistics/statistics_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zikrq/core/theme/app_colors.dart';
import 'package:zikrq/core/theme/app_text_styles.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memorizationStatsProvider);

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
              title: const Text('Statistik', style: AppTextStyles.titleLarge),
              centerTitle: false,
            ),
          ),
        ),
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => Center(
          child: Text('Gagal memuat statistik', style: AppTextStyles.bodySmall),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 120),
          children: [
            const SizedBox(height: 16),

            // Hero summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.outlineBase.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  // Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PENCAPAIAN',
                        style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2),
                      ),
                      Text(
                        'Total Hafalan',
                        style: AppTextStyles.headlineLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Big number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${stats.memorized}', style: AppTextStyles.displayLarge),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${stats.total} Surah',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MemorizationProgressBar(value: stats.memorizedPercent),
                  const SizedBox(height: 12),
                  Text(
                    '${stats.memorizedVerseCount} ayat telah dihafal',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rincian Status heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rincian Status', style: AppTextStyles.headlineSmall),
                Text('Bulan ini', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 20),

            // 2×2 grid
            Row(
              children: [
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.memorized,
                    count: stats.memorized,
                    total: stats.total,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.inProgress,
                    count: stats.inProgress,
                    total: stats.total,
                    color: AppColors.inProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.needsReview,
                    count: stats.needsReview,
                    total: stats.total,
                    color: AppColors.needsReview,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatusGridCard(
                    status: MemorizationStatus.notStarted,
                    count: stats.notStarted,
                    total: stats.total,
                    color: AppColors.notStarted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Activity section placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wawasan Aktivitas', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '7',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hari Berturut-turut',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGridCard extends StatelessWidget {
  const _StatusGridCard({
    required this.status,
    required this.count,
    required this.total,
    required this.color,
  });

  final MemorizationStatus status;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : count / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 13.2:** `flutter analyze` — 0 errors.
- [ ] **Step 13.3:** Commit: `git add lib/presentation/pages/statistics/statistics_page.dart && git commit -m "feat(stats): revamp StatisticsPage 2x2 grid from Figma"`

---

## Task 14: Final Verification + PR

- [ ] **Step 14.1:** Full analysis: `flutter analyze` — must be 0 errors.
- [ ] **Step 14.2:** Tests: `flutter test` — all pass (UI changes don't touch domain/data).
- [ ] **Step 14.3:** Format:
  ```bash
  dart format --output=none --set-exit-if-changed .
  ```
  If changes needed: `dart format . && git add -A && git commit -m "style: dart format"`
- [ ] **Step 14.4:** Push: `git push -u origin feat/ui-revamp`
- [ ] **Step 14.5:** Create PR:
  ```bash
  gh pr create \
    --title "feat: Twilight Sanctuary UI revamp" \
    --body "$(cat <<'EOF'
  ## Summary

  - Completely replaces ZikrQ color palette with purple-navy Twilight Sanctuary theme (from Figma file w2o2ZIUnHtMmoMSWIUWorH)
  - New AppColors (14 tokens), AppTextStyles (full scale), AppTheme
  - Frosted glass TopAppBar and BottomNavBar (backdropFilter blur, 32px top radius)
  - Home: bento grid for Terakhir Dibuka + murojaah card layout
  - Surah list: asymmetric editorial style (featured inProgress card + compact list)
  - Verse cards: 40px radius with gradient divider + bismillah gradient text
  - Statistics: hero summary card + 2×2 status grid + activity card
  - Zero changes to business logic, providers, use cases, or Isar models

  ## Figma source
  https://www.figma.com/design/w2o2ZIUnHtMmoMSWIUWorH/
  EOF
  )" \
    --base main \
    --head feat/ui-revamp
  ```

---

## Implementation Notes

- **Never use `.withOpacity()`** — always `.withValues(alpha: x)`
- **Never use relative imports** — always `package:zikrq/…`
- **`const` constructors** wherever possible
- **`dart:ui` imports** — `import 'dart:ui'` for `ImageFilter` in shell, surah list, surah detail, stats. Place at top of file.
- **Do not touch** anything under `lib/domain/`, `lib/data/`, `lib/presentation/providers/`
- **Do not edit** any `.g.dart` files
- Task 9 `_FeaturedSurahCard` shows `value: 0.45` as placeholder for progress bar — this is fine since there's no per-verse progress on home screen
- The `MemorizationStats` import in Task 9: verify the exact file path is `package:zikrq/domain/entities/memorization_stats.dart`
