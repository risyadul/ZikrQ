# ZikrQ MVP — Design Spec

**Date:** 2026-03-26  
**App Name:** ZikrQ  
**Platform:** Flutter (Android + iOS)  
**Scope:** MVP — Quran memorization tracking with verse display

---

## 1. Overview

ZikrQ is a mobile app that helps users track their Quran memorization (hafalan) progress. For MVP, users can:

1. See all 114 surahs with their current memorization status
2. Update the status of any surah (4 statuses)
3. Read verses (ayat) of any surah with Arabic text and Indonesian translation
4. Interact with individual verses inside a surah
5. View overall memorization statistics

The app works fully offline. All data is stored locally on device. Architecture is designed to support a backend integration in the future without requiring a rewrite.

---

## 2. Architecture

### Approach

Clean Architecture with 3 layers: `data`, `domain`, `presentation`.

- `domain/` is pure Dart — no Flutter, no Isar, no external dependencies
- `data/` implements `domain/` interfaces using Isar and local JSON assets
- `presentation/` consumes `domain/` exclusively through Riverpod providers

This separation ensures that when a backend is added later, only a `RemoteDataSource` needs to be added to `data/` — domain and UI remain untouched.

### Folder Structure

```
lib/
├── core/
│   ├── theme/              # Dark Elegant color palette, text styles, app theme
│   ├── constants/          # Asset paths, string keys, app config
│   └── utils/              # Helpers (juz calculator, arabic number formatter)
│
├── data/
│   ├── datasources/
│   │   └── local/
│   │       ├── quran_local_datasource.dart     # Reads quran_id.json
│   │       └── memorization_local_datasource.dart  # Isar CRUD operations
│   ├── models/
│   │   ├── surah_model.dart             # Isar schema for surah seed data
│   │   ├── verse_model.dart             # Isar schema for verse seed data
│   │   ├── memorization_record_model.dart  # Isar schema for surah-level user data
│   │   └── marked_verse_record_model.dart  # Isar schema for per-verse marks
│   └── repositories/
│       └── quran_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── surah.dart
│   │   ├── verse.dart
│   │   └── memorization_status.dart
│   ├── repositories/
│   │   └── quran_repository.dart   # Abstract interface
│   └── usecases/
│       ├── get_all_surahs.dart
│       ├── get_verses_by_surah.dart
│       ├── update_memorization_status.dart
│       ├── toggle_verse_mark.dart
│       ├── get_memorization_stats.dart
│       └── seed_initial_data.dart
│
├── presentation/
│   ├── providers/
│   │   ├── surah_list_provider.dart
│   │   ├── surah_detail_provider.dart
│   │   └── stats_provider.dart
│   ├── pages/
│   │   ├── home/
│   │   │   └── home_page.dart
│   │   ├── surah_list/
│   │   │   ├── surah_list_page.dart
│   │   │   └── surah_list_filter.dart
│   │   ├── surah_detail/
│   │   │   ├── surah_detail_page.dart
│   │   │   └── verse_card.dart
│   │   └── statistics/
│   │       └── statistics_page.dart
│   ├── widgets/
│   │   ├── surah_tile.dart
│   │   ├── status_badge.dart
│   │   ├── memorization_progress_bar.dart
│   │   └── status_bottom_sheet.dart
│   └── app_router.dart             # go_router configuration
│
└── main.dart
```

---

## 3. Data Layer

### Entities

```dart
// domain/entities/surah.dart
class Surah {
  final int id;               // 1–114
  final String name;          // "Al-Fatihah"
  final String nameArabic;    // "الفاتحة"
  final int totalVerses;
  final int juzStart;         // first juz where this surah begins (taken from juz[0] in JSON)
  final String revelation;    // "Meccan" | "Medinan"
  final MemorizationStatus status;
}

// domain/entities/verse.dart
class Verse {
  final int id;
  final int surahId;
  final int number;
  final String arabic;
  final String translation;   // Indonesian
}

// domain/entities/memorization_status.dart
enum MemorizationStatus {
  notStarted,    // UI: "Belum Mulai"
  inProgress,    // UI: "Sedang Dihafal"
  memorized,     // UI: "Sudah Hafal"
  needsReview,   // UI: "Perlu Murojaah"
}
```

### Isar Models

Four Isar collections:
- `SurahModel` — seeded from JSON, read-only after seed
- `VerseModel` — seeded from JSON, read-only after seed
- `MemorizationRecord` — user data, mutable (`surahId`, `status`, `updatedAt`, `lastAccessedAt`)
- `MarkedVerseRecord` — user data, mutable (`surahId`, `verseNumber`, `isMarked`); stores per-verse reading marks independently from the read-only `VerseModel`

`lastAccessedAt` on `MemorizationRecord` is updated every time the user opens a surah's detail page. Used by the Home screen to show recently accessed surahs.

### Data Flow

```
assets/data/quran_id.json
        │
        ▼
QuranLocalDataSource.seedIfEmpty()
        │  (first launch only)
        ▼
Isar DB: SurahModel + VerseModel + MemorizationRecord (all notStarted)
        │
        ▼
QuranRepositoryImpl
        │
        ▼
UseCases (domain)
        │
        ▼
Riverpod Providers
        │
        ▼
UI Widgets
```

### Seed Strategy

On app launch, `SeedInitialDataUseCase` checks if Isar is empty. If so, it:
1. Reads `assets/data/quran_id.json`
2. Writes all 114 `SurahModel` records
3. Writes all 6,236 `VerseModel` records
4. Creates 114 `MemorizationRecord` entries with `status = notStarted`

Subsequent launches skip seeding entirely.

---

## 4. Domain — Use Cases

| Use Case | Input | Output |
|---|---|---|
| `GetAllSurahsUseCase` | filter: `MemorizationStatus?` | `List<Surah>` |
| `GetVersesBySurahUseCase` | `surahId: int` | `List<Verse>` |
| `UpdateMemorizationStatusUseCase` | `surahId: int`, `status: MemorizationStatus` | `void` |
| `ToggleVerseMarkUseCase` | `surahId: int`, `verseNumber: int` | `void` |
| `GetMemorizationStatsUseCase` | — | `MemorizationStats` |
| `SeedInitialDataUseCase` | — | `void` |

`MemorizationStats` is a simple value object:
```dart
class MemorizationStats {
  final int memorized;
  final int inProgress;
  final int needsReview;
  final int notStarted;
  final int total;              // always 114
  final int memorizedVerseCount; // sum of totalVerses from memorized surahs
}
```

---

## 5. Screens

### 5.1 Home (Tab 1)

**Purpose:** Quick overview of memorization progress.

**Content:**
- App bar: "ZikrQ" wordmark
- Progress card: "X / 114 Surah Dihafal" with a progress bar
- Recently accessed surahs (last 3, sorted by `lastAccessedAt` descending on `MemorizationRecord`). This section is hidden if no surah has been accessed yet — i.e., all `lastAccessedAt` values are null.
- Needs review reminder: list of surahs with `needsReview` status (max 5)
- Tapping any surah navigates to Surah Detail

### 5.2 Surah List (Tab 2)

**Purpose:** Browse all 114 surahs and manage their status.

**Content:**
- Search bar (filter by surah name — applied in-memory at the Riverpod provider level, combined with the status filter chip)
- Filter chip bar: "Semua" | "Sudah Hafal" | "Sedang Dihafal" | "Perlu Murojaah" | "Belum Mulai"
- List of `SurahTile` widgets, each showing:
  - Surah number, name, Arabic name
  - Total verses + juz info
  - `StatusBadge` (color-coded by status)
- Tapping a tile navigates to Surah Detail

### 5.3 Surah Detail (Push Route)

**Purpose:** Read verses and manage surah + verse-level interaction.

**Content:**
- App bar: surah name + Arabic name
- Surah status button (tapping opens `StatusBottomSheet` to change status)
- Scrollable list of `VerseCard` widgets, each showing:
  - Arabic text (right-aligned, Arabic font, large)
  - Verse number indicator
  - Indonesian translation
  - Tap-to-toggle per-verse memorization indicator — stored in a separate `MarkedVerseRecord` Isar collection (keyed by `surahId` + `verseNumber`). `VerseModel` remains read-only.
- Bismillah header (for non-Tawbah surahs)

> **Note on per-verse interaction:** For MVP, tapping a verse toggles a visual "marked" state. This is persisted in `MarkedVerseRecord` (not `VerseModel`, which is read-only seed data). It serves as a reading aid, not a full memorization tracking system. Full per-verse tracking can be added post-MVP.

### 5.4 Statistics (Tab 3)

**Purpose:** Summary of memorization progress.

**Content:**
- Circular or segmented progress indicator showing the 4-status breakdown
- Stat cards for each status with count and percentage:
  - Sudah Hafal
  - Sedang Dihafal
  - Perlu Murojaah
  - Belum Mulai
- Total verse count memorized (sum of verses from `memorized` surahs)

---

## 6. Visual Design

### Theme: Dark Elegant

| Token | Value |
|---|---|
| Background | `#0F1F1A` |
| Surface | `#1A3328` |
| Primary (gold) | `#C9A84C` |
| On-surface text | `#E8D5A3` |
| Secondary text | `#8AB5A0` |
| Error / needs review | `#E88080` |
| In progress | `#4A8A64` |

### Typography
- Arabic text: **Scheherazade New** (Google Fonts) — optimized for Quranic text
- UI text: **Inter** or system font
- Arabic verse font size: 22sp, line height 2.0
- Translation font size: 13sp

### Status Colors

| Status | Color | Label |
|---|---|---|
| `memorized` | Gold `#C9A84C` | Sudah Hafal |
| `inProgress` | Green `#4A8A64` | Sedang Dihafal |
| `needsReview` | Red `#E88080` | Perlu Murojaah |
| `notStarted` | Muted `#3A5A4A` | Belum Mulai |

---

## 7. Navigation

Router: `go_router`

| Route | Path | Description |
|---|---|---|
| Home | `/` | Tab scaffold entry |
| Surah List | `/surahs` | Tab 2 |
| Statistics | `/stats` | Tab 3 |
| Surah Detail | `/surahs/:id` | Push from Surah List or Home |

Bottom navigation persists across Tab 1–3. Surah Detail sits on top of the navigation stack (push route, not a tab).

---

## 8. Tech Stack

| Concern | Package | Version strategy |
|---|---|---|
| State management | `riverpod` + `flutter_riverpod` + `hooks_riverpod` | Latest stable |
| Local database | `isar` + `isar_flutter_libs` | Latest stable |
| Code generation | `isar_generator` + `build_runner` | Match isar version |
| Navigation | `go_router` | Latest stable |
| Arabic font | `google_fonts` | Latest stable |
| Linting | `very_good_analysis` | Latest stable |

**Data source:** `quran-json` open source dataset (MIT licensed), bundled as `assets/data/quran_id.json`.

The JSON structure follows this shape:
```json
[
  {
    "id": 1,
    "name": "Al-Fatihah",
    "name_arabic": "الفاتحة",
    "verses_count": 7,
    "juz": [1],
    "revelation_place": "mecca",
    "verses": [
      {
        "id": 1,
        "text": "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        "translation": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang"
      }
    ]
  }
]
```

`QuranLocalDataSource` maps these fields to `SurahModel` and `VerseModel` during seed. For `juz`, which is an array in the JSON (e.g., `[1, 2, 3]` for surahs spanning multiple juz), only the first element is taken as `juzStart`. This is sufficient for MVP display ("Juz 1") and grouping purposes.

**Min SDK:**
- Android: API 21 (Android 5.0)
- iOS: 12.0

---

## 9. Future Considerations (Post-MVP)

The following are explicitly out of scope for MVP but the architecture supports them:

- **Backend sync:** Add `RemoteDataSource` in `data/datasources/remote/` — no domain or UI changes needed
- **User accounts:** Auth layer slots in at the data layer
- **Audio playback:** `VerseModel` can be extended with `audioUrl`
- **Full per-verse tracking:** Promote the simple verse-mark system to a proper `VerseMemorizationRecord`
- **Notifications:** Murojaah reminders using `flutter_local_notifications`
- **Juz navigation:** Filter/group surahs by juz on the Surah List page
- **Dark/light theme toggle:** Theme system is token-based, easy to add a light variant

---

## 10. Out of Scope for MVP

- User login / registration
- Cloud sync / backup
- Audio playback (murottal)
- Tajweed coloring
- Multiple translations
- Sharing progress
- Widgets (home screen)
