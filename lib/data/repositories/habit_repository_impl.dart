import 'package:meta/meta.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/models/daily_progress_model.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/models/user_preference_model.dart';
import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/user_preference.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';

@immutable
class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(this._datasource);

  final HabitLocalDatasource _datasource;

  @override
  Future<HabitPlan> getPlan() async {
    final model = await _datasource.getPlan();
    if (model == null) {
      return _defaultPlan();
    }
    return _toPlanEntity(model);
  }

  @override
  Future<void> savePlan(HabitPlan plan) =>
      _datasource.savePlan(_toPlanModel(plan));

  @override
  Future<DailyProgress?> getProgressByDate(DateTime date) async {
    final model = await _datasource.getProgressByDate(date);
    if (model == null) {
      return null;
    }
    return _toProgressEntity(model);
  }

  @override
  Future<void> saveProgress(DailyProgress progress) =>
      _datasource.saveProgress(_toProgressModel(progress));

  @override
  Future<UserPreference> getPreference() async {
    final model = await _datasource.getPreference();
    if (model == null) {
      return _defaultPreference();
    }
    return _toPreferenceEntity(model);
  }

  @override
  Future<void> savePreference(UserPreference preference) =>
      _datasource.savePreference(_toPreferenceModel(preference));

  HabitPlanModel _toPlanModel(HabitPlan plan) => HabitPlanModel()
    ..dailyTargetAyat = plan.dailyTargetAyat
    ..activeDays = List<int>.from(plan.activeDays)
    ..reminderEnabled = plan.reminderEnabled
    ..reminderHour = plan.reminderHour
    ..reminderMinute = plan.reminderMinute
    ..snoozeMinutes = plan.snoozeMinutes
    ..updatedAt = plan.updatedAt
    ..localChangeVersion = plan.localChangeVersion;

  HabitPlan _toPlanEntity(HabitPlanModel model) => HabitPlan(
    dailyTargetAyat: model.dailyTargetAyat,
    activeDays: List<int>.from(model.activeDays),
    reminderEnabled: model.reminderEnabled,
    reminderHour: model.reminderHour,
    reminderMinute: model.reminderMinute,
    snoozeMinutes: model.snoozeMinutes,
    updatedAt: model.updatedAt,
    localChangeVersion: model.localChangeVersion,
  );

  DailyProgressModel _toProgressModel(DailyProgress progress) =>
      DailyProgressModel()
        ..date = _localDate(progress.date)
        ..completedAyat = progress.completedAyat
        ..targetAyat = progress.targetAyat
        ..goalMet = progress.goalMet
        ..updatedAt = progress.updatedAt
        ..localChangeVersion = progress.localChangeVersion;

  DailyProgress _toProgressEntity(DailyProgressModel model) => DailyProgress(
    date: model.date,
    completedAyat: model.completedAyat,
    targetAyat: model.targetAyat,
    goalMet: model.goalMet,
    updatedAt: model.updatedAt,
    localChangeVersion: model.localChangeVersion,
  );

  UserPreferenceModel _toPreferenceModel(UserPreference preference) =>
      UserPreferenceModel()
        ..onboardingCompleted = preference.onboardingCompleted
        ..notificationsPermissionRequested =
            preference.notificationsPermissionRequested
        ..notificationsPermissionGranted =
            preference.notificationsPermissionGranted
        ..soundEnabled = preference.soundEnabled
        ..vibrationEnabled = preference.vibrationEnabled
        ..snoozeMinutes = preference.snoozeMinutes
        ..defaultQuickAction = preference.defaultQuickAction.index
        ..hapticEnabled = preference.hapticEnabled
        ..updatedAt = preference.updatedAt
        ..localChangeVersion = preference.localChangeVersion;

  UserPreference _toPreferenceEntity(UserPreferenceModel model) =>
      UserPreference(
        onboardingCompleted: model.onboardingCompleted,
        notificationsPermissionRequested:
            model.notificationsPermissionRequested,
        notificationsPermissionGranted: model.notificationsPermissionGranted,
        soundEnabled: model.soundEnabled,
        vibrationEnabled: model.vibrationEnabled,
        snoozeMinutes: model.snoozeMinutes,
        defaultQuickAction: _toMemorizationStatus(
          model.defaultQuickAction,
          isLegacy: _isLegacyPreference(model),
        ),
        hapticEnabled: _toHapticEnabled(
          model.hapticEnabled,
          isLegacy: _isLegacyPreference(model),
        ),
        updatedAt: model.updatedAt,
        localChangeVersion: model.localChangeVersion,
      );

  HabitPlan _defaultPlan() => HabitPlan(
    dailyTargetAyat: 5,
    activeDays: const [1, 2, 3, 4, 5, 6, 7],
    reminderEnabled: false,
    reminderHour: 5,
    reminderMinute: 0,
    snoozeMinutes: 10,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    localChangeVersion: 0,
  );

  UserPreference _defaultPreference() => UserPreference(
    onboardingCompleted: false,
    notificationsPermissionRequested: false,
    notificationsPermissionGranted: false,
    soundEnabled: true,
    vibrationEnabled: true,
    snoozeMinutes: 10,
    defaultQuickAction: MemorizationStatus.inProgress,
    hapticEnabled: true,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    localChangeVersion: 0,
  );

  static bool _isLegacyPreference(UserPreferenceModel model) {
    return model.localChangeVersion <= 0;
  }

  static MemorizationStatus _toMemorizationStatus(
    int index, {
    required bool isLegacy,
  }) {
    if (index < 0 || index >= MemorizationStatus.values.length) {
      return MemorizationStatus.inProgress;
    }
    if (isLegacy && index == MemorizationStatus.notStarted.index) {
      return MemorizationStatus.inProgress;
    }
    return MemorizationStatus.values[index];
  }

  static bool _toHapticEnabled(bool value, {required bool isLegacy}) {
    if (isLegacy && value == false) {
      return true;
    }
    return value;
  }

  static DateTime _localDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
