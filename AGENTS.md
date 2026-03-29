# AGENTS.md — ZikrQ

Flutter Quran-memorization tracker. Clean Architecture with Riverpod, Isar, and go_router.
SDK constraint: `^3.11.0`. Linter: `very_good_analysis`.

---

## Commands

### Run / build
```
flutter run                         # debug on connected device
flutter build apk                   # Android release
flutter build ios                   # iOS release
```

### Analyze & format
```
flutter analyze                     # static analysis (very_good_analysis rules)
dart format .                       # auto-format all Dart files
dart format --output=none --set-exit-if-changed .   # CI format check
```

### Tests
```
flutter test                        # run entire test suite
flutter test test/domain/usecases/get_all_surahs_test.dart   # single file
flutter test --name "returns surahs from repository"         # single test by name
flutter test --coverage             # with coverage report
```

All test files live under `test/` and mirror the `lib/` directory structure exactly.

### Code generation (Isar schemas + Riverpod)
```
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # continuous
```
Never edit `.g.dart` files manually — they are fully generated.

---

## Architecture

```
lib/
  core/
    constants/      # AppConstants (abstract final class, only static members)
    theme/          # AppColors, AppTextStyles, AppTheme
  domain/
    entities/       # pure Dart, @immutable, no Flutter imports
    repositories/   # abstract interface class contracts
    usecases/       # one class per use case, exposes call()
  data/
    datasources/local/   # Isar queries
    models/              # Isar @Collection models + .g.dart parts
    repositories/        # QuranRepositoryImpl (@immutable)
  presentation/
    pages/          # one subdirectory per screen
    providers/      # Riverpod providers (core_providers.dart wires the DI graph)
    widgets/        # shared widgets
```

Dependency direction: `presentation → domain ← data`. No domain class may import from `data` or `presentation`.

---

## Project-Specific Rules (non-negotiable)

These rules override general Flutter conventions and are enforced by code review and the design specs in `docs/superpowers/specs/`.

- **No relative imports.** Always use `package:zikrq/…` — never `../` or `./`.
- **No `.withOpacity()`.** Use `.withValues(alpha: x)` instead — `.withOpacity` is deprecated in this project.
- **No runtime font fetching.** Fonts (Poppins, Scheherazade New) are bundled as local TTF assets under `assets/fonts/`. `google_fonts` is NOT used for runtime delivery; use native Flutter font registration (`fontFamily: 'Poppins'`).
- **Provider invalidation after every mutation.** After any status change, invalidate all four affected providers before popping:
  ```dart
  ref.invalidate(surahListProvider);
  ref.invalidate(memorizationStatsProvider);
  ref.invalidate(recentlyAccessedProvider);
  ref.invalidate(needsReviewProvider);
  ```
- **Do not upgrade the Flutter/Dart SDK** without explicit approval — existing constraints must be respected.

---

## Code Style

### File header comment
Every file begins with a path comment on line 1:
```dart
// lib/data/models/surah_model.dart
```

### Import ordering (enforced by `very_good_analysis`)
1. `dart:` — Dart SDK
2. `package:flutter/` — Flutter framework
3. Third-party packages (`package:isar/`, `package:riverpod/`, …)
4. Own package (`package:zikrq/…`)

No blank lines between imports within each group; one blank line between groups.

### Class patterns
- **Utility / namespace classes** use `abstract final class` with only `static` members:
  ```dart
  abstract final class AppConstants {
    static const appName = 'ZikrQ';
  }
  ```
- **Repository contracts** use `abstract interface class`.
- **Entities and repository implementations** are annotated `@immutable` (from `package:meta`).
- **Use cases** are plain classes with a `const` constructor and a single `call()` method.

### Constructors & fields
- Always use `const` constructors where possible.
- Prefer `required` named parameters over positional for more than one argument.
- Private fields are prefixed with `_`.
- Isar model fields use `late` (not `final`) because Isar requires mutable fields.

### Immutability
- Domain entities implement `==` and `hashCode` manually; use `Object.hash()` for multiple fields.
- Entity `==` only compares identity-relevant fields (see `Surah`: id + status only).
- Provide `copyWith` when the UI needs to produce updated values.

### Enums
- Prefer `enum` with members and computed getters:
  ```dart
  enum MemorizationStatus {
    notStarted, inProgress, memorized, needsReview;
    String get label => switch (this) { ... };
  }
  ```
- **Never reorder** enum values whose `.index` is persisted to Isar — append only.

### Switch expressions
Use exhaustive `switch` expressions (no `default` for sealed/enum switches):
```dart
case MemorizationStatus.memorized: ...
case MemorizationStatus.inProgress: ...
// all cases listed — no default
```

### TODO comments
```dart
// TODO(label): explanation
```
Use a short scope label (e.g. `mvp`, `perf`, `cleanup`) in parentheses.

---

## Riverpod Conventions

- Providers are defined in `presentation/providers/`.
- `core_providers.dart` owns the full DI graph: Isar instance → datasources → repository → use cases.
- The Isar instance is injected via `isarProvider.overrideWithValue(isar)` in `main()`.
- Prefer `FutureProvider` / `FutureProvider.family` for async data; `StateProvider` for simple UI state.
- Invalidate providers with `ref.invalidate(provider)` after mutations instead of managing state manually.
- In tests, use `ProviderContainer` with `overrides` and call `addTearDown(container.dispose)`.

---

## Testing Conventions

- **Framework**: `flutter_test` + `mocktail`.
- Mock classes are defined at the top of each test file:
  ```dart
  class MockQuranRepository extends Mock implements QuranRepository {}
  ```
- Fake data builders are top-level functions prefixed with `_fake` or `_surah`:
  ```dart
  Surah _surah(int id, String name) => Surah(...);
  ```
- Provider tests: construct a `ProviderContainer` with `overrides` inside a helper function, add teardown, then `await container.read(provider.future)`.
- Use case tests: instantiate the use case with a mock repository in `setUp`, use `when/verify` from mocktail.
- Widget tests use `ConsumerWidget` testing helpers from `flutter_riverpod`.
- Test names are plain English descriptions: `'returns surahs from repository'`, not `'test1'`.

---

## Isar Models

- Annotate with `@Collection()`.
- Always include `part 'filename.g.dart';`.
- `Id id = Isar.autoIncrement;` is the standard primary key pattern.
- Use `@Index(unique: true)` for business-key fields (e.g. `surahId`).
- Map Isar models to domain entities in the repository (`_toSurah`, `_toVerse`). Domain entities never leak into the data layer.
- `statusIndex` (int) is the persisted form of `MemorizationStatus` — treat its ordinal as a stable contract.

---

## Error Handling

- Repositories surface errors as uncaught exceptions; callers handle them via `AsyncValue.error` in Riverpod or `try/catch` in `main()`.
- UI uses `.when(loading:, error:, data:)` on `AsyncValue` — always handle all three branches.
- Null safety: prefer `??` and `?.` over `!`, except where the nullability is a logic error (then assert or let it throw).
- Do not swallow exceptions silently; at minimum rethrow or log before returning a fallback.
