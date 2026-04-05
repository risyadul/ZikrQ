import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';

abstract interface class ReviewQueueRepository {
  /// Generates the queue for a local calendar day.
  ///
  /// [date] uses local-date semantics and is interpreted by its local day
  /// boundary (00:00 local time).
  Future<List<ReviewTask>> generateTodayQueue(DateTime date);

  /// Recomputes queue ordering/content for a local calendar day.
  ///
  /// [date] uses local-date semantics and is interpreted by its local day
  /// boundary (00:00 local time).
  Future<List<ReviewTask>> refreshQueue(DateTime date);
  Future<void> completeTaskAction({
    required String taskId,
    required MemorizationStatus nextStatus,
  });
}
