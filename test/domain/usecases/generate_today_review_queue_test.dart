import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';
import 'package:zikrq/domain/usecases/generate_today_review_queue.dart';

class MockReviewQueueRepository extends Mock implements ReviewQueueRepository {}

void main() {
  late MockReviewQueueRepository repository;
  late GenerateTodayReviewQueueUseCase useCase;

  setUp(() {
    repository = MockReviewQueueRepository();
    useCase = GenerateTodayReviewQueueUseCase(repository);
  });

  test('returns score-sorted tasks', () async {
    final today = DateTime(2026, 3, 30);
    final unsorted = [
      ReviewTask(
        id: 'a',
        surahId: 2,
        source: ReviewTaskSource.manual,
        scheduledDate: today,
        priorityScore: 10,
        updatedAt: today,
        localChangeVersion: 1,
      ),
      ReviewTask(
        id: 'b',
        surahId: 1,
        source: ReviewTaskSource.needsReview,
        scheduledDate: today,
        priorityScore: 80,
        updatedAt: today,
        localChangeVersion: 1,
      ),
      ReviewTask(
        id: 'c',
        surahId: 3,
        source: ReviewTaskSource.streakRecovery,
        scheduledDate: today,
        priorityScore: 50,
        updatedAt: today,
        localChangeVersion: 1,
      ),
    ];

    when(
      () => repository.generateTodayQueue(any()),
    ).thenAnswer((_) async => unsorted);

    final result = await useCase(date: today);
    expect(result.map((task) => task.priorityScore).toList(), [80, 50, 10]);
  });
}
