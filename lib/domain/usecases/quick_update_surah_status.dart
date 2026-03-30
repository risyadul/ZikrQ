import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';

class QuickUpdateSurahStatusUseCase {
  QuickUpdateSurahStatusUseCase(this._repository);

  final QuickActionRepository _repository;

  Future<void> _pending = Future<void>.value();

  Future<void> call({
    required int surahId,
    required MemorizationStatus status,
  }) {
    _pending = _pending
        .catchError((_) {})
        .then((_) => _runUpdate(surahId: surahId, status: status));
    return _pending;
  }

  Future<void> _runUpdate({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    await _repository.applyStatusToSurah(surahId: surahId, status: status);
    await _repository.setLastUsedStatusAction(status);
  }
}
