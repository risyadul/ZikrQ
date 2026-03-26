// lib/data/repositories/quran_repository_impl.dart
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/datasources/local/quran_local_datasource.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/data/models/surah_model.dart';
import 'package:zikrq/data/models/verse_model.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/entities/verse.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  const QuranRepositoryImpl({
    required QuranLocalDatasource quranDatasource,
    required MemorizationLocalDatasource memorizationDatasource,
  }) : _quran = quranDatasource,
       _memorization = memorizationDatasource;

  final QuranLocalDatasource _quran;
  final MemorizationLocalDatasource _memorization;

  @override
  Future<void> seedIfEmpty() => _quran.seedFromAssets();
  // Note: seedFromAssets() already guards against double-seeding internally.
  // No need to check isEmpty here.

  @override
  Future<List<Surah>> getAllSurahs({MemorizationStatus? filter}) async {
    final surahModels = await _quran.getAllSurahModels();
    final records = await _memorization.getAllRecords();
    final recordMap = {for (final r in records) r.surahId: r};

    final surahs = surahModels.map((m) {
      final record = recordMap[m.surahId];
      return _toSurah(m, record);
    }).toList();

    if (filter != null) {
      return surahs.where((s) => s.status == filter).toList();
    }
    return surahs;
  }

  @override
  Future<List<Verse>> getVersesBySurah(int surahId) async {
    final models = await _quran.getVersesBySurahId(surahId);
    return models.map(_toVerse).toList();
  }

  @override
  Future<void> updateMemorizationStatus(
    int surahId,
    MemorizationStatus status,
  ) => _memorization.updateStatus(surahId, status.index);

  @override
  Future<void> toggleVerseMark(int surahId, int verseNumber) =>
      _memorization.toggleVerseMark(surahId, verseNumber);

  @override
  Future<bool> isVerseMark(int surahId, int verseNumber) =>
      _memorization.isVerseMark(surahId, verseNumber);

  @override
  Future<void> updateLastAccessed(int surahId) =>
      _memorization.updateLastAccessed(surahId);

  @override
  Future<MemorizationStats> getMemorizationStats() async {
    final surahs = await getAllSurahs();
    var memorized = 0;
    var inProgress = 0;
    var needsReview = 0;
    var notStarted = 0;
    var memorizedVerseCount = 0;

    for (final s in surahs) {
      switch (s.status) {
        case MemorizationStatus.memorized:
          memorized++;
          memorizedVerseCount += s.totalVerses;
        case MemorizationStatus.inProgress:
          inProgress++;
        case MemorizationStatus.needsReview:
          needsReview++;
        case MemorizationStatus.notStarted:
          notStarted++;
      }
    }

    return MemorizationStats(
      memorized: memorized,
      inProgress: inProgress,
      needsReview: needsReview,
      notStarted: notStarted,
      total: surahs.length,
      memorizedVerseCount: memorizedVerseCount,
    );
  }

  // --- Mappers ---

  // CAUTION: Uses MemorizationStatus.values[record.statusIndex].
  // This will break silently if enum order is changed — statusIndex is the
  // persisted Isar value and must remain stable across app versions.
  Surah _toSurah(SurahModel m, MemorizationRecordModel? record) => Surah(
    id: m.surahId,
    name: m.name,
    nameArabic: m.nameArabic,
    totalVerses: m.totalVerses,
    juzStart: m.juzStart,
    revelation: m.revelation,
    status: record != null
        ? MemorizationStatus.values[record.statusIndex]
        : MemorizationStatus.notStarted,
  );

  Verse _toVerse(VerseModel m) => Verse(
    id: m.verseId,
    surahId: m.surahId,
    number: m.number,
    arabic: m.arabic,
    translation: m.translation,
  );
}
