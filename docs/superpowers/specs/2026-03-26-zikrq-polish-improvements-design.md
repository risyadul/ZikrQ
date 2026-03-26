# ZikrQ Polish Improvements — Design Spec

**Date:** 2026-03-26
**Branch:** `feature/polish-improvements`
**Status:** Approved

---

## Overview

Four targeted UX/polish improvements to the ZikrQ Quran memorization tracker app. All changes land in a single feature branch and are sequenced from lowest-risk (bug fix) to highest-complexity (interactivity).

---

## 1. State Refresh Bug Fix

### Problem

`StatusBottomSheet` (`lib/presentation/widgets/status_bottom_sheet.dart`) calls `updateMemorizationStatusUseCaseProvider` and then pops — but does **not** invalidate any Riverpod providers. After a status change, the surah list, statistics page, and home page all show stale data until the user navigates away and back.

### Solution

Inside `StatusBottomSheet.onTap` (the callback invoked after the use case completes), invalidate the four affected providers before calling `context.pop()`:

```dart
ref.invalidate(surahListProvider);
ref.invalidate(memorizationStatsProvider);
ref.invalidate(recentlyAccessedProvider);
ref.invalidate(needsReviewProvider);
```

### Scope

- **File:** `lib/presentation/widgets/status_bottom_sheet.dart`
- **Change size:** ~4 lines added inside the existing callback
- **No structural changes** to providers or architecture

---

## 2. Filter Tab UI Fix

### Problem

In `lib/presentation/pages/surah_list/surah_list_page.dart`, the filter chip row is a `SizedBox(height: 44)` wrapping a horizontal `ListView` with `padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6)`. The 12px of total vertical padding inside a 44px container leaves only 32px for the `ChoiceChip` widgets — chips appear cramped and visually low/asymmetric.

### Solution

Two targeted changes:

1. Increase `SizedBox` height from `44` → `48`
2. Remove `vertical: 6` from the `ListView` padding (keep `horizontal: 16` only)

This gives chips the full 48px to center naturally within the `ListView`.

### Scope

- **File:** `lib/presentation/pages/surah_list/surah_list_page.dart`
- **Change size:** 2 lines modified
- No layout restructuring

---

## 3. Poppins Font

### Goal

Replace the default system font with Poppins across all text in the app. The app is fully offline — no runtime CDN fetching is permitted.

### Approach

1. Add `google_fonts: ^6.x` to `pubspec.yaml` dependencies
2. Download Poppins font `.ttf` files and bundle them as local assets under `assets/fonts/Poppins/`
3. Disable runtime font fetching before `runApp()`:
   ```dart
   GoogleFonts.config.allowRuntimeFetching = false;
   ```
4. In `lib/core/theme/app_text_styles.dart`, replace each raw `TextStyle(...)` with `GoogleFonts.poppins(...)` preserving all existing parameters (size, weight, color, etc.)
5. In `lib/core/theme/app_theme.dart`, set the `ThemeData` text theme:
   ```dart
   textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
   ```
   This ensures both custom styles and Material widget defaults (AppBar title, buttons, etc.) use Poppins.

### Font weights needed

Poppins files to bundle: Regular (400), Medium (500), SemiBold (600), Bold (700) — both normal and italic variants.

### Scope

- **Files:** `pubspec.yaml`, `lib/main.dart`, `lib/core/theme/app_text_styles.dart`, `lib/core/theme/app_theme.dart`, `assets/fonts/Poppins/` (new directory)

---

## 4. Interactivity

Three improvements applied together for a cohesive tactile UX upgrade.

### A — Haptic Feedback

`HapticFeedback.lightImpact()` called at the following trigger points:

| Trigger | File |
|---|---|
| Bookmark icon tap | `lib/presentation/widgets/surah_tile.dart` |
| Status option tap in bottom sheet | `lib/presentation/widgets/status_bottom_sheet.dart` |
| Filter chip tap | `lib/presentation/pages/surah_list/surah_list_page.dart` |
| Swipe-left threshold reached on surah tile | `lib/presentation/widgets/surah_tile.dart` |

### B — Animations

| Element | Widget | Technique | Duration |
|---|---|---|---|
| Status badge background color | `lib/presentation/widgets/status_badge.dart` | `AnimatedContainer` | 200ms |
| Memorization progress bar value | `lib/presentation/widgets/memorization_progress_bar.dart` | `TweenAnimationBuilder<double>`, `Curves.easeOut` | 300ms |
| Bookmark icon toggle | `lib/presentation/widgets/surah_tile.dart` | `AnimatedSwitcher` with scale transition | 150ms |

### C — Swipe Left on SurahTile

**Behavior:** Swiping left on a `SurahTile` opens the `StatusBottomSheet` directly from the list, eliminating the need to enter the Surah Detail page just to change status.

**Implementation:**

- Wrap the tile content in a `GestureDetector` tracking `onHorizontalDragUpdate` and `onHorizontalDragEnd`
- When horizontal drag delta exceeds **60px leftward**, trigger:
  1. `HapticFeedback.lightImpact()`
  2. `showModalBottomSheet(...)` presenting `StatusBottomSheet` for that surah
- The tile **does not stay offset** — it snaps back to its original position immediately as the sheet opens (swipe is a trigger, not a slide-to-reveal affordance)
- During the drag, a subtle slide-and-fade reveal of the **current memorization status icon** (same icon used in `StatusBadge`) on the right edge of the tile provides visual drag feedback. This indicator fades in proportionally to drag progress and disappears when the sheet opens or the drag is cancelled.

**Why `GestureDetector` over `Dismissible`:** `Dismissible` is semantically designed for item removal/archival. Using it for a status action would be semantically wrong and would require fighting its built-in dismiss behavior.

### Scope

- **Files:** `lib/presentation/widgets/surah_tile.dart`, `lib/presentation/widgets/status_badge.dart`, `lib/presentation/widgets/memorization_progress_bar.dart`, `lib/presentation/widgets/status_bottom_sheet.dart`, `lib/presentation/pages/surah_list/surah_list_page.dart`

---

## Implementation Order

1. **State refresh bug fix** — lowest risk, foundational correctness
2. **Filter tab UI fix** — low risk, pure layout
3. **Poppins font** — medium, touches theme + pubspec
4. **Interactivity** — most complex, builds on stable base

---

## Constraints & Notes

- Use `.withValues(alpha: x)` — **not** `.withOpacity()` (deprecated in this project)
- Use `package:zikrq/...` imports — **not** relative imports
- `google_fonts` must use bundled local fonts only (`allowRuntimeFetching = false`)
- Target Flutter SDK: existing project constraints (do not upgrade Flutter/Dart SDK)
