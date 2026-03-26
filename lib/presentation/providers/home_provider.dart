// lib/presentation/providers/home_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

// Recently accessed surahs (last 3 with non-null lastAccessedAt)
final recentlyAccessedProvider = FutureProvider<List<Surah>>((ref) async {
  final memDs = ref.watch(memorizationLocalDatasourceProvider);
  final repo = ref.watch(quranRepositoryProvider);

  final recentRecords = await memDs.getRecentlyAccessed(3);
  if (recentRecords.isEmpty) return [];

  final allSurahs = await repo.getAllSurahs();
  final surahMap = {for (final s in allSurahs) s.id: s};
  return recentRecords
      .map((r) => surahMap[r.surahId])
      .whereType<Surah>()
      .toList();
});

// Surahs that need review (max 5)
final needsReviewProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final surahs = await repo.getAllSurahs(
    filter: MemorizationStatus.needsReview,
  );
  return surahs.take(5).toList();
});
