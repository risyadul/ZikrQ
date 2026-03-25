import 'package:zikrq/domain/entities/verse.dart';

class VerseWithMark {
  const VerseWithMark({required this.verse, required this.isMarked});

  final Verse verse;
  final bool isMarked;

  VerseWithMark copyWith({bool? isMarked}) =>
      VerseWithMark(verse: verse, isMarked: isMarked ?? this.isMarked);
}
