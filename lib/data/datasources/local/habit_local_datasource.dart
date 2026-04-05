import 'package:isar/isar.dart';
import 'package:zikrq/data/models/daily_progress_model.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/data/models/review_task_model.dart';
import 'package:zikrq/data/models/user_preference_model.dart';

class HabitLocalDatasource {
  const HabitLocalDatasource(this._isar);

  final Isar _isar;

  Future<HabitPlanModel?> getPlan() =>
      _isar.habitPlanModels.where().findFirst();

  Future<void> savePlan(HabitPlanModel plan) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.habitPlanModels.where().findFirst();
      if (existing != null) {
        plan.id = existing.id;
      }
      await _isar.habitPlanModels.put(plan);
    });
  }

  Future<DailyProgressModel?> getProgressByDate(DateTime date) {
    final localDate = _localDate(date);
    return _isar.dailyProgressModels
        .filter()
        .dateEqualTo(localDate)
        .findFirst();
  }

  Future<void> saveProgress(DailyProgressModel progress) async {
    final localDate = _localDate(progress.date);
    progress.date = localDate;

    await _isar.writeTxn(() async {
      final existing = await _isar.dailyProgressModels
          .filter()
          .dateEqualTo(localDate)
          .findFirst();
      if (existing != null) {
        progress.id = existing.id;
      }
      await _isar.dailyProgressModels.put(progress);
    });
  }

  Future<UserPreferenceModel?> getPreference() =>
      _isar.userPreferenceModels.where().findFirst();

  Future<void> savePreference(UserPreferenceModel preference) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.userPreferenceModels.where().findFirst();
      if (existing != null) {
        preference.id = existing.id;
      }
      await _isar.userPreferenceModels.put(preference);
    });
  }

  Future<List<ReviewTaskModel>> getQueueByDate(DateTime date) {
    final localDate = _localDate(date);
    return _isar.reviewTaskModels
        .filter()
        .scheduledDateEqualTo(localDate)
        .findAll();
  }

  Future<void> replaceQueueForDate(
    DateTime date,
    List<ReviewTaskModel> tasks,
  ) async {
    final localDate = _localDate(date);

    await _isar.writeTxn(() async {
      final existing = await _isar.reviewTaskModels
          .filter()
          .scheduledDateEqualTo(localDate)
          .findAll();
      final ids = existing.map((task) => task.id).toList();
      if (ids.isNotEmpty) {
        await _isar.reviewTaskModels.deleteAll(ids);
      }

      if (tasks.isNotEmpty) {
        for (final task in tasks) {
          task.scheduledDate = localDate;
        }
        await _isar.reviewTaskModels.putAll(tasks);
      }
    });
  }

  Future<ReviewTaskModel?> getTaskByTaskId(String taskId) =>
      _isar.reviewTaskModels.filter().taskIdEqualTo(taskId).findFirst();

  Future<void> deleteTaskByTaskId(String taskId) async {
    await _isar.writeTxn(() async {
      final task = await getTaskByTaskId(taskId);
      if (task != null) {
        await _isar.reviewTaskModels.delete(task.id);
      }
    });
  }

  Future<void> completeTaskActionTransactional({
    required String taskId,
    required int statusIndex,
  }) async {
    await _isar.writeTxn(() async {
      final task = await _isar.reviewTaskModels
          .filter()
          .taskIdEqualTo(taskId)
          .findFirst();
      if (task == null) {
        return;
      }

      final record = await _isar.memorizationRecordModels
          .filter()
          .surahIdEqualTo(task.surahId)
          .findFirst();
      if (record != null) {
        record
          ..statusIndex = statusIndex
          ..updatedAt = DateTime.now();
        await _isar.memorizationRecordModels.put(record);
      }

      await _isar.reviewTaskModels.delete(task.id);
    });
  }

  static DateTime _localDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
