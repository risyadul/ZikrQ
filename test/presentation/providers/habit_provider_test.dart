import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/entities/today_dashboard.dart';
import 'package:zikrq/domain/entities/user_preference.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/reminder_scheduler.dart';
import 'package:zikrq/domain/usecases/get_today_dashboard.dart';
import 'package:zikrq/domain/usecases/reschedule_reminder.dart';
import 'package:zikrq/domain/usecases/update_daily_target.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/habit_provider.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class MockReminderScheduler extends Mock implements ReminderScheduler {}

class MockGetTodayDashboardUseCase extends Mock
    implements GetTodayDashboardUseCase {}

HabitPlan _plan({int target = 7}) => HabitPlan(
  dailyTargetAyat: target,
  activeDays: const [1, 2, 3, 4, 5, 6, 7],
  reminderEnabled: false,
  reminderHour: 5,
  reminderMinute: 30,
  snoozeMinutes: 10,
  updatedAt: DateTime(2026, 3, 30),
  localChangeVersion: 1,
);

UserPreference _preference({
  int snoozeMinutes = 10,
  bool notificationsPermissionRequested = true,
  bool notificationsPermissionGranted = true,
}) => UserPreference(
  onboardingCompleted: true,
  notificationsPermissionRequested: notificationsPermissionRequested,
  notificationsPermissionGranted: notificationsPermissionGranted,
  soundEnabled: true,
  vibrationEnabled: true,
  snoozeMinutes: snoozeMinutes,
  defaultQuickAction: MemorizationStatus.inProgress,
  hapticEnabled: true,
  updatedAt: DateTime(2026, 3, 30),
  localChangeVersion: 1,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_plan());
    registerFallbackValue(_preference());
  });

  test('todayDashboardProvider exposes target and queue size', () async {
    final useCase = MockGetTodayDashboardUseCase();
    final date = DateTime(2026, 3, 30);
    final dashboard = TodayDashboard(
      date: date,
      plan: _plan(target: 9),
      progress: DailyProgress(
        date: date,
        completedAyat: 3,
        targetAyat: 9,
        goalMet: false,
        updatedAt: date,
        localChangeVersion: 1,
      ),
      reviewQueue: [
        ReviewTask(
          id: 'a',
          surahId: 1,
          source: ReviewTaskSource.manual,
          scheduledDate: date,
          priorityScore: 20,
          updatedAt: date,
          localChangeVersion: 1,
        ),
        ReviewTask(
          id: 'b',
          surahId: 2,
          source: ReviewTaskSource.manual,
          scheduledDate: date,
          priorityScore: 30,
          updatedAt: date,
          localChangeVersion: 1,
        ),
      ],
    );

    when(
      () => useCase.call(date: any(named: 'date')),
    ).thenAnswer((_) async => dashboard);

    final container = ProviderContainer(
      overrides: [getTodayDashboardUseCaseProvider.overrideWithValue(useCase)],
    );
    addTearDown(container.dispose);

    final result = await container.read(todayDashboardProvider.future);
    expect(result.targetAyat, 9);
    expect(result.reviewQueue.length, 2);
  });

  test('update target validation rejects <= 0', () async {
    final repository = MockHabitRepository();
    final useCase = UpdateDailyTargetUseCase(repository);
    await expectLater(useCase(0), throwsArgumentError);
  });

  test('reschedule reminder validation rejects invalid hour/minute', () async {
    final repository = MockHabitRepository();
    final scheduler = MockReminderScheduler();
    when(() => repository.getPlan()).thenAnswer((_) async => _plan());

    final useCase = RescheduleReminderUseCase(
      habitRepository: repository,
      reminderScheduler: scheduler,
    );

    await expectLater(useCase(hour: 24, minute: 0), throwsArgumentError);

    await expectLater(useCase(hour: 10, minute: 99), throwsArgumentError);
  });

  test('settings save cancels reminders when reminder is disabled', () async {
    final repository = MockHabitRepository();
    final scheduler = MockReminderScheduler();

    when(() => repository.getPlan()).thenAnswer((_) async => _plan());
    when(
      () => repository.getPreference(),
    ).thenAnswer((_) async => _preference());
    when(() => repository.savePlan(any())).thenAnswer((_) async {});
    when(() => repository.savePreference(any())).thenAnswer((_) async {});
    when(() => scheduler.cancelAllReminders()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(settingsSaveControllerProvider.notifier);
    await notifier.save(
      const SettingsFormState(
        dailyTargetAyat: 8,
        activeDays: {1, 2, 3, 4, 5, 6, 7},
        reminderEnabled: false,
        reminderHour: 6,
        reminderMinute: 15,
        snoozeMinutes: 10,
        defaultQuickAction: MemorizationStatus.memorized,
        hapticEnabled: false,
      ),
    );

    verifyInOrder([
      () => repository.savePlan(any()),
      () => repository.savePreference(any()),
      () => scheduler.cancelAllReminders(),
    ]);
    verifyNever(
      () => scheduler.scheduleDailyReminder(
        hour: any(named: 'hour'),
        minute: any(named: 'minute'),
        activeWeekdays: any(named: 'activeWeekdays'),
      ),
    );
  });

  test('settings form state normalizes invalid stored snooze value', () async {
    final repository = MockHabitRepository();
    when(() => repository.getPlan()).thenAnswer((_) async => _plan());
    when(
      () => repository.getPreference(),
    ).thenAnswer((_) async => _preference(snoozeMinutes: 0));

    final container = ProviderContainer(
      overrides: [habitRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final formState = await container.read(settingsFormStateProvider.future);
    expect(formState.snoozeMinutes, 10);
  });

  test(
    'settings save with reminder enabled and denied permission skips scheduling',
    () async {
      final repository = MockHabitRepository();
      final scheduler = MockReminderScheduler();

      when(() => repository.getPlan()).thenAnswer((_) async => _plan());
      when(() => repository.getPreference()).thenAnswer(
        (_) async => _preference(notificationsPermissionRequested: false),
      );
      when(() => repository.savePlan(any())).thenAnswer((_) async {});
      UserPreference? savedPreference;
      when(() => repository.savePreference(any())).thenAnswer((
        invocation,
      ) async {
        savedPreference =
            invocation.positionalArguments.first as UserPreference;
      });
      when(() => scheduler.requestPermission()).thenAnswer((_) async => false);
      when(() => scheduler.cancelAllReminders()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsSaveControllerProvider.notifier);
      final result = await notifier.save(
        const SettingsFormState(
          dailyTargetAyat: 8,
          activeDays: {1, 2, 3, 4, 5, 6, 7},
          reminderEnabled: true,
          reminderHour: 6,
          reminderMinute: 15,
          snoozeMinutes: 10,
          defaultQuickAction: MemorizationStatus.memorized,
          hapticEnabled: false,
        ),
      );

      expect(result, ReminderPermissionRequestResult.deniedCanOpenSettings);
      expect(savedPreference, isNotNull);
      expect(savedPreference!.notificationsPermissionRequested, isTrue);
      expect(savedPreference!.notificationsPermissionGranted, isFalse);
      verifyInOrder([
        () => scheduler.requestPermission(),
        () => repository.savePlan(any()),
        () => repository.savePreference(any()),
        () => scheduler.cancelAllReminders(),
      ]);
      verifyNever(
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      );
    },
  );

  test(
    'settings save with reminder enabled and granted permission schedules reminder',
    () async {
      final repository = MockHabitRepository();
      final scheduler = MockReminderScheduler();

      when(() => repository.getPlan()).thenAnswer((_) async => _plan());
      when(() => repository.getPreference()).thenAnswer(
        (_) async => _preference(notificationsPermissionRequested: false),
      );
      when(() => repository.savePlan(any())).thenAnswer((_) async {});
      UserPreference? savedPreference;
      when(() => repository.savePreference(any())).thenAnswer((
        invocation,
      ) async {
        savedPreference =
            invocation.positionalArguments.first as UserPreference;
      });
      when(() => scheduler.requestPermission()).thenAnswer((_) async => true);
      when(
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsSaveControllerProvider.notifier);
      final result = await notifier.save(
        const SettingsFormState(
          dailyTargetAyat: 8,
          activeDays: {1, 2, 3, 4, 5, 6, 7},
          reminderEnabled: true,
          reminderHour: 6,
          reminderMinute: 15,
          snoozeMinutes: 10,
          defaultQuickAction: MemorizationStatus.memorized,
          hapticEnabled: false,
        ),
      );

      expect(result, ReminderPermissionRequestResult.granted);
      expect(savedPreference, isNotNull);
      expect(savedPreference!.notificationsPermissionRequested, isTrue);
      expect(savedPreference!.notificationsPermissionGranted, isTrue);
      verifyInOrder([
        () => scheduler.requestPermission(),
        () => repository.savePlan(any()),
        () => repository.savePreference(any()),
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      ]);
    },
  );

  test(
    'settings save does not request permission when already requested',
    () async {
      final repository = MockHabitRepository();
      final scheduler = MockReminderScheduler();

      when(() => repository.getPlan()).thenAnswer((_) async => _plan());
      when(() => repository.getPreference()).thenAnswer(
        (_) async => _preference(
          notificationsPermissionRequested: true,
          notificationsPermissionGranted: true,
        ),
      );
      when(() => repository.savePlan(any())).thenAnswer((_) async {});
      when(() => repository.savePreference(any())).thenAnswer((_) async {});
      when(
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsSaveControllerProvider.notifier);
      final result = await notifier.save(
        const SettingsFormState(
          dailyTargetAyat: 8,
          activeDays: {1, 2, 3, 4, 5, 6, 7},
          reminderEnabled: true,
          reminderHour: 6,
          reminderMinute: 15,
          snoozeMinutes: 10,
          defaultQuickAction: MemorizationStatus.memorized,
          hapticEnabled: false,
        ),
      );

      expect(result, isNull);
      verifyNever(() => scheduler.requestPermission());
      verify(
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      ).called(1);
    },
  );

  test(
    'settings save skips scheduling when permission was already denied',
    () async {
      final repository = MockHabitRepository();
      final scheduler = MockReminderScheduler();

      when(() => repository.getPlan()).thenAnswer((_) async => _plan());
      when(() => repository.getPreference()).thenAnswer(
        (_) async => _preference(
          notificationsPermissionRequested: true,
          notificationsPermissionGranted: false,
        ),
      );
      when(() => repository.savePlan(any())).thenAnswer((_) async {});
      UserPreference? savedPreference;
      when(() => repository.savePreference(any())).thenAnswer((
        invocation,
      ) async {
        savedPreference =
            invocation.positionalArguments.first as UserPreference;
      });
      when(() => scheduler.cancelAllReminders()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsSaveControllerProvider.notifier);
      final result = await notifier.save(
        const SettingsFormState(
          dailyTargetAyat: 8,
          activeDays: {1, 2, 3, 4, 5, 6, 7},
          reminderEnabled: true,
          reminderHour: 6,
          reminderMinute: 15,
          snoozeMinutes: 10,
          defaultQuickAction: MemorizationStatus.memorized,
          hapticEnabled: false,
        ),
      );

      expect(result, isNull);
      expect(savedPreference, isNotNull);
      expect(savedPreference!.notificationsPermissionRequested, isTrue);
      expect(savedPreference!.notificationsPermissionGranted, isFalse);
      verifyNever(() => scheduler.requestPermission());
      verifyNever(
        () => scheduler.scheduleDailyReminder(
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          activeWeekdays: any(named: 'activeWeekdays'),
        ),
      );
      verify(() => scheduler.cancelAllReminders()).called(1);
    },
  );
}
