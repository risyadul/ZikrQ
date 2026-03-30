# ZikrQ

A Quran memorization tracker for Android and iOS. Built with Flutter using Clean Architecture, Riverpod, and Isar — works fully offline.

---

## Features

- **114 Surahs** with Arabic text and Indonesian translation
- **4 memorization statuses** per surah: Not Started, In Progress, Memorized, Needs Review
- **Per-verse marking** as a reading aid (persisted locally)
- **Statistics** — overall memorization progress summary
- **Recently accessed** — last opened surahs shown on the Home screen
- **Review reminders** — surahs marked Needs Review are highlighted on Home
- **Daily habit dashboard** — target ayat, today's progress, and focused review queue
- **Quick status actions** — long-press surah tile for one-tap status update
- **Bulk update mode** — apply a status to multiple selected surahs at once
- **Personalized settings** — daily target, active days, default quick action, haptic/sound
- **Local reminder notifications** — configurable schedule with permission-aware flow
- **Sync-ready local metadata** — local change versions persisted for future cloud sync
- Search and filter surahs by status
- Swipe-left gesture on a surah tile to change its status directly from the list
- Fully offline — no network requests whatsoever

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` + `hooks_riverpod` |
| Local database | `isar` + `isar_flutter_libs` |
| Navigation | `go_router` |
| Linting | `very_good_analysis` |
| Testing | `flutter_test` + `mocktail` |
| Code generation | `build_runner` + `isar_generator` |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.0`
- Dart SDK `^3.11.0`
- Android Studio / Xcode (for device or emulator)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate Isar schemas (required after the first clone)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

### Build

```bash
flutter build apk    # Android release APK
flutter build ios    # iOS release (requires macOS + Xcode)
```

---

## Development

### Analyze & Format

```bash
flutter analyze                                              # static analysis
dart format .                                               # auto-format
dart format --output=none --set-exit-if-changed .           # CI format check
```

### Test

```bash
flutter test                                                # full test suite
flutter test test/domain/usecases/get_all_surahs_test.dart  # single file
flutter test --name "returns surahs from repository"        # single test by name
flutter test --coverage                                     # with coverage report
```

### Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs    # one-shot
dart run build_runner watch --delete-conflicting-outputs    # watch mode
```

> Never edit `.g.dart` files manually — they are fully generated.

---

## Architecture

Clean Architecture with three layers:

```
lib/
  core/           # Theme, colors, constants
  domain/         # Entities, repository interfaces, use cases (pure Dart)
  data/           # Isar implementation, datasources, repository
  presentation/   # Riverpod providers, pages, widgets
```

Dependency direction: `presentation → domain ← data`. The `domain` layer must not import from `data` or `presentation`.

See `AGENTS.md` for full code, testing, and architecture conventions.

---

## Data

Quran data is sourced from the open-source [quran-json](https://github.com/risan/quran-json) dataset (MIT License), bundled as a local asset at `assets/data/quran_id.json`. Data is seeded into Isar on the first app launch.
