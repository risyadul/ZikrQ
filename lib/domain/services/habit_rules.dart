import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';

class HabitRules {
  static const int needsReviewStatusWeight = 100;
  static const int inProgressStatusWeight = 60;
  static const int memorizedStatusWeight = 20;
  static const int notStartedStatusWeight = 10;

  static const int recoveryBonusWeight = 15;
  static const int recencyCap = 30;

  static int suggestedTargetAyat(int dailyTargetAyat, int missedActiveDays) {
    if (dailyTargetAyat <= 0) {
      return 0;
    }

    final missed = missedActiveDays < 0 ? 0 : missedActiveDays;
    final maxTarget = (dailyTargetAyat * 3) ~/ 2;
    final suggested = dailyTargetAyat + missed;
    return suggested > maxTarget ? maxTarget : suggested;
  }

  static int priorityScore(
    MemorizationStatus status,
    int daysSinceLastReviewed,
    bool isRecoveryTask,
  ) {
    final recencyContribution = daysSinceLastReviewed < 0
        ? 0
        : daysSinceLastReviewed;
    final boundedRecency = recencyContribution > recencyCap
        ? recencyCap
        : recencyContribution;

    return statusWeight(status) +
        boundedRecency +
        recoveryWeight(isRecoveryTask);
  }

  static int statusWeight(MemorizationStatus status) {
    return switch (status) {
      MemorizationStatus.needsReview => needsReviewStatusWeight,
      MemorizationStatus.inProgress => inProgressStatusWeight,
      MemorizationStatus.memorized => memorizedStatusWeight,
      MemorizationStatus.notStarted => notStartedStatusWeight,
    };
  }

  static int recoveryWeight(bool isRecoveryTask) {
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
