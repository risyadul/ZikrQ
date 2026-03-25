import 'package:meta/meta.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

@immutable
class Surah {
  const Surah({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.totalVerses,
    required this.juzStart,
    required this.revelation,
    required this.status,
  });

  final int id;
  final String name;
  final String nameArabic;
  final int totalVerses;
  final int juzStart;
  final String revelation; // 'Meccan' | 'Medinan'
  final MemorizationStatus status;

  Surah copyWith({MemorizationStatus? status}) => Surah(
    id: id,
    name: name,
    nameArabic: nameArabic,
    totalVerses: totalVerses,
    juzStart: juzStart,
    revelation: revelation,
    status: status ?? this.status,
  );

  // Equality is based on id and status only — surahs are considered the same
  // UI item when their identity (id) and memorization state (status) match.
  // Other fields (name, verses, etc.) are static and do not affect diffing.
  @override
  bool operator ==(Object other) =>
      other is Surah && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);
}
