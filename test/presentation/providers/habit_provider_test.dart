import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/entities/today_dashboard.dart';
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

void main() {
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
    expectLater(useCase(0), throwsArgumentError);
  });

  test('reschedule reminder validation rejects invalid hour/minute', () async {
    final repository = MockHabitRepository();
    final scheduler = MockReminderScheduler();
    when(() => repository.getPlan()).thenAnswer((_) async => _plan());

    final useCase = RescheduleReminderUseCase(
      habitRepository: repository,
      reminderScheduler: scheduler,
    );

    expectLater(useCase(hour: 24, minute: 0), throwsArgumentError);

    expectLater(useCase(hour: 10, minute: 99), throwsArgumentError);
  });
}
