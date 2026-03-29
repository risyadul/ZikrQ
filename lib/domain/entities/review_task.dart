enum ReviewTaskSource { needsReview, streakRecovery, manual }

class ReviewTask {
  const ReviewTask({
    required this.id,
    required this.surahId,
    required this.source,
    required this.scheduledDate,
    this.lastReviewedAt,
    required this.priorityScore,
  });

  final String id;
  final int surahId;
  final ReviewTaskSource source;
  final DateTime scheduledDate;
  final DateTime? lastReviewedAt;
  final int priorityScore;
}
