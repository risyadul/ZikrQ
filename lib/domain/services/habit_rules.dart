import 'dart:math' as math;

import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';

class HabitRules {
  static const int needsReviewStatusWeight = 100;
  static const int inProgressStatusWeight = 60;
  static const int memorizedStatusWeight = 20;
  static const int notStartedStatusWeight = 10;

  static const int recoveryBonusWeight = 15;
  static const int recencyCap = 30;

  static int suggestedTargetAyat({
    required int dailyTargetAyat,
    required int missedActiveDays,
  }) {
    if (dailyTargetAyat <= 0) {
      return 0;
    }

    final missed = math.max(0, missedActiveDays);
    final recoveryBoost = math.min(5, missed * 2);
    final suggested = dailyTargetAyat + recoveryBoost;
    final maxTarget = ((dailyTargetAyat * 3) + 1) ~/ 2;

    return math.min(suggested, maxTarget);
  }

  static int priorityScore({
    required MemorizationStatus status,
    required int daysSinceLastReviewed,
    required bool isRecoveryTask,
  }) {
    final recencyWeight = math.max(0, daysSinceLastReviewed) * 2;
    final boundedRecency = math.min(recencyCap, recencyWeight);

    return statusWeight(status) +
        boundedRecency +
        recoveryWeight(isRecoveryTask: isRecoveryTask);
  }

  static int statusWeight(MemorizationStatus status) {
    return switch (status) {
      MemorizationStatus.needsReview => needsReviewStatusWeight,
      MemorizationStatus.inProgress => inProgressStatusWeight,
      MemorizationStatus.memorized => memorizedStatusWeight,
      MemorizationStatus.notStarted => notStartedStatusWeight,
    };
  }

  static int recoveryWeight({required bool isRecoveryTask}) {
    return isRecoveryTask ? recoveryBonusWeight : 0;
  }

  static bool shouldExitRecoveryMode(
    List<bool> recentActiveDaysCompleted, {
    int minConsecutiveSuccessDays = 2,
  }) {
    if (minConsecutiveSuccessDays <= 0) {
      return true;
    }

    if (recentActiveDaysCompleted.length < minConsecutiveSuccessDays) {
      return false;
    }

    final start = recentActiveDaysCompleted.length - minConsecutiveSuccessDays;
    return recentActiveDaysCompleted
        .sublist(start)
        .every((completed) => completed);
  }

  static List<ReviewTask> sortQueue(List<ReviewTask> queue) {
    final sorted = List<ReviewTask>.from(queue);
    sorted.sort((a, b) {
      final byPriority = b.priorityScore.compareTo(a.priorityScore);
      if (byPriority != 0) {
        return byPriority;
      }

      final aDate = a.lastReviewedAt;
      final bDate = b.lastReviewedAt;

      if (aDate == null && bDate != null) {
        return -1;
      }
      if (aDate != null && bDate == null) {
        return 1;
      }
      if (aDate != null && bDate != null) {
        final byRecency = aDate.compareTo(bDate);
        if (byRecency != 0) {
          return byRecency;
        }
      }

      return a.surahId.compareTo(b.surahId);
    });
    return sorted;
  }

  static bool isRolloverDate(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year != localB.year ||
        localA.month != localB.month ||
        localA.day != localB.day;
  }
}
