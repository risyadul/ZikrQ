import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';

class UpdateMemorizationStatusUseCase {
  const UpdateMemorizationStatusUseCase(this._repository);
  final QuranRepository _repository;

  Future<void> call(int surahId, MemorizationStatus status) =>
      _repository.updateMemorizationStatus(surahId, status);
}
