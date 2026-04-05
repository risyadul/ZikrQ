import 'package:isar/isar.dart';

part 'habit_plan_model.g.dart';

@Collection()
class HabitPlanModel {
  Id id = Isar.autoIncrement;

  late int dailyTargetAyat;
  late List<int> activeDays;
  late bool reminderEnabled;
  late int reminderHour;
  late int reminderMinute;
  late int snoozeMinutes;
  late DateTime updatedAt;
  late int localChangeVersion;
}
