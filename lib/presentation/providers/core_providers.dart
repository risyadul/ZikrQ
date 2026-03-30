// lib/presentation/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:zikrq/data/datasources/local/habit_local_datasource.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/datasources/local/quran_local_datasource.dart';
import 'package:zikrq/data/repositories/habit_repository_impl.dart';
import 'package:zikrq/data/repositories/quick_action_repository_impl.dart';
import 'package:zikrq/data/repositories/quran_repository_impl.dart';
import 'package:zikrq/data/repositories/review_queue_repository_impl.dart';
import 'package:zikrq/domain/repositories/habit_repository.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/repositories/reminder_scheduler.dart';
import 'package:zikrq/domain/repositories/review_queue_repository.dart';
import 'package:zikrq/domain/usecases/bulk_update_surah_status.dart';
import 'package:zikrq/domain/usecases/generate_today_review_queue.dart';
import 'package:zikrq/domain/usecases/get_all_surahs.dart';
import 'package:zikrq/domain/usecases/get_memorization_stats.dart';
import 'package:zikrq/domain/usecases/get_today_dashboard.dart';
import 'package:zikrq/domain/usecases/get_verses_by_surah.dart';
import 'package:zikrq/domain/usecases/quick_update_surah_status.dart';
import 'package:zikrq/domain/usecases/reschedule_reminder.dart';
import 'package:zikrq/domain/usecases/schedule_reminder.dart';
import 'package:zikrq/domain/usecases/seed_initial_data.dart';
import 'package:zikrq/domain/usecases/toggle_verse_mark.dart';
import 'package:zikrq/domain/usecases/update_daily_target.dart';
import 'package:zikrq/domain/usecases/update_memorization_status.dart';

// Isar instance — opened once on startup
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

// Datasources
final quranLocalDatasourceProvider = Provider<QuranLocalDatasource>(
  (ref) => QuranLocalDatasource(ref.watch(isarProvider)),
);

final memorizationLocalDatasourceProvider =
    Provider<MemorizationLocalDatasource>(
      (ref) => MemorizationLocalDatasource(ref.watch(isarProvider)),
    );

final habitLocalDatasourceProvider = Provider<HabitLocalDatasource>(
  (ref) => HabitLocalDatasource(ref.watch(isarProvider)),
);

// Repository
final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepositoryImpl(
    quranDatasource: ref.watch(quranLocalDatasourceProvider),
    memorizationDatasource: ref.watch(memorizationLocalDatasourceProvider),
  ),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepositoryImpl(ref.watch(habitLocalDatasourceProvider)),
);

final reviewQueueRepositoryProvider = Provider<ReviewQueueRepository>(
  (ref) => ReviewQueueRepositoryImpl(
    habitDatasource: ref.watch(habitLocalDatasourceProvider),
    memorizationDatasource: ref.watch(memorizationLocalDatasourceProvider),
  ),
);

final quickActionRepositoryProvider = Provider<QuickActionRepository>(
  (ref) => QuickActionRepositoryImpl(
    habitDatasource: ref.watch(habitLocalDatasourceProvider),
    memorizationDatasource: ref.watch(memorizationLocalDatasourceProvider),
  ),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const _ReminderSchedulerPlaceholder(),
);

// Use cases
final getAllSurahsUseCaseProvider = Provider<GetAllSurahsUseCase>(
  (ref) => GetAllSurahsUseCase(ref.watch(quranRepositoryProvider)),
);

final getVersesBySurahUseCaseProvider = Provider<GetVersesBySurahUseCase>(
  (ref) => GetVersesBySurahUseCase(ref.watch(quranRepositoryProvider)),
);

final updateMemorizationStatusUseCaseProvider =
    Provider<UpdateMemorizationStatusUseCase>(
      (ref) =>
          UpdateMemorizationStatusUseCase(ref.watch(quranRepositoryProvider)),
    );

final toggleVerseMarkUseCaseProvider = Provider<ToggleVerseMarkUseCase>(
  (ref) => ToggleVerseMarkUseCase(ref.watch(quranRepositoryProvider)),
);

final getMemorizationStatsUseCaseProvider =
    Provider<GetMemorizationStatsUseCase>(
      (ref) => GetMemorizationStatsUseCase(ref.watch(quranRepositoryProvider)),
    );

final seedInitialDataUseCaseProvider = Provider<SeedInitialDataUseCase>(
  (ref) => SeedInitialDataUseCase(ref.watch(quranRepositoryProvider)),
);

final getTodayDashboardUseCaseProvider = Provider<GetTodayDashboardUseCase>(
  (ref) => GetTodayDashboardUseCase(
    ref.watch(habitRepositoryProvider),
    ref.watch(reviewQueueRepositoryProvider),
  ),
);

final updateDailyTargetUseCaseProvider = Provider<UpdateDailyTargetUseCase>(
  (ref) => UpdateDailyTargetUseCase(ref.watch(habitRepositoryProvider)),
);

final generateTodayReviewQueueUseCaseProvider =
    Provider<GenerateTodayReviewQueueUseCase>(
      (ref) => GenerateTodayReviewQueueUseCase(
        ref.watch(reviewQueueRepositoryProvider),
      ),
    );

final quickUpdateSurahStatusUseCaseProvider =
    Provider<QuickUpdateSurahStatusUseCase>(
      (ref) => QuickUpdateSurahStatusUseCase(
        ref.watch(quickActionRepositoryProvider),
      ),
    );

final bulkUpdateSurahStatusUseCaseProvider =
    Provider<BulkUpdateSurahStatusUseCase>(
      (ref) => BulkUpdateSurahStatusUseCase(
        ref.watch(quickActionRepositoryProvider),
      ),
    );

final scheduleReminderUseCaseProvider = Provider<ScheduleReminderUseCase>(
  (ref) => ScheduleReminderUseCase(
    habitRepository: ref.watch(habitRepositoryProvider),
    reminderScheduler: ref.watch(reminderSchedulerProvider),
  ),
);

final rescheduleReminderUseCaseProvider = Provider<RescheduleReminderUseCase>(
  (ref) => RescheduleReminderUseCase(
    habitRepository: ref.watch(habitRepositoryProvider),
    reminderScheduler: ref.watch(reminderSchedulerProvider),
  ),
);

class _ReminderSchedulerPlaceholder implements ReminderScheduler {
  const _ReminderSchedulerPlaceholder();

  @override
  Future<void> cancelAllReminders() => throw UnimplementedError(
    'ReminderScheduler concrete binding is provided in Task 6.',
  );

  @override
  Future<void> openSystemNotificationSettings() => throw UnimplementedError(
    'ReminderScheduler concrete binding is provided in Task 6.',
  );

  @override
  Future<bool> requestPermission() => throw UnimplementedError(
    'ReminderScheduler concrete binding is provided in Task 6.',
  );

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required Set<int> activeWeekdays,
  }) => throw UnimplementedError(
    'ReminderScheduler concrete binding is provided in Task 6.',
  );
}
