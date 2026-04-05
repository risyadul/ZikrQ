// lib/data/datasources/local/memorization_local_datasource.dart
import 'package:isar/isar.dart';
import 'package:zikrq/data/models/marked_verse_record_model.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';

class MemorizationLocalDatasource {
  const MemorizationLocalDatasource(this._isar);
  final Isar _isar;

  static int nextLocalChangeVersion(int currentVersion) {
    if (currentVersion <= 0) {
      return 1;
    }
    return currentVersion + 1;
  }

  Future<List<MemorizationRecordModel>> getAllRecords() =>
      _isar.memorizationRecordModels.where().findAll();

  Future<MemorizationRecordModel?> getRecord(int surahId) => _isar
      .memorizationRecordModels
      .filter()
      .surahIdEqualTo(surahId)
      .findFirst();

  Future<void> updateStatus(int surahId, int statusIndex) async {
    final record = await getRecord(surahId);
    if (record == null) return;
    await _isar.writeTxn(() async {
      record
        ..statusIndex = statusIndex
        ..updatedAt = DateTime.now()
        ..localChangeVersion = nextLocalChangeVersion(
          record.localChangeVersion,
        );
      await _isar.memorizationRecordModels.put(record);
    });
  }

  Future<void> updateStatusesTransactional(
    List<int> surahIds,
    int statusIndex,
  ) async {
    if (surahIds.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      final now = DateTime.now();
      for (final surahId in surahIds) {
        final record = await _isar.memorizationRecordModels
            .filter()
            .surahIdEqualTo(surahId)
            .findFirst();
        if (record == null) {
          continue;
        }

        record
          ..statusIndex = statusIndex
          ..updatedAt = now
          ..localChangeVersion = nextLocalChangeVersion(
            record.localChangeVersion,
          );
        await _isar.memorizationRecordModels.put(record);
      }
    });
  }

  Future<void> updateLastAccessed(int surahId) async {
    final record = await getRecord(surahId);
    if (record == null) return;
    await _isar.writeTxn(() async {
      record
        ..lastAccessedAt = DateTime.now()
        ..localChangeVersion = nextLocalChangeVersion(
          record.localChangeVersion,
        );
      await _isar.memorizationRecordModels.put(record);
    });
  }

  Future<List<MemorizationRecordModel>> getRecentlyAccessed(int limit) => _isar
      .memorizationRecordModels
      .filter()
      .lastAccessedAtIsNotNull()
      .sortByLastAccessedAtDesc()
      .limit(limit)
      .findAll();

  /// Record presence = marked, absence = not marked.
  Future<bool> isVerseMark(int surahId, int verseNumber) async {
    final record = await _isar.markedVerseRecordModels.getBySurahIdVerseNumber(
      surahId,
      verseNumber,
    );
    return record != null;
  }

  /// Toggle: delete record if present (unmark), insert if absent (mark).
  Future<void> toggleVerseMark(int surahId, int verseNumber) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.markedVerseRecordModels
          .getBySurahIdVerseNumber(surahId, verseNumber);
      if (existing != null) {
        await _isar.markedVerseRecordModels.delete(existing.id);
      } else {
        final record = MarkedVerseRecordModel()
          ..surahId = surahId
          ..verseNumber = verseNumber;
        await _isar.markedVerseRecordModels.put(record);
      }
    });
  }
}
