import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';

class GetAllSurahsUseCase {
  const GetAllSurahsUseCase(this._repository);
  final QuranRepository _repository;

  Future<List<Surah>> call({MemorizationStatus? filter}) =>
      _repository.getAllSurahs(filter: filter);
}
