import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/entities/today_dashboard.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

final settingsPlanProvider = FutureProvider<HabitPlan>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getPlan();
});

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  final useCase = ref.watch(getTodayDashboardUseCaseProvider);
  return useCase();
});
