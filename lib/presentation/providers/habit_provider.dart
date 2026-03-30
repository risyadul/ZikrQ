import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/today_dashboard.dart';
import 'package:zikrq/domain/entities/user_preference.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

const Set<int> kAllowedSnoozeMinutes = {5, 10, 15};
const int kDefaultSnoozeMinutes = 10;

int normalizeSnoozeMinutes(int value) {
  if (kAllowedSnoozeMinutes.contains(value)) {
    return value;
  }
  return kDefaultSnoozeMinutes;
}

final settingsPlanProvider = FutureProvider<HabitPlan>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getPlan();
});

final settingsPreferenceProvider = FutureProvider<UserPreference>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getPreference();
});

class SettingsFormState {
  const SettingsFormState({
    required this.dailyTargetAyat,
    required this.activeDays,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.snoozeMinutes,
    required this.defaultQuickAction,
    required this.hapticEnabled,
  });

  final int dailyTargetAyat;
  final Set<int> activeDays;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int snoozeMinutes;
  final MemorizationStatus defaultQuickAction;
  final bool hapticEnabled;

  SettingsFormState copyWith({
    int? dailyTargetAyat,
    Set<int>? activeDays,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? snoozeMinutes,
    MemorizationStatus? defaultQuickAction,
    bool? hapticEnabled,
  }) {
    return SettingsFormState(
      dailyTargetAyat: dailyTargetAyat ?? this.dailyTargetAyat,
      activeDays: activeDays ?? this.activeDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      defaultQuickAction: defaultQuickAction ?? this.defaultQuickAction,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

final settingsFormStateProvider = FutureProvider<SettingsFormState>((
  ref,
) async {
  final repository = ref.watch(habitRepositoryProvider);
  final plan = await repository.getPlan();
  final preference = await repository.getPreference();

  return SettingsFormState(
    dailyTargetAyat: plan.dailyTargetAyat,
    activeDays: plan.activeDays.toSet(),
    reminderEnabled: plan.reminderEnabled,
    reminderHour: plan.reminderHour,
    reminderMinute: plan.reminderMinute,
    snoozeMinutes: normalizeSnoozeMinutes(preference.snoozeMinutes),
    defaultQuickAction: preference.defaultQuickAction,
    hapticEnabled: preference.hapticEnabled,
  );
});

enum ReminderPermissionRequestResult { granted, deniedCanOpenSettings }

final reminderPermissionControllerProvider =
    NotifierProvider<
      ReminderPermissionController,
      ReminderPermissionRequestResult?
    >(ReminderPermissionController.new);

class ReminderPermissionController
    extends Notifier<ReminderPermissionRequestResult?> {
  @override
  ReminderPermissionRequestResult? build() => null;

  Future<ReminderPermissionRequestResult> request() async {
    final granted = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    final result = granted
        ? ReminderPermissionRequestResult.granted
        : ReminderPermissionRequestResult.deniedCanOpenSettings;
    state = result;
    return result;
  }
}

final settingsSaveControllerProvider =
    AsyncNotifierProvider<SettingsSaveController, void>(
      SettingsSaveController.new,
    );

class SettingsSaveController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ReminderPermissionRequestResult?> save(SettingsFormState state) async {
    this.state = const AsyncLoading<void>();

    ReminderPermissionRequestResult? permissionResult;

    this.state = await AsyncValue.guard(() async {
      final repository = ref.read(habitRepositoryProvider);
      final reminderScheduler = ref.read(reminderSchedulerProvider);
      final now = DateTime.now();
      final normalizedSnoozeMinutes = normalizeSnoozeMinutes(
        state.snoozeMinutes,
      );

      if (state.dailyTargetAyat < 1) {
        throw ArgumentError.value(
          state.dailyTargetAyat,
          'dailyTargetAyat',
          'dailyTargetAyat must be >= 1',
        );
      }
      if (state.activeDays.isEmpty) {
        throw ArgumentError.value(
          state.activeDays,
          'activeDays',
          'activeDays must not be empty',
        );
      }

      final currentPlan = await repository.getPlan();
      final currentPreference = await repository.getPreference();

      final updatedPlan = currentPlan.copyWith(
        dailyTargetAyat: state.dailyTargetAyat,
        activeDays: state.activeDays.toList()..sort(),
        reminderEnabled: state.reminderEnabled,
        reminderHour: state.reminderHour,
        reminderMinute: state.reminderMinute,
        snoozeMinutes: normalizedSnoozeMinutes,
        updatedAt: now,
        localChangeVersion: currentPlan.localChangeVersion + 1,
      );

      if (updatedPlan.reminderEnabled) {
        permissionResult = await ref
            .read(reminderPermissionControllerProvider.notifier)
            .request();
        if (permissionResult == ReminderPermissionRequestResult.granted) {
          await reminderScheduler.scheduleDailyReminder(
            hour: updatedPlan.reminderHour,
            minute: updatedPlan.reminderMinute,
            activeWeekdays: updatedPlan.activeDays.toSet(),
          );
        }
      } else {
        await reminderScheduler.cancelAllReminders();
      }

      await repository.savePlan(updatedPlan);

      await repository.savePreference(
        currentPreference.copyWith(
          snoozeMinutes: normalizedSnoozeMinutes,
          defaultQuickAction: state.defaultQuickAction,
          hapticEnabled: state.hapticEnabled,
          updatedAt: now,
          localChangeVersion: currentPreference.localChangeVersion + 1,
        ),
      );
    });

    if (this.state.hasError) {
      final error = this.state.error!;
      if (error is Exception) {
        throw error;
      }
      throw Exception('Failed to save settings: $error');
    }

    ref
      ..invalidate(settingsPlanProvider)
      ..invalidate(settingsPreferenceProvider)
      ..invalidate(settingsFormStateProvider)
      ..invalidate(todayDashboardProvider);

    return permissionResult;
  }
}

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  final useCase = ref.watch(getTodayDashboardUseCaseProvider);
  return useCase();
});
