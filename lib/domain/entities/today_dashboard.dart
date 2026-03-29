import 'package:meta/meta.dart';
import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/review_task.dart';

@immutable
class TodayDashboard {
  TodayDashboard({
    required this.date,
    required this.plan,
    required List<ReviewTask> reviewQueue,
    this.progress,
  }) : reviewQueue = List<ReviewTask>.unmodifiable(reviewQueue);

  final DateTime date;
  final HabitPlan plan;
  final DailyProgress? progress;
  final List<ReviewTask> reviewQueue;

  int get completedAyat => progress?.completedAyat ?? 0;
  int get targetAyat => progress?.targetAyat ?? plan.dailyTargetAyat;
  bool get goalMet => progress?.goalMet ?? false;

  @override
  bool operator ==(Object other) =>
      other is TodayDashboard &&
      other.date == date &&
      other.plan == plan &&
      other.progress == progress &&
      _listEquals(other.reviewQueue, reviewQueue);

  @override
  int get hashCode =>
      Object.hash(date, plan, progress, Object.hashAll(reviewQueue));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
