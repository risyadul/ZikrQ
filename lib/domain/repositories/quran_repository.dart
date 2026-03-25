import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/entities/verse.dart';

abstract interface class QuranRepository {
  Future<List<Surah>> getAllSurahs({MemorizationStatus? filter});
  Future<List<Verse>> getVersesBySurah(int surahId);
  Future<void> updateMemorizationStatus(int surahId, MemorizationStatus status);
  Future<void> toggleVerseMark(int surahId, int verseNumber);

  /// Called directly from the presentation layer (no use case wrapper needed —
  /// these are point queries, not orchestration).
  Future<bool> isVerseMark(int surahId, int verseNumber);
  Future<void> updateLastAccessed(int surahId);
  Future<MemorizationStats> getMemorizationStats();
  Future<void> seedIfEmpty();
}
