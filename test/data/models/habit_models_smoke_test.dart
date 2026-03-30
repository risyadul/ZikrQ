import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/data/models/daily_progress_model.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/models/review_task_model.dart';
import 'package:zikrq/data/models/user_preference_model.dart';

void main() {
  test('new habit engine models can be instantiated', () {
    final habitPlan = HabitPlanModel()
      ..dailyTargetAyat = 5
      ..activeDays = [1, 2, 3]
      ..reminderEnabled = true
      ..reminderHour = 6
      ..reminderMinute = 30
      ..snoozeMinutes = 10
      ..updatedAt = DateTime(2026)
      ..localChangeVersion = 1;

    final dailyProgress = DailyProgressModel()
      ..date = DateTime(2026, 3, 30)
      ..completedAyat = 4
      ..targetAyat = 5
      ..goalMet = false
      ..updatedAt = DateTime(2026, 3, 30, 12)
      ..localChangeVersion = 2;

    final reviewTask = ReviewTaskModel()
      ..taskId = 'rt-1'
      ..surahId = 2
      ..priorityScore = 75
      ..scheduledDate = DateTime(2026, 3, 31)
      ..source = 1
      ..updatedAt = DateTime(2026, 3, 30, 12)
      ..localChangeVersion = 3;

    final preference = UserPreferenceModel()
      ..onboardingCompleted = true
      ..notificationsPermissionRequested = true
      ..notificationsPermissionGranted = true
      ..soundEnabled = true
      ..vibrationEnabled = false
      ..snoozeMinutes = 10
      ..defaultQuickAction = 1
      ..hapticEnabled = true
      ..updatedAt = DateTime(2026, 3, 30, 12)
      ..localChangeVersion = 4;

    expect(habitPlan.dailyTargetAyat, 5);
    expect(dailyProgress.targetAyat, 5);
    expect(reviewTask.taskId, 'rt-1');
    expect(preference.onboardingCompleted, isTrue);
  });
}
