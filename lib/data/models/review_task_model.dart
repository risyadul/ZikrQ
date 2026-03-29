import 'package:isar/isar.dart';

part 'review_task_model.g.dart';

@Collection()
class ReviewTaskModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('verseNumber')], unique: true)
  late int surahId;

  late int verseNumber;
  late DateTime scheduledFor;
  late bool isCompleted;
  DateTime? completedAt;
  late DateTime updatedAt;
  late int localChangeVersion;
}
