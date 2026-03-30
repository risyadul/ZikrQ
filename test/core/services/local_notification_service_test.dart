import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikrq/core/services/local_notification_service.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('LocalNotificationService', () {
    test(
      'scheduleDailyReminder schedules next local-time reminders with zonedSchedule',
      () async {
        final gateway = _FakeNotificationGateway();
        final service = LocalNotificationService(
          gateway: gateway,
          getLocalTimezone: () async => 'Asia/Jakarta',
          initializeTimeZones: () {},
          setLocalLocation: tz.setLocalLocation,
          now: () =>
              tz.TZDateTime(tz.getLocation('Asia/Jakarta'), 2026, 3, 30, 22, 0),
        );

        await service.initialize();
        await service.scheduleDailyReminder(
          hour: 21,
          minute: 30,
          activeWeekdays: const {1, 3},
        );

        expect(gateway.scheduled.length, 2);

        final monday = gateway.scheduled.firstWhere((e) => e.id == 1);
        final wednesday = gateway.scheduled.firstWhere((e) => e.id == 3);

        expect(monday.at.weekday, DateTime.monday);
        expect(monday.at.year, 2026);
        expect(monday.at.month, 4);
        expect(monday.at.day, 6);
        expect(monday.at.hour, 21);
        expect(monday.at.minute, 30);

        expect(wednesday.at.weekday, DateTime.wednesday);
        expect(wednesday.at.year, 2026);
        expect(wednesday.at.month, 4);
        expect(wednesday.at.day, 1);
        expect(wednesday.at.hour, 21);
        expect(wednesday.at.minute, 30);
      },
    );

    test(
      'requestPermission returns false when denied and supports opening settings',
      () async {
        final gateway = _FakeNotificationGateway(permissionGranted: false);
        final service = LocalNotificationService(
          gateway: gateway,
          getLocalTimezone: () async => 'UTC',
          initializeTimeZones: () {},
          setLocalLocation: tz.setLocalLocation,
        );

        await service.initialize();
        final granted = await service.requestPermission();
        await service.openSystemNotificationSettings();

        expect(granted, isFalse);
        expect(gateway.openSettingsCalls, 1);
      },
    );

    test(
      'openSystemSettings opens system settings without requesting permission again',
      () async {
        var openSettingsCalls = 0;
        final gateway = _SpyFlutterLocalNotificationGateway(
          onOpenSettings: () async {
            openSettingsCalls += 1;
          },
        );

        await gateway.openSystemSettings();

        expect(openSettingsCalls, 1);
        expect(gateway.requestPermissionCalls, 0);
      },
    );
  });
}

class _SpyFlutterLocalNotificationGateway
    extends FlutterLocalNotificationGateway {
  _SpyFlutterLocalNotificationGateway({required this.onOpenSettings})
    : super(openSystemSettings: onOpenSettings);

  final Future<void> Function() onOpenSettings;
  int requestPermissionCalls = 0;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalls += 1;
    return false;
  }
}

class _FakeNotificationGateway implements NotificationGateway {
  _FakeNotificationGateway({this.permissionGranted = true});

  final bool permissionGranted;
  final List<_ScheduledCall> scheduled = [];
  int openSettingsCalls = 0;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> openSystemSettings() async {
    openSettingsCalls += 1;
  }

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    scheduled.add(_ScheduledCall(id: id, at: scheduledDate));
  }
}

class _ScheduledCall {
  const _ScheduledCall({required this.id, required this.at});

  final int id;
  final tz.TZDateTime at;
}
