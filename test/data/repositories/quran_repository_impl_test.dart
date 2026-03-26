import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/datasources/local/quran_local_datasource.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/data/models/surah_model.dart';
import 'package:zikrq/data/models/verse_model.dart';
import 'package:zikrq/data/repositories/quran_repository_impl.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class MockQuranLocalDatasource extends Mock implements QuranLocalDatasource {}

class MockMemorizationLocalDatasource extends Mock
    implements MemorizationLocalDatasource {}

SurahModel _fakeSurahModel(int id) => SurahModel()
  ..surahId = id
  ..name = 'Surah $id'
  ..nameArabic = 'سورة'
  ..totalVerses = 7
  ..juzStart = 1
  ..revelation = 'Meccan';

MemorizationRecordModel _fakeRecord(int surahId, int statusIndex) =>
    MemorizationRecordModel()
      ..surahId = surahId
      ..statusIndex = statusIndex
      ..updatedAt = DateTime.now();

void main() {
  late MockQuranLocalDatasource quranDs;
  late MockMemorizationLocalDatasource memDs;
  late QuranRepositoryImpl repo;

  setUp(() {
    quranDs = MockQuranLocalDatasource();
    memDs = MockMemorizationLocalDatasource();
    repo = QuranRepositoryImpl(
      quranDatasource: quranDs,
      memorizationDatasource: memDs,
    );
  });

  test('getAllSurahs maps status from record', () async {
    when(
      () => quranDs.getAllSurahModels(),
    ).thenAnswer((_) async => [_fakeSurahModel(1)]);
    when(() => memDs.getAllRecords()).thenAnswer(
      (_) async => [_fakeRecord(1, MemorizationStatus.memorized.index)],
    );

    final surahs = await repo.getAllSurahs();
    expect(surahs.first.status, MemorizationStatus.memorized);
  });

  test('getAllSurahs with filter returns only matching', () async {
    when(
      () => quranDs.getAllSurahModels(),
    ).thenAnswer((_) async => [_fakeSurahModel(1), _fakeSurahModel(2)]);
    when(() => memDs.getAllRecords()).thenAnswer(
      (_) async => [
        _fakeRecord(1, MemorizationStatus.memorized.index),
        _fakeRecord(2, MemorizationStatus.notStarted.index),
      ],
    );

    final result = await repo.getAllSurahs(
      filter: MemorizationStatus.memorized,
    );
    expect(result.length, 1);
    expect(result.first.id, 1);
  });

  test('getMemorizationStats counts correctly', () async {
    when(
      () => quranDs.getAllSurahModels(),
    ).thenAnswer((_) async => [_fakeSurahModel(1), _fakeSurahModel(2)]);
    when(() => memDs.getAllRecords()).thenAnswer(
      (_) async => [
        _fakeRecord(1, MemorizationStatus.memorized.index),
        _fakeRecord(2, MemorizationStatus.inProgress.index),
      ],
    );

    final stats = await repo.getMemorizationStats();
    expect(stats.memorized, 1);
    expect(stats.inProgress, 1);
    expect(stats.memorizedVerseCount, 7); // 1 memorized surah × 7 verses
  });
}
