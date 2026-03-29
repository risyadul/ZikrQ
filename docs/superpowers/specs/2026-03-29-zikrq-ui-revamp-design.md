# ZikrQ UI Revamp — Design Specification (PRD)

**Date:** 2026-03-29  
**Status:** Ready for design  
**Scope:** Full visual revamp of all 4 screens — dark elegant theme, more premium and modern

---

## 1. Design System

### 1.1 Color Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#061612` | App background (darkest layer) |
| `surface` | `#13231E` | Standard card / tile background |
| `surface-elevated` | `#1D2D28` | Active / pressed card |
| `surface-high` | `#283832` | Hover / highlighted card |
| `primary` | `#C9A84C` | Gold — main accent, CTAs, active icons |
| `primary-bright` | `#E6C364` | Gold highlight — large numbers, progress bar |
| `on-surface` | `#D4E7DE` | Primary text (cream-white) |
| `on-surface-variant` | `#D0C5B2` | Secondary / meta text |
| `secondary` | `#93D5AA` | Memorized status, positive states |
| `in-progress` | `#4A8A64` | In-progress status |
| `needs-review` | `#F88D8D` | Needs-review status (soft red, not alarming) |
| `not-started` | `#3A5A4A` | Not-started status (muted) |
| `nav-bar` | `#2C3D37` at 85% opacity | Frosted glass bottom nav |
| `outline` | `#4D4637` at 15% opacity | Ghost borders only — never solid 1px lines |

### 1.2 Typography

**Latin — Poppins**
| Scale | Size | Weight | Usage |
|---|---|---|---|
| Display | 32–40px | SemiBold 600 | Big stat numbers (e.g. "12") |
| Headline | 20–24px | SemiBold 600 | Section titles |
| Title | 16–18px | Medium 500 | Surah names, card titles |
| Body | 14px | Regular 400 | Meta text, translations |
| Label | 11–12px | Regular 400 | Chips, badges, captions |

**Arabic — Scheherazade New**
| Scale | Size | Usage |
|---|---|---|
| Verse | 22–26px | Verse body text |
| Inline | 18px | Surah name in AppBar, tile |
| Bismillah | 24px | Centered header in Surah Detail |

> Rule: Arabic text must always be at least **1.5× the size** of adjacent Latin meta text. Never use Bold for Arabic — the script's inherent weight carries the hierarchy.

### 1.3 Shape

- Cards / tiles: `12–16px` border radius
- Chips / badges: `100px` (fully rounded pill)
- Input fields / search: `12px`
- Number badges (surah number): `8px`

### 1.4 Spacing

- Screen horizontal padding: `20px`
- Card internal padding: `16–20px`
- Item gap in lists: `10–12px`
- Section gap: `24px`

### 1.5 Elevation (tonal — no dark shadows)

Depth is expressed by moving up the surface hierarchy, not by adding shadows.
- Floating elements (nav bar, modals): frosted glass (`nav-bar` token)
- If a glow is needed: `primary` at 12% opacity, 30px blur

### 1.6 Rules

- **No 1px solid borders** for layout sections — use background-color shifts instead
- **No `.withOpacity()`** — use `.withValues(alpha: x)` in Flutter code
- **No dividers** between list items — use `10–12px` vertical spacing
- **No pure black or pure white** — breaks the sacred atmosphere
- Status colors are always used as: tinted background + same color text + same color border (all at reduced opacity)

---

## 2. Screen Specifications

---

### 2.1 Home Screen (`/`)

**Purpose:** Dashboard — progress overview, quick access to recent surahs, review reminders.

#### AppBar
- Background: `background`
- Left: App name **"ZikrQ"** in `primary` gold, Poppins SemiBold 22px
- Right: optional subtle crescent/star decorative icon in `primary` at 30% opacity
- Thin 1px `primary` at 20% opacity line below AppBar as accent separator
- No elevation

#### Body (scrollable)

**Section 1 — Progress Hafalan Card**
- Background: `surface`, rounded 16px
- Top label: "Progress Hafalan" — `on-surface-variant`, Label scale
- Center: `"12"` in Display gold + `" / 114 Surah"` in Title `on-surface-variant`
- Progress bar: 2px track in `surface-high`, gold filled, fully rounded, width = full card minus padding
- Below bar: 3 stat chips in a row (equal width, flex)
  - **Sudah Hafal `12`** — gold tint bg + gold border + gold text
  - **Sedang `8`** — green tint bg + green border + green text
  - **Review `3`** — soft-red tint bg + soft-red border + soft-red text
  - Each chip: pill shape, count large (18px Bold), label below (10px)

**Section 2 — Terakhir Dibuka**
- Section header: "Terakhir Dibuka" — Headline, `on-surface`, left-aligned
- List of `SurahTile` components (max 3, see Section 2.5)

**Section 3 — Perlu Murojaah**
- Section header: "Perlu Murojaah" — Headline, `needs-review` color
- List of `SurahTile` components with red-tinted status badge

#### Bottom Navigation
- 3 tabs: **Home** (active), **Surah**, **Statistik**
- Background: frosted `nav-bar`
- Active tab icon + label: `primary` gold
- Inactive: `on-surface-variant`
- Icons: filled when active, outlined when inactive

---

### 2.2 Daftar Surah Screen (`/surahs`)

**Purpose:** Browse and filter all 114 surahs.

#### AppBar
- Title: "Daftar Surah" — `on-surface`, Poppins SemiBold
- Same style as Home AppBar

#### AppBar Bottom Extension (sticky)

**Search Bar**
- Background: `surface`
- Border radius: 12px
- Prefix icon: search icon in `on-surface-variant`
- Placeholder: "Cari surah..." in `on-surface-variant`
- Text color: `on-surface`
- No border stroke — background shift defines the field
- Active state: placeholder transitions to `primary`, subtle gold underline

**Filter Chips (horizontal scroll)**
- Chips: Semua · Sudah Hafal · Sedang Dihafal · Perlu Murojaah · Belum Mulai
- Active chip: `primary` bg at 20% + `primary` border + `primary` label text
- Inactive chip: `surface` bg + `outline` border + `on-surface-variant` label
- No scroll indicator — fade edge on right side

#### Body
- ListView of `SurahTile` components (see Section 2.5)
- List padding: `20px` horizontal, `12px` top
- Separator: `10px` vertical gap (no dividers)

---

### 2.3 Surah Detail Screen (`/surahs/:id`)

**Purpose:** Read and mark verses of a specific surah.

#### AppBar
- Back arrow icon in `on-surface`
- Title column (left-aligned):
  - Line 1: Surah Latin name (e.g. "Al-Mulk") — Title scale, `on-surface`
  - Line 2: Arabic name (e.g. "الملك") — Scheherazade New 16px, `on-surface-variant`
- Right: Status badge pill (tappable → opens StatusBottomSheet)

#### Body
- **Bismillah header** (shown for all surahs except 1 and 9):
  - Centered Arabic text: `بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ`
  - Font: Scheherazade New 24px
  - Color: `primary` gold
  - Padding bottom: 24px

- **Verse Cards** (for each verse):
  - Background: `surface`, rounded 12px
  - Padding: 16px
  - Left side: gold circle with verse number, 32px diameter, `primary` border 1px, number in `primary` 12px Bold
  - Right side (main area):
    - Arabic text: Scheherazade New 22px, `on-surface`, right-aligned (RTL)
    - Translation: Poppins 13px, `on-surface-variant`, left-aligned, top margin 8px
  - Bottom-right: bookmark icon — `on-surface-variant` when unmarked, `primary` when marked
  - **Marked verse state:** subtle left glow/border using `primary` at 30% opacity; card shifts to `surface-elevated`
  - Separator: 10px gap (no dividers)

#### StatusBottomSheet (modal)
- Background: `surface`, top radius 20px
- Title: "Ubah Status" — Headline
- 4 option tiles, each tappable:
  - Icon (circle) in status color + label + checkmark if active
  - Colors map to the 4 `MemorizationStatus` values

---

### 2.4 Statistik Screen (`/statistics`)

**Purpose:** Aggregate memorization analytics.

#### AppBar
- Title: "Statistik"
- Same style as Home AppBar

#### Body (scrollable)

**Hero Summary Card**
- Background: `surface`, rounded 16px, padding 20px
- Center label: "Total Hafalan" — Label, `on-surface-variant`
- Center number: `"12"` Display gold + `" / 114 Surah"` Title `on-surface-variant`
- Progress bar: same 2px style as Home card
- Below bar: `"1430 ayat telah dihafal"` — Label, `on-surface-variant`, centered

**Rincian Status Section**
- Header: "Rincian Status" — Headline, `on-surface`
- 4 `StatusCard` components:

| Status | Accent Color |
|---|---|
| Sudah Hafal | `primary` `#C9A84C` |
| Sedang Dihafal | `in-progress` `#4A8A64` |
| Perlu Murojaah | `needs-review` `#F88D8D` |
| Belum Mulai | `not-started` `#3A5A4A` |

Each `StatusCard`:
- Background: `surface`, rounded 12px, left accent bar 4px wide in status color
- Left: 4px × 40px colored accent bar (rounded)
- Middle: status label (Title, status color) + mini `LinearProgressIndicator` (2px, status color)
- Right: count number (Display, status color) + percentage below (Label, `on-surface-variant`)
- Padding: 14–16px

#### Bottom Navigation
- Statistik tab active

---

### 2.5 SurahTile Component (shared)

Used on Home, Daftar Surah.

**Layout (horizontal, row):**
```
[ #Badge ] [ Name + Meta      ] [ Arabic ] [ StatusBadge ]
```

- **Number badge:** 36×36px, `surface-elevated` bg, `primary` border 1px, rounded 8px, surah number in `primary` 12px Bold
- **Name column:** 
  - Surah Latin name — Title 15px, `on-surface`
  - Meta: "X ayat · Juz Y" — Label 12px, `on-surface-variant`
- **Arabic name:** Scheherazade New 18px, `on-surface`, right side (before badge)
- **Status badge:** pill shape, 100px radius, 6px vertical / 10px horizontal padding
  - Memorized: `secondary` `#93D5AA` bg at 15%, text `secondary`
  - In Progress: `in-progress` bg at 15%, text `in-progress`
  - Needs Review: `needs-review` bg at 15%, text `needs-review`
  - Not Started: `not-started` bg at 15%, text `on-surface-variant`
- **Swipe-left gesture:** reveals edit icon (`primary`, 22px) behind card on right side

---

## 3. Interactions & Motion

- **List items:** fade-in + slide-up on first load (staggered, 50ms offset per item)
- **SurahTile swipe:** smooth translate, reveals icon progressively with opacity
- **Status change:** haptic feedback (`HapticFeedback.lightImpact`) + provider invalidation
- **Progress bar:** no animation needed on initial load — keep it static and fast
- **Bottom sheet:** standard modal slide-up, frosted background

---

## 4. Screens Summary for Stitch

When generating in Stitch, create these 4 screens in order:

1. **Home** — AppBar + progress card + surah tiles + bottom nav
2. **Daftar Surah** — AppBar + search + filter chips + surah list + bottom nav
3. **Surah Detail** — AppBar with arabic subtitle + bismillah + verse cards + status sheet
4. **Statistik** — AppBar + hero card + 4 status breakdown cards + bottom nav

Use the **dark mode** design system with the exact hex values from Section 1.1. The creative direction is: *"The Digital Mus'haf — a sanctuary, not a productivity app."* Generous whitespace. No borders between sections. Gold and deep forest green. Arabic calligraphy is the centerpiece.

---

## 5. What Stays the Same (Non-UI)

- All Riverpod providers and use cases — untouched
- Isar data models — untouched
- Navigation structure (go_router, 3-tab shell) — untouched
- `MemorizationStatus` enum — untouched
- Provider invalidation pattern after mutations — unchanged
- Font files (Poppins TTF, Scheherazade New TTF) — already bundled
