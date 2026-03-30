import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';

class BulkUpdateSurahStatusUseCase {
  const BulkUpdateSurahStatusUseCase(this._repository);

  final QuickActionRepository _repository;

  Future<void> call({
    required List<int> surahIds,
    required MemorizationStatus status,
  }) async {
    await _repository.applyStatusToSurahs(surahIds: surahIds, status: status);
    await _repository.setLastUsedStatusAction(status);
  }
}
