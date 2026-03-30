// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zikrq/core/constants/app_constants.dart';
import 'package:zikrq/core/services/local_notification_service.dart';
import 'package:zikrq/core/theme/app_theme.dart';
import 'package:zikrq/data/datasources/local/memorization_local_datasource.dart';
import 'package:zikrq/data/datasources/local/quran_local_datasource.dart';
import 'package:zikrq/data/models/marked_verse_record_model.dart';
import 'package:zikrq/data/models/memorization_record_model.dart';
import 'package:zikrq/data/models/daily_progress_model.dart';
import 'package:zikrq/data/models/habit_plan_model.dart';
import 'package:zikrq/data/models/review_task_model.dart';
import 'package:zikrq/data/models/surah_model.dart';
import 'package:zikrq/data/models/user_preference_model.dart';
import 'package:zikrq/data/models/verse_model.dart';
import 'package:zikrq/data/repositories/quran_repository_impl.dart';
import 'package:zikrq/domain/usecases/seed_initial_data.dart';
import 'package:zikrq/presentation/app_router.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    SurahModelSchema,
    VerseModelSchema,
    MemorizationRecordModelSchema,
    MarkedVerseRecordModelSchema,
    HabitPlanModelSchema,
    DailyProgressModelSchema,
    ReviewTaskModelSchema,
    UserPreferenceModelSchema,
  ], directory: dir.path);

  // Seed initial data once before the UI starts
  final repo = QuranRepositoryImpl(
    quranDatasource: QuranLocalDatasource(isar),
    memorizationDatasource: MemorizationLocalDatasource(isar),
  );
  await SeedInitialDataUseCase(repo)();

  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        localNotificationServiceProvider.overrideWithValue(
          localNotificationService,
        ),
      ],
      child: const ZikrQApp(),
    ),
  );
}

class ZikrQApp extends StatelessWidget {
  const ZikrQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
