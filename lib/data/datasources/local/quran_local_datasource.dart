// lib/data/datasources/local/quran_local_datasource.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/data/models/surah_model.dart';
import 'package:zikrq/data/models/verse_model.dart';

class QuranLocalDatasource {
  const QuranLocalDatasource(this._isar);
  final Isar _isar;

  Future<bool> get isEmpty async => await _isar.surahModels.count() == 0;

  Future<void> seedFromAssets() async {
    final jsonString = await rootBundle.loadString(AppConstants.quranAssetPath);
    final data = json.decode(jsonString) as List<dynamic>;

    await _isar.writeTxn(() async {
      for (final surahJson in data) {
        final map = surahJson as Map<String, dynamic>;
        final surahId = map['id'] as int;

        final surahModel = SurahModel()
          ..surahId = surahId
          ..name = map['transliteration'] as String
          ..nameArabic = map['name'] as String
          ..totalVerses = map['total_verses'] as int
          ..juzStart = _juzForSurah(surahId)
          ..revelation = (map['type'] as String) == 'meccan'
              ? 'Meccan'
              : 'Medinan';

        await _isar.surahModels.put(surahModel);

        final verses = (map['verses'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        for (var i = 0; i < verses.length; i++) {
          final verseJson = verses[i];
          final verseModel = VerseModel()
            ..verseId = verseJson['id'] as int
            ..surahId = surahId
            ..number =
                i +
                1 // 1-based position within surah
            ..arabic = verseJson['text'] as String
            ..translation = verseJson['translation'] as String;
          await _isar.verseModels.put(verseModel);
        }

        final record = MemorizationRecordModel()
          ..surahId = surahId
          ..statusIndex =
              0 // notStarted
          ..updatedAt = DateTime.now()
          ..lastAccessedAt = null;
        await _isar.memorizationRecordModels.put(record);
      }
    });
  }

  Future<List<SurahModel>> getAllSurahModels() =>
      _isar.surahModels.where().sortBySurahId().findAll();

  Future<List<VerseModel>> getVersesBySurahId(int surahId) =>
      _isar.verseModels.filter().surahIdEqualTo(surahId).findAll();

  /// Returns which Juz a surah starts in.
  /// Standard 30-juz division of the Quran.
  static int _juzForSurah(int surahId) {
    const juzMap = <int, int>{
      1: 1,
      2: 1,
      3: 3,
      4: 4,
      5: 6,
      6: 7,
      7: 8,
      8: 9,
      9: 10,
      10: 11,
      11: 11,
      12: 12,
      13: 13,
      14: 13,
      15: 14,
      16: 14,
      17: 15,
      18: 15,
      19: 16,
      20: 16,
      21: 17,
      22: 17,
      23: 18,
      24: 18,
      25: 18,
      26: 19,
      27: 19,
      28: 20,
      29: 20,
      30: 21,
      31: 21,
      32: 21,
      33: 21,
      34: 22,
      35: 22,
      36: 22,
      37: 23,
      38: 23,
      39: 23,
      40: 24,
      41: 24,
      42: 25,
      43: 25,
      44: 25,
      45: 25,
      46: 26,
      47: 26,
      48: 26,
      49: 26,
      50: 26,
      51: 26,
      52: 27,
      53: 27,
      54: 27,
      55: 27,
      56: 27,
      57: 27,
      58: 28,
      59: 28,
      60: 28,
      61: 28,
      62: 28,
      63: 28,
      64: 28,
      65: 28,
      66: 28,
      67: 29,
      68: 29,
      69: 29,
      70: 29,
      71: 29,
      72: 29,
      73: 29,
      74: 29,
      75: 29,
      76: 29,
      77: 29,
      78: 30,
      79: 30,
      80: 30,
      81: 30,
      82: 30,
      83: 30,
      84: 30,
      85: 30,
      86: 30,
      87: 30,
      88: 30,
      89: 30,
      90: 30,
      91: 30,
      92: 30,
      93: 30,
      94: 30,
      95: 30,
      96: 30,
      97: 30,
      98: 30,
      99: 30,
      100: 30,
      101: 30,
      102: 30,
      103: 30,
      104: 30,
      105: 30,
      106: 30,
      107: 30,
      108: 30,
      109: 30,
      110: 30,
      111: 30,
      112: 30,
      113: 30,
      114: 30,
    };
    return juzMap[surahId] ?? 1;
  }
}
