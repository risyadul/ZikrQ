import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';

void main() {
  test('copyWith retains old values when null is passed', () {
    final plan = HabitPlan(
      dailyTargetAyat: 5,
      activeDays: const [1, 3, 5],
      reminderEnabled: true,
      reminderHour: 6,
      reminderMinute: 30,
      snoozeMinutes: 10,
      updatedAt: DateTime(2026, 3, 30, 8),
      localChangeVersion: 7,
    );

    final copied = plan.copyWith(
      dailyTargetAyat: null,
      activeDays: null,
      reminderEnabled: null,
      reminderHour: null,
      reminderMinute: null,
      snoozeMinutes: null,
      updatedAt: null,
      localChangeVersion: null,
    );

    expect(copied, equals(plan));
  });
}
