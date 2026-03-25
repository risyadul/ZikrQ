import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';

void main() {
  test('memorizedPercent returns 0 when total is 0', () {
    const stats = MemorizationStats(
      memorized: 0,
      inProgress: 0,
      needsReview: 0,
      notStarted: 0,
      total: 0,
      memorizedVerseCount: 0,
    );
    expect(stats.memorizedPercent, 0.0);
  });

  test('memorizedPercent returns correct ratio', () {
    const stats = MemorizationStats(
      memorized: 10,
      inProgress: 0,
      needsReview: 0,
      notStarted: 4,
      total: 14,
      memorizedVerseCount: 100,
    );
    expect(stats.memorizedPercent, closeTo(10 / 14, 0.0001));
  });

  test('equality holds for identical values', () {
    const a = MemorizationStats(
      memorized: 5,
      inProgress: 2,
      needsReview: 1,
      notStarted: 6,
      total: 14,
      memorizedVerseCount: 50,
    );
    const b = MemorizationStats(
      memorized: 5,
      inProgress: 2,
      needsReview: 1,
      notStarted: 6,
      total: 14,
      memorizedVerseCount: 50,
    );
    expect(a, equals(b));
  });
}
