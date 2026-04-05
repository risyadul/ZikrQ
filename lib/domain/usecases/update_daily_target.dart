import 'package:zikrq/domain/entities/habit_plan.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';

class UpdateDailyTargetUseCase {
  const UpdateDailyTargetUseCase(this._habitRepository);

  final HabitRepository _habitRepository;

  Future<HabitPlan> call(int dailyTargetAyat) async {
    if (dailyTargetAyat < 1) {
      throw ArgumentError.value(
        dailyTargetAyat,
        'dailyTargetAyat',
        'dailyTargetAyat must be >= 1',
      );
    }

    final current = await _habitRepository.getPlan();
    final updated = current.copyWith(
      dailyTargetAyat: dailyTargetAyat,
      updatedAt: DateTime.now(),
      localChangeVersion: current.localChangeVersion + 1,
    );
    await _habitRepository.savePlan(updated);
    return updated;
  }
}
