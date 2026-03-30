import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/providers/habit_provider.dart';
import 'package:zikrq/presentation/providers/review_queue_provider.dart';
import 'package:zikrq/presentation/providers/stats_provider.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';

import 'core_providers.dart';

class QuickActionOperationState {
  const QuickActionOperationState({required this.isLoading, this.error});

  final bool isLoading;
  final String? error;

  factory QuickActionOperationState.idle() =>
      const QuickActionOperationState(isLoading: false);

  QuickActionOperationState copyWith({
    bool? isLoading,
    Object? error = _unset,
  }) {
    return QuickActionOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

const _unset = Object();

final quickActionProvider =
    NotifierProvider<QuickActionNotifier, QuickActionOperationState>(
      QuickActionNotifier.new,
    );

class QuickActionNotifier extends Notifier<QuickActionOperationState> {
  @override
  QuickActionOperationState build() => QuickActionOperationState.idle();

  Future<void> updateSingle({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(quickUpdateSurahStatusUseCaseProvider);
      await useCase(surahId: surahId, status: status);
      _invalidateAfterSuccess();
      state = state.copyWith(isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> updateBulk({
    required List<int> surahIds,
    required MemorizationStatus status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(bulkUpdateSurahStatusUseCaseProvider);
      await useCase(surahIds: surahIds, status: status);
      _invalidateAfterSuccess();
      state = state.copyWith(isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  void _invalidateAfterSuccess() {
    ref.invalidate(surahListProvider);
    ref.invalidate(memorizationStatsProvider);
    ref.invalidate(todayDashboardProvider);
    ref.invalidate(reviewQueueProvider);
  }
}
