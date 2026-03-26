import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/home_provider.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

class MockMemorizationLocalDatasource extends Mock
    implements MemorizationLocalDatasource {}

Surah _surah(int id, String name) => Surah(
  id: id,
  name: name,
  nameArabic: 'س',
  totalVerses: 7,
  juzStart: 1,
  revelation: 'Meccan',
  status: MemorizationStatus.notStarted,
);

MemorizationRecordModel _record(int surahId) {
  final r = MemorizationRecordModel()
    ..surahId = surahId
    ..statusIndex = 0
    ..updatedAt = DateTime.now()
    ..lastAccessedAt = DateTime.now();
  return r;
}

void main() {
  late MockQuranRepository repo;
  late MockMemorizationLocalDatasource memDs;

  setUp(() {
    repo = MockQuranRepository();
    memDs = MockMemorizationLocalDatasource();
    registerFallbackValue(MemorizationStatus.notStarted);
  });

  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [
      quranRepositoryProvider.overrideWithValue(repo),
      memorizationLocalDatasourceProvider.overrideWithValue(memDs),
    ],
  );

  group('recentlyAccessedProvider', () {
    test('returns empty list when datasource returns no records', () async {
      when(() => memDs.getRecentlyAccessed(3)).thenAnswer((_) async => []);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(recentlyAccessedProvider.future);
      expect(result, isEmpty);
    });

    test(
      'maps records to Surah objects, filters orphans via whereType',
      () async {
        // surahId 1 exists in repo, surahId 99 does not (orphan)
        when(
          () => memDs.getRecentlyAccessed(3),
        ).thenAnswer((_) async => [_record(1), _record(99)]);
        when(() => repo.getAllSurahs()).thenAnswer(
          (_) async => [_surah(1, 'Al-Fatihah'), _surah(2, 'Al-Baqarah')],
        );

        final container = makeContainer();
        addTearDown(container.dispose);

        final result = await container.read(recentlyAccessedProvider.future);
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.name, 'Al-Fatihah');
      },
    );
  });

  group('needsReviewProvider', () {
    test('returns max 5 surahs even if more exist', () async {
      final manySurahs = List.generate(
        10,
        (i) => _surah(i + 1, 'Surah ${i + 1}'),
      );
      when(
        () => repo.getAllSurahs(filter: MemorizationStatus.needsReview),
      ).thenAnswer((_) async => manySurahs);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(needsReviewProvider.future);
      expect(result.length, 5);
    });
  });
}
