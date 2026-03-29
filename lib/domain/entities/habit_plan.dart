import 'package:meta/meta.dart';

@immutable
class HabitPlan {
  HabitPlan({
    required this.dailyTargetAyat,
    required List<int> activeDays,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.snoozeMinutes,
    required this.updatedAt,
    required this.localChangeVersion,
  }) : activeDays = List<int>.unmodifiable(activeDays);

  final int dailyTargetAyat;

  /// Active weekdays using ISO weekday values: 1 (Monday) to 7 (Sunday).
  final List<int> activeDays;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int snoozeMinutes;
  final DateTime updatedAt;
  final int localChangeVersion;

  HabitPlan copyWith({
    int? dailyTargetAyat,
    List<int>? activeDays,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? snoozeMinutes,
    DateTime? updatedAt,
    int? localChangeVersion,
  }) => HabitPlan(
    dailyTargetAyat: dailyTargetAyat ?? this.dailyTargetAyat,
    activeDays: activeDays ?? this.activeDays,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    updatedAt: updatedAt ?? this.updatedAt,
    localChangeVersion: localChangeVersion ?? this.localChangeVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is HabitPlan &&
      other.dailyTargetAyat == dailyTargetAyat &&
      _listEquals(other.activeDays, activeDays) &&
      other.reminderEnabled == reminderEnabled &&
      other.reminderHour == reminderHour &&
      other.reminderMinute == reminderMinute &&
      other.snoozeMinutes == snoozeMinutes &&
      other.updatedAt == updatedAt &&
      other.localChangeVersion == localChangeVersion;

  @override
  int get hashCode => Object.hash(
    dailyTargetAyat,
    Object.hashAll(activeDays),
    reminderEnabled,
    reminderHour,
    reminderMinute,
    snoozeMinutes,
    updatedAt,
    localChangeVersion,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
