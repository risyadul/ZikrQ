import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/get_all_surahs.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

Surah _surah(int id, String name) => Surah(
  id: id,
  name: name,
  nameArabic: 'س',
  totalVerses: 7,
  juzStart: 1,
  revelation: 'Meccan',
  status: MemorizationStatus.notStarted,
);

void main() {
  late MockQuranRepository repo;

  setUp(() {
    repo = MockQuranRepository();
    registerFallbackValue(MemorizationStatus.notStarted);
  });

  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [
      quranRepositoryProvider.overrideWithValue(repo),
      getAllSurahsUseCaseProvider.overrideWith(
        (ref) => GetAllSurahsUseCase(repo),
      ),
    ],
  );

  test('returns all surahs when no filter or search', () async {
    when(() => repo.getAllSurahs(filter: null)).thenAnswer(
      (_) async => [_surah(1, 'Al-Fatihah'), _surah(2, 'Al-Baqarah')],
    );

    final container = makeContainer();
    addTearDown(container.dispose);
    final result = await container.read(surahListProvider.future);
    expect(result.length, 2);
  });

  test('filters by search query', () async {
    when(() => repo.getAllSurahs(filter: null)).thenAnswer(
      (_) async => [_surah(1, 'Al-Fatihah'), _surah(2, 'Al-Baqarah')],
    );

    final container = makeContainer();
    addTearDown(container.dispose);
    container.read(surahSearchQueryProvider.notifier).state = 'fatihah';
    final result = await container.read(surahListProvider.future);
    expect(result.length, 1);
    expect(result.first.name, 'Al-Fatihah');
  });

  test('passes status filter to use case', () async {
    when(
      () => repo.getAllSurahs(filter: MemorizationStatus.memorized),
    ).thenAnswer((_) async => [_surah(1, 'Al-Fatihah')]);

    final container = makeContainer();
    addTearDown(container.dispose);
    container.read(surahStatusFilterProvider.notifier).state =
        MemorizationStatus.memorized;
    final result = await container.read(surahListProvider.future);
    expect(result.length, 1);
  });
}
