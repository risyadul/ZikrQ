import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/repositories/habit_repository_impl.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';

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

void main() {
  late MockHabitLocalDatasource datasource;
  late HabitRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(HabitPlanModel());
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
}
