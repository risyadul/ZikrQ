import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/today_dashboard.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';

class GetTodayDashboardUseCase {
  const GetTodayDashboardUseCase(
    this._habitRepository,
    this._reviewQueueRepository,
  );

  final HabitRepository _habitRepository;
  final ReviewQueueRepository _reviewQueueRepository;

  Future<TodayDashboard> call({DateTime? date}) async {
    final localDate = _localDate(date ?? DateTime.now());
    final planFuture = _habitRepository.getPlan();
    final progressFuture = _habitRepository.getProgressByDate(localDate);
    final queueFuture = _reviewQueueRepository.generateTodayQueue(localDate);

    final (plan, progress, queue) = await (
      planFuture,
      progressFuture,
      queueFuture,
    ).wait;
    final streakDays = await _calculateStreakDays(
      date: localDate,
      plan: plan,
      todayProgress: progress,
    );

    return TodayDashboard(
      date: localDate,
      plan: plan,
      progress: progress,
      reviewQueue: queue,
      streakDays: streakDays,
    );
  }

  Future<int> _calculateStreakDays({
    required DateTime date,
    required HabitPlan plan,
    required DailyProgress? todayProgress,
  }) async {
    final activeWeekdays = plan.activeDays.toSet();
    if (activeWeekdays.isEmpty) {
      return 0;
    }

    var streakDays = 0;
    var cursor = date;
    var isFirstActiveDay = true;

    while (true) {
      if (!activeWeekdays.contains(cursor.weekday)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }

      final progress = _isSameLocalDate(cursor, date)
          ? todayProgress
          : await _habitRepository.getProgressByDate(cursor);

      if (progress?.goalMet ?? false) {
        streakDays += 1;
        cursor = cursor.subtract(const Duration(days: 1));
        isFirstActiveDay = false;
        continue;
      }

      if (isFirstActiveDay) {
        cursor = cursor.subtract(const Duration(days: 1));
        isFirstActiveDay = false;
        continue;
      }

      return streakDays;
    }
  }

  DateTime _localDate(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  bool _isSameLocalDate(DateTime left, DateTime right) {
    final localLeft = _localDate(left);
    final localRight = _localDate(right);
    return localLeft == localRight;
  }
}
