import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/repositories/quick_action_repository_impl.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class MockHabitLocalDatasource extends Mock implements HabitLocalDatasource {}

class MockMemorizationLocalDatasource extends Mock
    implements MemorizationLocalDatasource {}

void main() {
  late MockHabitLocalDatasource habitDatasource;
  late MockMemorizationLocalDatasource memorizationDatasource;
  late QuickActionRepositoryImpl repository;

  setUp(() {
    habitDatasource = MockHabitLocalDatasource();
    memorizationDatasource = MockMemorizationLocalDatasource();
    repository = QuickActionRepositoryImpl(
      habitDatasource: habitDatasource,
      memorizationDatasource: memorizationDatasource,
    );
  });

  test(
    'applyStatusToSurahs delegates to transactional datasource update',
    () async {
      const surahIds = [2, 18, 36];
      const status = MemorizationStatus.needsReview;

      when(
        () => memorizationDatasource.updateStatusesTransactional(
          surahIds,
          status.index,
        ),
      ).thenAnswer((_) async {});

      await repository.applyStatusToSurahs(surahIds: surahIds, status: status);

      verify(
        () => memorizationDatasource.updateStatusesTransactional(
          surahIds,
          status.index,
        ),
      ).called(1);
      verifyNoMoreInteractions(memorizationDatasource);
    },
  );
}
