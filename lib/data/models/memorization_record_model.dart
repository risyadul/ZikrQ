// lib/data/models/memorization_record_model.dart
import 'package:isar/isar.dart';

part 'memorization_record_model.g.dart';

@Collection()
class MemorizationRecordModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int surahId;

  late int statusIndex; // MemorizationStatus.index

  late DateTime updatedAt;

  DateTime? lastAccessedAt;

  late int localChangeVersion;
}
