// lib/presentation/providers/surah_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

// Active status filter (null = show all)
final surahStatusFilterProvider = StateProvider<MemorizationStatus?>(
  (ref) => null,
);

// Search query
final surahSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered + searched surah list
final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final filter = ref.watch(surahStatusFilterProvider);
  final query = ref.watch(surahSearchQueryProvider);
  final useCase = ref.watch(getAllSurahsUseCaseProvider);

  final surahs = await useCase(filter: filter);

  if (query.trim().isEmpty) return surahs;

  final lowerQuery = query.toLowerCase();
  return surahs
      .where((s) => s.name.toLowerCase().contains(lowerQuery))
      .toList();
});
