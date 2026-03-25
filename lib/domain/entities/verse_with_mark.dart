import 'package:meta/meta.dart';
import 'package:zikrq/domain/entities/verse.dart';

@immutable
class VerseWithMark {
  const VerseWithMark({required this.verse, required this.isMarked});

  final Verse verse;
  final bool isMarked;

  VerseWithMark copyWith({bool? isMarked}) =>
      VerseWithMark(verse: verse, isMarked: isMarked ?? this.isMarked);

  @override
  bool operator ==(Object other) =>
      other is VerseWithMark &&
      other.verse == verse &&
      other.isMarked == isMarked;

  @override
  int get hashCode => Object.hash(verse, isMarked);
}
