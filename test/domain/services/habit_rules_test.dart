import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/services/habit_rules.dart';

void main() {
  group('HabitRules', () {
    test('suggested target caps at 150% of base', () {
      final result = HabitRules.suggestedTargetAyat(10, 99);

      expect(result, 15);
    });

    test('needsReview score is higher than inProgress score', () {
      final needsReview = HabitRules.priorityScore(
        MemorizationStatus.needsReview,
        5,
        false,
      );
      final inProgress = HabitRules.priorityScore(
        MemorizationStatus.inProgress,
        5,
        false,
      );

      expect(needsReview, greaterThan(inProgress));
    });

    test('status weights match constants', () {
      expect(HabitRules.statusWeight(MemorizationStatus.needsReview), 100);
      expect(HabitRules.statusWeight(MemorizationStatus.inProgress), 60);
      expect(HabitRules.statusWeight(MemorizationStatus.memorized), 20);
      expect(HabitRules.statusWeight(MemorizationStatus.notStarted), 10);
    });

    test('recovery weight true is 15 and false is 0', () {
      expect(HabitRules.recoveryWeight(true), 15);
      expect(HabitRules.recoveryWeight(false), 0);
    });

    test(
      'recovery mode exits after two consecutive successful active days',
      () {
        final exits = HabitRules.shouldExitRecoveryMode([false, true, true]);

        expect(exits, isTrue);
      },
    );

    test('recency contribution is capped at 30', () {
      final atCap = HabitRules.priorityScore(
        MemorizationStatus.inProgress,
        30,
        false,
      );
      final aboveCap = HabitRules.priorityScore(
        MemorizationStatus.inProgress,
        365,
        false,
      );

      expect(aboveCap, atCap);
    });

    test('tie-breaker prefers older lastReviewedAt then lower surahId', () {
      final samePriority = [
        ReviewTask(
          id: 'a',
          surahId: 2,
          source: ReviewTaskSource.manual,
          scheduledDate: DateTime(2026, 3, 30),
          lastReviewedAt: DateTime(2026, 3, 28),
          priorityScore: 80,
        ),
        ReviewTask(
          id: 'b',
          surahId: 3,
          source: ReviewTaskSource.manual,
          scheduledDate: DateTime(2026, 3, 30),
          lastReviewedAt: DateTime(2026, 3, 27),
          priorityScore: 80,
        ),
        ReviewTask(
          id: 'c',
          surahId: 1,
          source: ReviewTaskSource.manual,
          scheduledDate: DateTime(2026, 3, 30),
          lastReviewedAt: DateTime(2026, 3, 27),
          priorityScore: 80,
        ),
      ];

      final sorted = HabitRules.sortQueue(samePriority);

      expect(sorted.map((task) => task.id), ['c', 'b', 'a']);
    });

    test('local day-boundary rollover happens at 00:00', () {
      final beforeMidnight = DateTime(2026, 3, 30, 23, 59);
      final atMidnight = DateTime(2026, 3, 31, 0, 0);

      expect(HabitRules.isRolloverDate(beforeMidnight, atMidnight), isTrue);
    });
  });
}
