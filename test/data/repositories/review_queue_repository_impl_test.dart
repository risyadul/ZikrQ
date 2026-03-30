import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/repositories/review_queue_repository_impl.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class MockHabitLocalDatasource extends Mock implements HabitLocalDatasource {}

class MockMemorizationLocalDatasource extends Mock
    implements MemorizationLocalDatasource {}

void main() {
  late MockHabitLocalDatasource habitDatasource;
  late MockMemorizationLocalDatasource memorizationDatasource;
  late ReviewQueueRepositoryImpl repository;

  setUp(() {
    habitDatasource = MockHabitLocalDatasource();
    memorizationDatasource = MockMemorizationLocalDatasource();
    repository = ReviewQueueRepositoryImpl(
      habitDatasource: habitDatasource,
      memorizationDatasource: memorizationDatasource,
    );
  });

  test(
    'completeTaskAction delegates to atomic datasource transaction',
    () async {
      const taskId = 'task-123';
      const nextStatus = MemorizationStatus.memorized;

      when(
        () => habitDatasource.completeTaskActionTransactional(
          taskId: taskId,
          statusIndex: nextStatus.index,
        ),
      ).thenAnswer((_) async {});

      await repository.completeTaskAction(
        taskId: taskId,
        nextStatus: nextStatus,
      );

      verify(
        () => habitDatasource.completeTaskActionTransactional(
          taskId: taskId,
          statusIndex: nextStatus.index,
        ),
      ).called(1);
      verifyNoMoreInteractions(habitDatasource);
      verifyZeroInteractions(memorizationDatasource);
    },
  );
}
