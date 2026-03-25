// lib/data/models/marked_verse_record_model.dart
import 'package:isar/isar.dart';

part 'marked_verse_record_model.g.dart';

@Collection()
class MarkedVerseRecordModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('verseNumber')], unique: true)
  late int surahId;

  late int verseNumber;
  late bool isMarked;
}
