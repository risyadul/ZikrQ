import 'package:zikrq/domain/entities/memorization_status.dart';

abstract interface class QuickActionRepository {
  Future<MemorizationStatus?> getLastUsedStatusAction();
  Future<void> setLastUsedStatusAction(MemorizationStatus status);
  Future<void> applyStatusToSurahs({
    required List<int> surahIds,
    required MemorizationStatus status,
  });
}
