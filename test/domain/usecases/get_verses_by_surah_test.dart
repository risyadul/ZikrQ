import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/verse.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/get_verses_by_surah.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late GetVersesBySurahUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = GetVersesBySurahUseCase(repo);
  });

  test('delegates to repository with surahId', () async {
    when(() => repo.getVersesBySurah(1)).thenAnswer((_) async => []);
    await useCase(1);
    verify(() => repo.getVersesBySurah(1)).called(1);
  });

  test('returns verses from repository', () async {
    final verses = [
      const Verse(
        id: 1,
        surahId: 1,
        number: 1,
        arabic: 'بِسْمِ ٱللَّهِ',
        translation: 'Dengan nama Allah',
      ),
    ];
    when(() => repo.getVersesBySurah(1)).thenAnswer((_) async => verses);
    final result = await useCase(1);
    expect(result, verses);
  });
}
