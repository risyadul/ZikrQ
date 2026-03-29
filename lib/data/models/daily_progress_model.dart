import 'package:isar/isar.dart';

part 'daily_progress_model.g.dart';

@Collection()
class DailyProgressModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date;

  late int completedAyat;
  late int targetAyat;
  late bool goalMet;
  late DateTime updatedAt;
  late int localChangeVersion;
}
