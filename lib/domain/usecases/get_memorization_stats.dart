import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';

class GetMemorizationStatsUseCase {
  const GetMemorizationStatsUseCase(this._repository);
  final QuranRepository _repository;

  Future<MemorizationStats> call() => _repository.getMemorizationStats();
}
