import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikrq/domain/repositories/reminder_scheduler.dart';

class LocalNotificationService implements ReminderScheduler {
  LocalNotificationService({
    NotificationGateway? gateway,
    tz.TZDateTime Function()? now,
    Future<String> Function()? getLocalTimezone,
    void Function()? initializeTimeZones,
    void Function(tz.Location)? setLocalLocation,
  }) : _gateway = gateway ?? FlutterLocalNotificationGateway(),
       _now = now ?? (() => tz.TZDateTime.now(tz.local)),
       _getLocalTimezone = getLocalTimezone ?? FlutterTimezone.getLocalTimezone,
       _initializeTimeZones =
           initializeTimeZones ?? tz_data.initializeTimeZones,
       _setLocalLocation = setLocalLocation ?? tz.setLocalLocation;

  static const _reminderTitle = 'Waktunya murajaah';
  static const _reminderBody = 'Jaga konsistensi murajaah harianmu.';

  final NotificationGateway _gateway;
  final tz.TZDateTime Function() _now;
  final Future<String> Function() _getLocalTimezone;
  final void Function() _initializeTimeZones;
  final void Function(tz.Location) _setLocalLocation;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _initializeTimeZones();
    final timeZoneName = await _getLocalTimezone();
    final location = tz.getLocation(timeZoneName);
    _setLocalLocation(location);

    await _gateway.initialize();
    _isInitialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    return _gateway.requestPermission();
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required Set<int> activeWeekdays,
  }) async {
    await initialize();

    if (activeWeekdays.any((weekday) => weekday < 1 || weekday > 7)) {
      throw ArgumentError.value(activeWeekdays, 'activeWeekdays');
    }

    await _gateway.cancelAll();

    for (final weekday in activeWeekdays.toList()..sort()) {
      final next = _nextLocalTime(weekday: weekday, hour: hour, minute: minute);

      await _gateway.zonedSchedule(
        id: weekday,
        title: _reminderTitle,
        body: _reminderBody,
        scheduledDate: next,
      );
    }
  }

  @override
  Future<void> cancelAllReminders() => _gateway.cancelAll();

  @override
  Future<void> openSystemNotificationSettings() =>
      _gateway.openSystemSettings();

  tz.TZDateTime _nextLocalTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = _now();

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

abstract interface class NotificationGateway {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  });
  Future<void> cancelAll();
  Future<void> openSystemSettings();
}

class FlutterLocalNotificationGateway implements NotificationGateway {
  FlutterLocalNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    Future<void> Function()? openSystemSettings,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _openSystemSettings =
           openSystemSettings ??
           (() async {
             await AppSettings.openAppSettings(
               type: AppSettingsType.notification,
             );
           });

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<void> Function() _openSystemSettings;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Pengingat harian untuk murajaah.',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings);
  }

  @override
  Future<bool> requestPermission() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (androidGranted != null) {
      return androidGranted;
    }

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (iosGranted != null) {
      return iosGranted;
    }

    final macGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return macGranted ?? true;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> openSystemSettings() => _openSystemSettings();
}
