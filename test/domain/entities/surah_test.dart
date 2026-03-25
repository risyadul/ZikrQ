import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';

void main() {
  const surah = Surah(
    id: 1,
    name: 'Al-Fatihah',
    nameArabic: 'الفاتحة',
    totalVerses: 7,
    juzStart: 1,
    revelation: 'Meccan',
    status: MemorizationStatus.notStarted,
  );

  test('copyWith changes only status', () {
    final updated = surah.copyWith(status: MemorizationStatus.memorized);
    expect(updated.status, MemorizationStatus.memorized);
    expect(updated.name, surah.name);
    expect(updated.id, surah.id);
  });

  test('equality is based on id and status', () {
    final same = surah.copyWith(status: MemorizationStatus.notStarted);
    expect(surah, equals(same));
  });

  test('MemorizationStatus labels are non-empty', () {
    for (final s in MemorizationStatus.values) {
      expect(s.label.isNotEmpty, isTrue);
    }
  });
}
