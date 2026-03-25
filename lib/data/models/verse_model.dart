// lib/data/models/verse_model.dart
import 'package:isar/isar.dart';

part 'verse_model.g.dart';

@Collection()
class VerseModel {
  Id id = Isar.autoIncrement;

  late int verseId; // global verse id from JSON
  @Index()
  late int surahId;
  late int number;
  late String arabic;
  late String translation;
}
