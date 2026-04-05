import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/models/user_preference_model.dart';
import 'package:zikrq/data/repositories/habit_repository_impl.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/user_preference.dart';

class MockHabitLocalDatasource extends Mock implements HabitLocalDatasource {}

HabitPlan _samplePlan() => HabitPlan(
  dailyTargetAyat: 12,
  activeDays: const [1, 2, 4, 6],
  reminderEnabled: true,
  reminderHour: 5,
  reminderMinute: 45,
  snoozeMinutes: 10,
  updatedAt: DateTime(2026, 3, 30, 8),
  localChangeVersion: 7,
);

HabitPlanModel _modelFromPlan(HabitPlan plan) => HabitPlanModel()
  ..dailyTargetAyat = plan.dailyTargetAyat
  ..activeDays = List<int>.from(plan.activeDays)
  ..reminderEnabled = plan.reminderEnabled
  ..reminderHour = plan.reminderHour
  ..reminderMinute = plan.reminderMinute
  ..snoozeMinutes = plan.snoozeMinutes
  ..updatedAt = plan.updatedAt
  ..localChangeVersion = plan.localChangeVersion;

UserPreference _samplePreference({
  MemorizationStatus defaultQuickAction = MemorizationStatus.memorized,
  bool hapticEnabled = false,
  int localChangeVersion = 3,
}) => UserPreference(
  onboardingCompleted: true,
  notificationsPermissionRequested: true,
  notificationsPermissionGranted: true,
  soundEnabled: true,
  vibrationEnabled: true,
  snoozeMinutes: 15,
  defaultQuickAction: defaultQuickAction,
  lastUsedStatusAction: null,
  hapticEnabled: hapticEnabled,
  updatedAt: DateTime(2026, 3, 30, 8),
  localChangeVersion: localChangeVersion,
);

UserPreferenceModel _modelFromPreference(UserPreference preference) =>
    UserPreferenceModel()
      ..onboardingCompleted = preference.onboardingCompleted
      ..notificationsPermissionRequested =
          preference.notificationsPermissionRequested
      ..notificationsPermissionGranted =
          preference.notificationsPermissionGranted
      ..soundEnabled = preference.soundEnabled
      ..vibrationEnabled = preference.vibrationEnabled
      ..snoozeMinutes = preference.snoozeMinutes
      ..defaultQuickAction = preference.defaultQuickAction.index
      ..lastUsedStatusAction = preference.lastUsedStatusAction?.index
      ..hapticEnabled = preference.hapticEnabled
      ..updatedAt = preference.updatedAt
      ..localChangeVersion = preference.localChangeVersion;

void main() {
  late MockHabitLocalDatasource datasource;
  late HabitRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HabitPlanModel());
    registerFallbackValue(UserPreferenceModel());
  });

  setUp(() {
    datasource = MockHabitLocalDatasource();
    repository = HabitRepositoryImpl(datasource);
  });

  test('savePlan then getPlan returns the persisted values', () async {
    final plan = _samplePlan();
    HabitPlanModel? storedModel;

    when(() => datasource.savePlan(any())).thenAnswer((invocation) async {
      storedModel = invocation.positionalArguments.first as HabitPlanModel;
    });

    when(() => datasource.getPlan()).thenAnswer((_) async => storedModel);

    await repository.savePlan(plan);
    final result = await repository.getPlan();

    expect(result, plan);
    verify(() => datasource.savePlan(any())).called(1);
    verify(() => datasource.getPlan()).called(1);
  });

  test('getPlan maps datasource model to entity', () async {
    final plan = _samplePlan();
    final model = _modelFromPlan(plan);

    when(() => datasource.getPlan()).thenAnswer((_) async => model);

    final result = await repository.getPlan();

    expect(result, plan);
  });

  test('getPreference keeps valid quick action and haptic values', () async {
    final preference = _samplePreference(
      defaultQuickAction: MemorizationStatus.needsReview,
      hapticEnabled: false,
      localChangeVersion: 4,
    );
    final model = _modelFromPreference(preference);

    when(() => datasource.getPreference()).thenAnswer((_) async => model);

    final result = await repository.getPreference();

    expect(result.defaultQuickAction, MemorizationStatus.needsReview);
    expect(result.hapticEnabled, isFalse);
  });

  test('getPreference maps persisted last used quick action', () async {
    final model = _modelFromPreference(_samplePreference())
      ..lastUsedStatusAction = MemorizationStatus.memorized.index;

    when(() => datasource.getPreference()).thenAnswer((_) async => model);

    final result = await repository.getPreference();

    expect(result.lastUsedStatusAction, MemorizationStatus.memorized);
  });

  test('getPreference defaults invalid quick action to inProgress', () async {
    final model = _modelFromPreference(_samplePreference())
      ..defaultQuickAction = -1;

    when(() => datasource.getPreference()).thenAnswer((_) async => model);

    final result = await repository.getPreference();

    expect(result.defaultQuickAction, MemorizationStatus.inProgress);
  });

  test('getPreference defaults legacy quick action to inProgress', () async {
    final model = _modelFromPreference(_samplePreference())
      ..defaultQuickAction = MemorizationStatus.notStarted.index
      ..localChangeVersion = 0;

    when(() => datasource.getPreference()).thenAnswer((_) async => model);

    final result = await repository.getPreference();

    expect(result.defaultQuickAction, MemorizationStatus.inProgress);
  });

  test('getPreference defaults legacy haptic value to true', () async {
    final model = _modelFromPreference(_samplePreference())
      ..hapticEnabled = false
      ..localChangeVersion = 0;

    when(() => datasource.getPreference()).thenAnswer((_) async => model);

    final result = await repository.getPreference();

    expect(result.hapticEnabled, isTrue);
  });

  test('getPreference returns default permission flags when missing', () async {
    when(() => datasource.getPreference()).thenAnswer((_) async => null);

    final result = await repository.getPreference();

    expect(result.notificationsPermissionRequested, isFalse);
    expect(result.notificationsPermissionGranted, isFalse);
  });
}
