import 'package:meta/meta.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/models/review_task_model.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';
import 'package:zikrq/domain/services/habit_rules.dart';

@immutable
class ReviewQueueRepositoryImpl implements ReviewQueueRepository {
  const ReviewQueueRepositoryImpl({
    required HabitLocalDatasource habitDatasource,
    required MemorizationLocalDatasource memorizationDatasource,
  }) : _habitDatasource = habitDatasource,
       _memorizationDatasource = memorizationDatasource;

  final HabitLocalDatasource _habitDatasource;
  final MemorizationLocalDatasource _memorizationDatasource;

  @override
  Future<List<ReviewTask>> generateTodayQueue(DateTime date) async {
    final existing = await _habitDatasource.getQueueByDate(date);
    if (existing.isNotEmpty) {
      return _toEntities(existing);
    }
    return regenerateQueueForDate(date);
  }

  @override
  Future<List<ReviewTask>> refreshQueue(DateTime date) =>
      regenerateQueueForDate(date);

  Future<List<ReviewTask>> regenerateQueueForDate(DateTime date) async {
    final localDate = _localDate(date);
    final records = await _memorizationDatasource.getAllRecords();

    final tasks = <ReviewTask>[];
    for (final record in records) {
      if (record.statusIndex < 0 ||
          record.statusIndex >= MemorizationStatus.values.length) {
        continue;
      }

      final status = MemorizationStatus.values[record.statusIndex];
      if (status == MemorizationStatus.notStarted) {
        continue;
      }

      final lastReviewedAt = record.updatedAt.toLocal();
      final daysSince = localDate.difference(_localDate(lastReviewedAt)).inDays;
      final source = status == MemorizationStatus.needsReview
          ? ReviewTaskSource.needsReview
          : ReviewTaskSource.manual;
      final priorityScore = HabitRules.priorityScore(
        status: status,
        daysSinceLastReviewed: daysSince,
        isRecoveryTask: false,
      );

      tasks.add(
        ReviewTask(
          id: '${localDate.toIso8601String()}-${record.surahId}-${source.index}',
          surahId: record.surahId,
          source: source,
          scheduledDate: localDate,
          priorityScore: priorityScore,
          updatedAt: DateTime.now(),
          localChangeVersion: 1,
        ),
      );
    }

    final sorted = HabitRules.sortQueue(tasks);
    final models = sorted.map(_toModel).toList();
    await _habitDatasource.replaceQueueForDate(localDate, models);
    return sorted;
  }

  @override
  Future<void> completeTaskAction({
    required String taskId,
    required MemorizationStatus nextStatus,
  }) => _habitDatasource.completeTaskActionTransactional(
    taskId: taskId,
    statusIndex: nextStatus.index,
  );

  List<ReviewTask> _toEntities(List<ReviewTaskModel> models) {
    final tasks = models.map(_toEntity).toList();
    return HabitRules.sortQueue(tasks);
  }

  ReviewTaskModel _toModel(ReviewTask task) => ReviewTaskModel()
    ..taskId = task.id
    ..surahId = task.surahId
    ..priorityScore = task.priorityScore
    ..scheduledDate = _localDate(task.scheduledDate)
    ..source = task.source.index
    ..updatedAt = task.updatedAt
    ..localChangeVersion = task.localChangeVersion;

  ReviewTask _toEntity(ReviewTaskModel model) {
    final source =
        model.source >= 0 && model.source < ReviewTaskSource.values.length
        ? ReviewTaskSource.values[model.source]
        : ReviewTaskSource.manual;

    return ReviewTask(
      id: model.taskId,
      surahId: model.surahId,
      source: source,
      scheduledDate: model.scheduledDate,
      priorityScore: model.priorityScore,
      updatedAt: model.updatedAt,
      localChangeVersion: model.localChangeVersion,
    );
  }

  static DateTime _localDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
