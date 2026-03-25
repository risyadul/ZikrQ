import 'package:meta/meta.dart';

@immutable
class Verse {
  const Verse({
    required this.id,
    required this.surahId,
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int id;
  final int surahId;
  final int number;
  final String arabic;
  final String translation;

  @override
  bool operator ==(Object other) => other is Verse && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
