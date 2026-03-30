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

    return TodayDashboard(
      date: localDate,
      plan: plan,
      progress: progress,
      reviewQueue: queue,
    );
  }

  DateTime _localDate(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
