import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/models/user_preference_model.dart';
import 'package:zikrq/data/repositories/quick_action_repository_impl.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';

class MockHabitLocalDatasource extends Mock implements HabitLocalDatasource {}

class MockMemorizationLocalDatasource extends Mock
    implements MemorizationLocalDatasource {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserPreferenceModel());
  });

  late MockHabitLocalDatasource habitDatasource;
  late MockMemorizationLocalDatasource memorizationDatasource;
  late QuickActionRepositoryImpl repository;

  setUp(() {
    habitDatasource = MockHabitLocalDatasource();
    memorizationDatasource = MockMemorizationLocalDatasource();
    QuickActionRepositoryImpl.resetLastUsedStatusActionCache();
    repository = QuickActionRepositoryImpl(
      habitDatasource: habitDatasource,
      memorizationDatasource: memorizationDatasource,
    );
  });

  test(
    'getLastUsedStatusAction reads persisted preference when cache is empty',
    () async {
      final preference = UserPreferenceModel()
        ..onboardingCompleted = false
        ..notificationsPermissionRequested = false
        ..notificationsPermissionGranted = false
        ..soundEnabled = true
        ..vibrationEnabled = true
        ..snoozeMinutes = 10
        ..defaultQuickAction = MemorizationStatus.inProgress.index
        ..lastUsedStatusAction = MemorizationStatus.memorized.index
        ..hapticEnabled = true
        ..updatedAt = DateTime(2026)
        ..localChangeVersion = 3;

      when(
        () => habitDatasource.getPreference(),
      ).thenAnswer((_) async => preference);

      final result = await repository.getLastUsedStatusAction();

      expect(result, MemorizationStatus.memorized);
      verify(() => habitDatasource.getPreference()).called(1);
    },
  );

  test(
    'setLastUsedStatusAction persists status to preference storage',
    () async {
      final preference = UserPreferenceModel()
        ..onboardingCompleted = true
        ..notificationsPermissionRequested = true
        ..notificationsPermissionGranted = true
        ..soundEnabled = true
        ..vibrationEnabled = true
        ..snoozeMinutes = 5
        ..defaultQuickAction = MemorizationStatus.inProgress.index
        ..lastUsedStatusAction = null
        ..hapticEnabled = true
        ..updatedAt = DateTime(2026)
        ..localChangeVersion = 7;

      when(
        () => habitDatasource.getPreference(),
      ).thenAnswer((_) async => preference);
      when(
        () => habitDatasource.savePreference(any()),
      ).thenAnswer((_) async {});

      await repository.setLastUsedStatusAction(MemorizationStatus.needsReview);

      expect(
        preference.lastUsedStatusAction,
        MemorizationStatus.needsReview.index,
      );
      verify(() => habitDatasource.getPreference()).called(1);
      verify(() => habitDatasource.savePreference(preference)).called(1);
    },
  );

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
