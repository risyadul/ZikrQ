import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/reminder_scheduler.dart';

class ScheduleReminderUseCase {
  const ScheduleReminderUseCase({
    required HabitRepository habitRepository,
    required ReminderScheduler reminderScheduler,
  }) : _habitRepository = habitRepository,
       _reminderScheduler = reminderScheduler;

  final HabitRepository _habitRepository;
  final ReminderScheduler _reminderScheduler;

  Future<void> call(HabitPlan plan) async {
    _validatePlan(plan);

    if (!plan.reminderEnabled) {
      await _reminderScheduler.cancelAllReminders();
      await _habitRepository.savePlan(plan);
      return;
    }

    final granted = await _reminderScheduler.requestPermission();
    if (!granted) {
      throw StateError('Notification permission denied');
    }

    await _reminderScheduler.scheduleDailyReminder(
      hour: plan.reminderHour,
      minute: plan.reminderMinute,
      activeWeekdays: plan.activeDays.toSet(),
    );
    await _habitRepository.savePlan(plan);
  }

  void _validatePlan(HabitPlan plan) {
    if (plan.dailyTargetAyat < 1) {
      throw ArgumentError.value(plan.dailyTargetAyat, 'dailyTargetAyat');
    }
    if (!_isValidSnooze(plan.snoozeMinutes)) {
      throw ArgumentError.value(plan.snoozeMinutes, 'snoozeMinutes');
    }
    if (!_isValidHour(plan.reminderHour)) {
      throw ArgumentError.value(plan.reminderHour, 'hour');
    }
    if (!_isValidMinute(plan.reminderMinute)) {
      throw ArgumentError.value(plan.reminderMinute, 'minute');
    }
    if (plan.reminderEnabled && plan.activeDays.isEmpty) {
      throw ArgumentError.value(plan.activeDays, 'activeDays');
    }
  }

  bool _isValidSnooze(int value) => value == 5 || value == 10 || value == 15;
  bool _isValidHour(int value) => value >= 0 && value <= 23;
  bool _isValidMinute(int value) => value >= 0 && value <= 59;
}
