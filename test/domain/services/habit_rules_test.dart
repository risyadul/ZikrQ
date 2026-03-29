import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/services/habit_rules.dart';

void main() {
  group('HabitRules', () {
    test('suggested target caps at 150% of base', () {
      final result = HabitRules.suggestedTargetAyat(
        dailyTargetAyat: 10,
        missedActiveDays: 99,
      );

      expect(result, 15);
    });

    test('suggested target applies recovery boost before cap', () {
      final result = HabitRules.suggestedTargetAyat(
        dailyTargetAyat: 10,
        missedActiveDays: 2,
      );

      expect(result, 14);
    });

    test('needsReview score is higher than inProgress score', () {
      final needsReview = HabitRules.priorityScore(
        status: MemorizationStatus.needsReview,
        daysSinceLastReviewed: 5,
        isRecoveryTask: false,
      );
      final inProgress = HabitRules.priorityScore(
        status: MemorizationStatus.inProgress,
        daysSinceLastReviewed: 5,
        isRecoveryTask: false,
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
      expect(HabitRules.recoveryWeight(isRecoveryTask: true), 15);
      expect(HabitRules.recoveryWeight(isRecoveryTask: false), 0);
    });

    test('recency contribution uses non-capped slope of 2 per day', () {
      final base = HabitRules.priorityScore(
        status: MemorizationStatus.inProgress,
        daysSinceLastReviewed: 0,
        isRecoveryTask: false,
      );
      final fiveDays = HabitRules.priorityScore(
        status: MemorizationStatus.inProgress,
        daysSinceLastReviewed: 5,
        isRecoveryTask: false,
      );

      expect(fiveDays - base, 10);
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
        status: MemorizationStatus.inProgress,
        daysSinceLastReviewed: 15,
        isRecoveryTask: false,
      );
      final aboveCap = HabitRules.priorityScore(
        status: MemorizationStatus.inProgress,
        daysSinceLastReviewed: 365,
        isRecoveryTask: false,
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
          updatedAt: DateTime(2026, 3, 30),
          localChangeVersion: 1,
        ),
        ReviewTask(
          id: 'b',
          surahId: 3,
          source: ReviewTaskSource.manual,
          scheduledDate: DateTime(2026, 3, 30),
          lastReviewedAt: DateTime(2026, 3, 27),
          priorityScore: 80,
          updatedAt: DateTime(2026, 3, 30),
          localChangeVersion: 1,
        ),
        ReviewTask(
          id: 'c',
          surahId: 1,
          source: ReviewTaskSource.manual,
          scheduledDate: DateTime(2026, 3, 30),
          lastReviewedAt: DateTime(2026, 3, 27),
          priorityScore: 80,
          updatedAt: DateTime(2026, 3, 30),
          localChangeVersion: 1,
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
