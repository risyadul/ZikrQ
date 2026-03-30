import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';
import 'package:zikrq/domain/services/habit_rules.dart';

class GenerateTodayReviewQueueUseCase {
  const GenerateTodayReviewQueueUseCase(this._repository);

  final ReviewQueueRepository _repository;

  Future<List<ReviewTask>> call({DateTime? date, bool refresh = false}) async {
    final localDate = _localDate(date ?? DateTime.now());
    final queue = refresh
        ? await _repository.refreshQueue(localDate)
        : await _repository.generateTodayQueue(localDate);
    return HabitRules.sortQueue(queue);
  }

  DateTime _localDate(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
