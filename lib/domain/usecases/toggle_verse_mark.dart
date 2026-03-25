import 'package:zikrq/domain/repositories/quran_repository.dart';

class ToggleVerseMarkUseCase {
  const ToggleVerseMarkUseCase(this._repository);
  final QuranRepository _repository;

  Future<void> call(int surahId, int verseNumber) =>
      _repository.toggleVerseMark(surahId, verseNumber);
}
