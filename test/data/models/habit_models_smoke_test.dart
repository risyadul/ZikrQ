import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';

void main() {
  test('habit plan model can be instantiated', () {
    final model = HabitPlanModel()
      ..dailyTargetAyat = 5
      ..activeDays = [1, 2, 3]
      ..reminderEnabled = true
      ..reminderHour = 6
      ..reminderMinute = 30
      ..snoozeMinutes = 10
      ..updatedAt = DateTime(2026)
      ..localChangeVersion = 1;

    expect(model.dailyTargetAyat, 5);
  });
}
