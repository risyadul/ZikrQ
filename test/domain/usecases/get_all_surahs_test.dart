import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/get_all_surahs.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late GetAllSurahsUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = GetAllSurahsUseCase(repo);
  });

  test('calls getAllSurahs with no filter', () async {
    when(() => repo.getAllSurahs()).thenAnswer((_) async => []);
    await useCase();
    verify(() => repo.getAllSurahs()).called(1);
  });

  test('calls getAllSurahs with status filter', () async {
    when(
      () => repo.getAllSurahs(filter: MemorizationStatus.memorized),
    ).thenAnswer((_) async => []);
    await useCase(filter: MemorizationStatus.memorized);
    verify(
      () => repo.getAllSurahs(filter: MemorizationStatus.memorized),
    ).called(1);
  });

  test('returns surahs from repository', () async {
    final surahs = [
      const Surah(
        id: 1,
        name: 'Al-Fatihah',
        nameArabic: 'الفاتحة',
        totalVerses: 7,
        juzStart: 1,
        revelation: 'Meccan',
        status: MemorizationStatus.memorized,
      ),
    ];
    when(() => repo.getAllSurahs()).thenAnswer((_) async => surahs);
    final result = await useCase();
    expect(result, surahs);
  });
}
