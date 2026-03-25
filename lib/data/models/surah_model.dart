// lib/data/models/surah_model.dart
import 'package:isar/isar.dart';

part 'surah_model.g.dart';

@Collection()
class SurahModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int surahId; // 1-114
  late String name;
  late String nameArabic;
  late int totalVerses;
  late int juzStart;
  late String revelation;
}
