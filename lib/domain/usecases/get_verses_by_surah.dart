import 'package:zikrq/domain/entities/verse.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';

class GetVersesBySurahUseCase {
  const GetVersesBySurahUseCase(this._repository);
  final QuranRepository _repository;

  Future<List<Verse>> call(int surahId) =>
      _repository.getVersesBySurah(surahId);
}
