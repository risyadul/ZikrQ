import 'package:isar/isar.dart';

part 'review_task_model.g.dart';

@Collection()
class ReviewTaskModel {
  Id id = Isar.autoIncrement;

  late String taskId;
  late int surahId;
  late int priorityScore;
  late DateTime scheduledDate;
  late int source;
  late DateTime updatedAt;
  late int localChangeVersion;
}
