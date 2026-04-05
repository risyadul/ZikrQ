import 'package:meta/meta.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/models/user_preference_model.dart';
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

  @visibleForTesting
  static void resetLastUsedStatusActionCache() {
    _cachedLastUsedStatusAction = null;
  }

  @override
  Future<MemorizationStatus?> getLastUsedStatusAction() async {
    if (_cachedLastUsedStatusAction != null) {
      return _cachedLastUsedStatusAction;
    }

    final preference = await _habitDatasource.getPreference();
    final status = _memorizationStatusFromStoredValue(
      preference?.lastUsedStatusAction,
    );

    if (status != null) {
      _cachedLastUsedStatusAction = status;
    }

    return status;
  }

  @override
  Future<void> setLastUsedStatusAction(MemorizationStatus status) async {
    _cachedLastUsedStatusAction = status;

    final preference = await _habitDatasource.getPreference();
    final updatedPreference = (preference ?? _buildDefaultPreference())
      ..lastUsedStatusAction = status.index;

    await _habitDatasource.savePreference(updatedPreference);
  }

  @override
  Future<void> applyStatusToSurah({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    await _memorizationDatasource.updateStatus(surahId, status.index);
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
  }

  static MemorizationStatus? _memorizationStatusFromStoredValue(int? value) {
    if (value == null) {
      return null;
    }
    if (value < 0 || value >= MemorizationStatus.values.length) {
      return null;
    }
    return MemorizationStatus.values[value];
  }

  static UserPreferenceModel _buildDefaultPreference() => UserPreferenceModel()
    ..onboardingCompleted = false
    ..notificationsPermissionRequested = false
    ..notificationsPermissionGranted = false
    ..soundEnabled = true
    ..vibrationEnabled = true
    ..snoozeMinutes = 10
    ..defaultQuickAction = MemorizationStatus.inProgress.index
    ..lastUsedStatusAction = null
    ..hapticEnabled = true
    ..updatedAt = DateTime.fromMillisecondsSinceEpoch(0)
    ..localChangeVersion = 0;
}
