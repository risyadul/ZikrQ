abstract interface class ReminderScheduler {
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder(
    int hour,
    int minute,
    List<int> activeWeekdays,
  );
  Future<void> cancelAllReminders();
  Future<void> openSystemNotificationSettings();
}
