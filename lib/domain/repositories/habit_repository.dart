import 'package:zikrq/domain/entities/daily_progress.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/user_preference.dart';

abstract interface class HabitRepository {
  Future<HabitPlan> getPlan();
  Future<void> savePlan(HabitPlan plan);
  Future<DailyProgress?> getProgressByDate(DateTime date);
  Future<void> saveProgress(DailyProgress progress);
  Future<UserPreference> getPreference();
  Future<void> savePreference(UserPreference preference);
}
