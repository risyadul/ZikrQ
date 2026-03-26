// lib/presentation/providers/stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

final memorizationStatsProvider = FutureProvider<MemorizationStats>((ref) {
  final useCase = ref.watch(getMemorizationStatsUseCaseProvider);
  return useCase();
});
