abstract interface class ReminderScheduler {
  Future<bool> requestPermission();

  /// Schedules reminders in local time for ISO weekdays 1 (Monday) to 7
  /// (Sunday).
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required Set<int> activeWeekdays,
  });
  Future<void> cancelAllReminders();
  Future<void> openSystemNotificationSettings();
}
