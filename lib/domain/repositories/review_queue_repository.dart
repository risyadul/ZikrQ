import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';

abstract interface class ReviewQueueRepository {
  Future<List<ReviewTask>> generateTodayQueue(DateTime date);
  Future<List<ReviewTask>> refreshQueue(DateTime date);
  Future<void> completeTaskAction({
    required String taskId,
    required MemorizationStatus nextStatus,
  });
}
