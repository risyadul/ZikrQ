import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/verse.dart';
import 'package:zikrq/domain/entities/verse_with_mark.dart';

void main() {
  const verse = Verse(
    id: 1,
    surahId: 1,
    number: 1,
    arabic: 'بِسْمِ ٱللَّهِ',
    translation: 'Dengan nama Allah',
  );

  test('copyWith changes only isMarked', () {
    const vwm = VerseWithMark(verse: verse, isMarked: false);
    final updated = vwm.copyWith(isMarked: true);
    expect(updated.isMarked, isTrue);
    expect(updated.verse, verse);
  });

  test('equality holds for identical values', () {
    const a = VerseWithMark(verse: verse, isMarked: false);
    const b = VerseWithMark(verse: verse, isMarked: false);
    expect(a, equals(b));
  });
}
