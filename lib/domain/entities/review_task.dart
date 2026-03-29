import 'package:meta/meta.dart';

enum ReviewTaskSource { needsReview, streakRecovery, manual }

const Object _lastReviewedAtNotSet = Object();

@immutable
class ReviewTask {
  const ReviewTask({
    required this.id,
    required this.surahId,
    required this.source,
    required this.scheduledDate,
    this.lastReviewedAt,
    required this.priorityScore,
    required this.updatedAt,
    required this.localChangeVersion,
  });

  final String id;
  final int surahId;
  final ReviewTaskSource source;
  final DateTime scheduledDate;
  final DateTime? lastReviewedAt;
  final int priorityScore;
  final DateTime updatedAt;
  final int localChangeVersion;

  ReviewTask copyWith({
    String? id,
    int? surahId,
    ReviewTaskSource? source,
    DateTime? scheduledDate,
    Object? lastReviewedAt = _lastReviewedAtNotSet,
    int? priorityScore,
    DateTime? updatedAt,
    int? localChangeVersion,
  }) => ReviewTask(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    source: source ?? this.source,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    lastReviewedAt: identical(lastReviewedAt, _lastReviewedAtNotSet)
        ? this.lastReviewedAt
        : lastReviewedAt as DateTime?,
    priorityScore: priorityScore ?? this.priorityScore,
    updatedAt: updatedAt ?? this.updatedAt,
    localChangeVersion: localChangeVersion ?? this.localChangeVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is ReviewTask &&
      other.id == id &&
      other.surahId == surahId &&
      other.source == source &&
      other.scheduledDate == scheduledDate &&
      other.lastReviewedAt == lastReviewedAt &&
      other.priorityScore == priorityScore &&
      other.updatedAt == updatedAt &&
      other.localChangeVersion == localChangeVersion;

  @override
  int get hashCode => Object.hash(
    id,
    surahId,
    source,
    scheduledDate,
    lastReviewedAt,
    priorityScore,
    updatedAt,
    localChangeVersion,
  );
}
