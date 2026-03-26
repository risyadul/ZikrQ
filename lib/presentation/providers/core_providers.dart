// lib/presentation/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/datasources/local/quran_local_datasource.dart';
import 'package:zikrq/data/repositories/quran_repository_impl.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/get_all_surahs.dart';
import 'package:zikrq/domain/usecases/get_memorization_stats.dart';
import 'package:zikrq/domain/usecases/get_verses_by_surah.dart';
import 'package:zikrq/domain/usecases/seed_initial_data.dart';
import 'package:zikrq/domain/usecases/toggle_verse_mark.dart';
import 'package:zikrq/domain/usecases/update_memorization_status.dart';

// Isar instance — opened once on startup
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

// Datasources
final quranLocalDatasourceProvider = Provider<QuranLocalDatasource>(
  (ref) => QuranLocalDatasource(ref.watch(isarProvider)),
);

final memorizationLocalDatasourceProvider =
    Provider<MemorizationLocalDatasource>(
      (ref) => MemorizationLocalDatasource(ref.watch(isarProvider)),
    );

// Repository
final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepositoryImpl(
    quranDatasource: ref.watch(quranLocalDatasourceProvider),
    memorizationDatasource: ref.watch(memorizationLocalDatasourceProvider),
  ),
);

// Use cases
final getAllSurahsUseCaseProvider = Provider<GetAllSurahsUseCase>(
  (ref) => GetAllSurahsUseCase(ref.watch(quranRepositoryProvider)),
);

final getVersesBySurahUseCaseProvider = Provider<GetVersesBySurahUseCase>(
  (ref) => GetVersesBySurahUseCase(ref.watch(quranRepositoryProvider)),
);

final updateMemorizationStatusUseCaseProvider =
    Provider<UpdateMemorizationStatusUseCase>(
      (ref) =>
          UpdateMemorizationStatusUseCase(ref.watch(quranRepositoryProvider)),
    );

final toggleVerseMarkUseCaseProvider = Provider<ToggleVerseMarkUseCase>(
  (ref) => ToggleVerseMarkUseCase(ref.watch(quranRepositoryProvider)),
);

final getMemorizationStatsUseCaseProvider =
    Provider<GetMemorizationStatsUseCase>(
      (ref) => GetMemorizationStatsUseCase(ref.watch(quranRepositoryProvider)),
    );

final seedInitialDataUseCaseProvider = Provider<SeedInitialDataUseCase>(
  (ref) => SeedInitialDataUseCase(ref.watch(quranRepositoryProvider)),
);
