import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/reminder_scheduler.dart';

class RescheduleReminderUseCase {
  const RescheduleReminderUseCase({
    required HabitRepository habitRepository,
    required ReminderScheduler reminderScheduler,
  }) : _habitRepository = habitRepository,
       _reminderScheduler = reminderScheduler;

  final HabitRepository _habitRepository;
  final ReminderScheduler _reminderScheduler;

  Future<HabitPlan> call({required int hour, required int minute}) async {
    if (!_isValidHour(hour)) {
      throw ArgumentError.value(hour, 'hour', 'hour must be in 0..23');
    }
    if (!_isValidMinute(minute)) {
      throw ArgumentError.value(minute, 'minute', 'minute must be in 0..59');
    }

    final currentPlan = await _habitRepository.getPlan();
    final updatedPlan = currentPlan.copyWith(
      reminderHour: hour,
      reminderMinute: minute,
      updatedAt: DateTime.now(),
      localChangeVersion: currentPlan.localChangeVersion + 1,
    );

    _validatePlan(updatedPlan);

    if (updatedPlan.reminderEnabled) {
      await _reminderScheduler.scheduleDailyReminder(
        hour: updatedPlan.reminderHour,
        minute: updatedPlan.reminderMinute,
        activeWeekdays: updatedPlan.activeDays.toSet(),
      );
    }

    await _habitRepository.savePlan(updatedPlan);
    return updatedPlan;
  }

  void _validatePlan(HabitPlan plan) {
    if (plan.dailyTargetAyat < 1) {
      throw ArgumentError.value(plan.dailyTargetAyat, 'dailyTargetAyat');
    }
    if (!_isValidSnooze(plan.snoozeMinutes)) {
      throw ArgumentError.value(plan.snoozeMinutes, 'snoozeMinutes');
    }
    if (plan.reminderEnabled && plan.activeDays.isEmpty) {
      throw ArgumentError.value(plan.activeDays, 'activeDays');
    }
  }

  bool _isValidSnooze(int value) => value == 5 || value == 10 || value == 15;
  bool _isValidHour(int value) => value >= 0 && value <= 23;
  bool _isValidMinute(int value) => value >= 0 && value <= 59;
}
