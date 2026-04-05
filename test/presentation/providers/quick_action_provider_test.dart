import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';
import 'package:zikrq/domain/usecases/bulk_update_surah_status.dart';
import 'package:zikrq/domain/usecases/quick_update_surah_status.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/quick_action_provider.dart';

class MockBulkUpdateSurahStatusUseCase extends Mock
    implements BulkUpdateSurahStatusUseCase {}

class MockQuickUpdateSurahStatusUseCase extends Mock
    implements QuickUpdateSurahStatusUseCase {}

class _SerialTrackingQuickActionRepository implements QuickActionRepository {
  int _inFlight = 0;
  int maxConcurrent = 0;
  final List<int> callOrder = [];

  @override
  Future<MemorizationStatus?> getLastUsedStatusAction() async => null;

  @override
  Future<void> setLastUsedStatusAction(MemorizationStatus status) async {}

  @override
  Future<void> applyStatusToSurah({
    required int surahId,
    required MemorizationStatus status,
  }) async {
    _inFlight += 1;
    if (_inFlight > maxConcurrent) {
      maxConcurrent = _inFlight;
    }

    await Future<void>.delayed(const Duration(milliseconds: 20));
    callOrder.add(surahId);
    _inFlight -= 1;
  }

  @override
  Future<void> applyStatusToSurahs({
    required List<int> surahIds,
    required MemorizationStatus status,
  }) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(MemorizationStatus.notStarted);
  });

  test('quick updates are serialized under rapid repeated calls', () async {
    final trackingRepository = _SerialTrackingQuickActionRepository();
    final quickUpdateUseCase = QuickUpdateSurahStatusUseCase(
      trackingRepository,
    );
    final bulkUpdateUseCase = MockBulkUpdateSurahStatusUseCase();

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
          quickUpdateUseCase,
        ),
        bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
          bulkUpdateUseCase,
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quickActionProvider.notifier);
    final f1 = notifier.updateSingle(
      surahId: 2,
      status: MemorizationStatus.inProgress,
    );
    final f2 = notifier.updateSingle(
      surahId: 18,
      status: MemorizationStatus.memorized,
    );

    await Future.wait([f1, f2]);

    expect(trackingRepository.maxConcurrent, 1);
    expect(trackingRepository.callOrder, [2, 18]);
  });

  test('quickActionProvider emits loading then success state', () async {
    final trackingRepository = _SerialTrackingQuickActionRepository();
    final quickUpdateUseCase = QuickUpdateSurahStatusUseCase(
      trackingRepository,
    );
    final bulkUpdateUseCase = MockBulkUpdateSurahStatusUseCase();

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
          quickUpdateUseCase,
        ),
        bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
          bulkUpdateUseCase,
        ),
      ],
    );
    addTearDown(container.dispose);

    final states = <QuickActionOperationState>[];
    final subscription = container.listen<QuickActionOperationState>(
      quickActionProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container
        .read(quickActionProvider.notifier)
        .updateSingle(surahId: 5, status: MemorizationStatus.needsReview);

    expect(states.first.isLoading, false);
    expect(states.any((state) => state.isLoading), isTrue);
    expect(states.last.isLoading, false);
    expect(states.last.error, isNull);
  });

  test('keeps loading true until all in-flight operations complete', () async {
    final quickUpdateUseCase = MockQuickUpdateSurahStatusUseCase();
    final bulkUpdateUseCase = MockBulkUpdateSurahStatusUseCase();
    final singleCompleter = Completer<void>();
    final bulkCompleter = Completer<void>();

    when(
      () => quickUpdateUseCase.call(
        surahId: any(named: 'surahId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => singleCompleter.future);

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => bulkCompleter.future);

    final container = ProviderContainer(
      overrides: [
        quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
          quickUpdateUseCase,
        ),
        bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
          bulkUpdateUseCase,
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quickActionProvider.notifier);
    final single = notifier.updateSingle(
      surahId: 5,
      status: MemorizationStatus.needsReview,
    );
    final bulk = notifier.updateBulk(
      surahIds: const [2, 3],
      status: MemorizationStatus.inProgress,
    );

    await Future<void>.delayed(Duration.zero);
    expect(container.read(quickActionProvider).isLoading, isTrue);

    singleCompleter.complete();
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(quickActionProvider).isLoading,
      isTrue,
      reason: 'bulk update is still in-flight',
    );

    bulkCompleter.complete();
    await Future.wait([single, bulk]);

    final finalState = container.read(quickActionProvider);
    expect(finalState.isLoading, isFalse);
    expect(finalState.error, isNull);
  });
}
