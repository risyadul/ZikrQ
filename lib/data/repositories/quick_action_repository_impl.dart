import 'package:meta/meta.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';

@immutable
class QuickActionRepositoryImpl implements QuickActionRepository {
  const QuickActionRepositoryImpl({
    required HabitLocalDatasource habitDatasource,
    required MemorizationLocalDatasource memorizationDatasource,
  }) : _habitDatasource = habitDatasource,
       _memorizationDatasource = memorizationDatasource;

  final HabitLocalDatasource _habitDatasource;
  final MemorizationLocalDatasource _memorizationDatasource;

  static MemorizationStatus? _cachedLastUsedStatusAction;

  @override
  Future<MemorizationStatus?> getLastUsedStatusAction() async {
    if (_cachedLastUsedStatusAction != null) {
      return _cachedLastUsedStatusAction;
    }

    await _habitDatasource.getPreference();
    return null;
  }

  @override
  Future<void> setLastUsedStatusAction(MemorizationStatus status) async {
    _cachedLastUsedStatusAction = status;
  }

  @override
  Future<void> applyStatusToSurah({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    await _memorizationDatasource.updateStatus(surahId, status.index);
    await setLastUsedStatusAction(status);
  }

  @override
  Future<void> applyStatusToSurahs({
    required List<int> surahIds,
    required MemorizationStatus status,
  }) async {
    await _memorizationDatasource.updateStatusesTransactional(
      surahIds,
      status.index,
    );
    await setLastUsedStatusAction(status);
  }
}
