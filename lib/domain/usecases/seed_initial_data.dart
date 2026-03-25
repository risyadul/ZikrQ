import 'package:zikrq/domain/repositories/quran_repository.dart';

class SeedInitialDataUseCase {
  const SeedInitialDataUseCase(this._repository);
  final QuranRepository _repository;

  Future<void> call() => _repository.seedIfEmpty();
}
