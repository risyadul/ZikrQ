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
  int _inFlightOperations = 0;

  @override
  QuickActionOperationState build() => QuickActionOperationState.idle();

  Future<void> updateSingle({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    _beginOperation();
    try {
      final useCase = ref.read(quickUpdateSurahStatusUseCaseProvider);
      await useCase(surahId: surahId, status: status);
      _invalidateAfterSuccess();
      _endOperation();
    } catch (error) {
      _endOperation(error: error.toString());
    }
  }

  Future<void> updateBulk({
    required List<int> surahIds,
    required MemorizationStatus status,
  }) async {
    _beginOperation();
    try {
      final useCase = ref.read(bulkUpdateSurahStatusUseCaseProvider);
      await useCase(surahIds: surahIds, status: status);
      _invalidateAfterSuccess();
      _endOperation();
    } catch (error) {
      _endOperation(error: error.toString());
    }
  }

  void _beginOperation() {
    _inFlightOperations += 1;
    state = state.copyWith(isLoading: true, error: null);
  }

  void _endOperation({String? error}) {
    if (_inFlightOperations > 0) {
      _inFlightOperations -= 1;
    }

    state = state.copyWith(isLoading: _inFlightOperations > 0, error: error);
  }

  void _invalidateAfterSuccess() {
    ref.invalidate(surahListProvider);
    ref.invalidate(memorizationStatsProvider);
    ref.invalidate(todayDashboardProvider);
    ref.invalidate(reviewQueueProvider);
  }
}
