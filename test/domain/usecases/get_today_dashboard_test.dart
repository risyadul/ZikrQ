import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';
import 'package:zikrq/domain/usecases/get_today_dashboard.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class MockReviewQueueRepository extends Mock implements ReviewQueueRepository {}

void main() {
  late MockHabitRepository habitRepository;
  late MockReviewQueueRepository reviewQueueRepository;
  late GetTodayDashboardUseCase useCase;

  HabitPlan plan() => HabitPlan(
    dailyTargetAyat: 5,
    activeDays: const [1, 2, 3, 4, 5, 6, 7],
    reminderEnabled: false,
    reminderHour: 5,
    reminderMinute: 0,
    snoozeMinutes: 10,
    updatedAt: DateTime(2026, 4, 3),
    localChangeVersion: 1,
  );

  setUp(() {
    habitRepository = MockHabitRepository();
    reviewQueueRepository = MockReviewQueueRepository();
    useCase = GetTodayDashboardUseCase(habitRepository, reviewQueueRepository);
  });

  test(
    'carries over previous streak when current active day is not complete yet',
    () async {
      final today = DateTime(2026, 4, 3);

      when(() => habitRepository.getPlan()).thenAnswer((_) async => plan());
      when(
        () => habitRepository.getProgressByDate(today),
      ).thenAnswer((_) async => null);
      when(
        () => habitRepository.getProgressByDate(DateTime(2026, 4, 2)),
      ).thenAnswer(
        (_) async => DailyProgress(
          date: DateTime(2026, 4, 2),
          completedAyat: 5,
          targetAyat: 5,
          goalMet: true,
          updatedAt: DateTime(2026, 4, 2),
          localChangeVersion: 1,
        ),
      );
      when(
        () => habitRepository.getProgressByDate(DateTime(2026, 4, 1)),
      ).thenAnswer(
        (_) async => DailyProgress(
          date: DateTime(2026, 4, 1),
          completedAyat: 5,
          targetAyat: 5,
          goalMet: true,
          updatedAt: DateTime(2026, 4, 1),
          localChangeVersion: 1,
        ),
      );
      when(
        () => habitRepository.getProgressByDate(DateTime(2026, 3, 31)),
      ).thenAnswer(
        (_) async => DailyProgress(
          date: DateTime(2026, 3, 31),
          completedAyat: 0,
          targetAyat: 5,
          goalMet: false,
          updatedAt: DateTime(2026, 3, 31),
          localChangeVersion: 1,
        ),
      );
      when(
        () => reviewQueueRepository.generateTodayQueue(today),
      ).thenAnswer((_) async => const <ReviewTask>[]);

      final dashboard = await useCase(date: today);

      expect(dashboard.streakDays, 2);
    },
  );

  test(
    'includes today in streak when current active day is complete',
    () async {
      final today = DateTime(2026, 4, 3);

      when(() => habitRepository.getPlan()).thenAnswer((_) async => plan());
      when(() => habitRepository.getProgressByDate(today)).thenAnswer(
        (_) async => DailyProgress(
          date: today,
          completedAyat: 5,
          targetAyat: 5,
          goalMet: true,
          updatedAt: today,
          localChangeVersion: 1,
        ),
      );
      when(
        () => habitRepository.getProgressByDate(DateTime(2026, 4, 2)),
      ).thenAnswer(
        (_) async => DailyProgress(
          date: DateTime(2026, 4, 2),
          completedAyat: 5,
          targetAyat: 5,
          goalMet: true,
          updatedAt: DateTime(2026, 4, 2),
          localChangeVersion: 1,
        ),
      );
      when(
        () => habitRepository.getProgressByDate(DateTime(2026, 4, 1)),
      ).thenAnswer((_) async => null);
      when(
        () => reviewQueueRepository.generateTodayQueue(today),
      ).thenAnswer((_) async => const <ReviewTask>[]);

      final dashboard = await useCase(date: today);

      expect(dashboard.streakDays, 2);
    },
  );
}
