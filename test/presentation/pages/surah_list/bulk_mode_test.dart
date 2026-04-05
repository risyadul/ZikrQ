import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';
import 'package:zikrq/domain/usecases/bulk_update_surah_status.dart';
import 'package:zikrq/domain/usecases/quick_update_surah_status.dart';
import 'package:zikrq/presentation/pages/surah_list/surah_list_page.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';
import 'package:zikrq/presentation/widgets/quick_status_action_sheet.dart';

class _MockBulkUpdateSurahStatusUseCase extends Mock
    implements BulkUpdateSurahStatusUseCase {}

class _MockQuickUpdateSurahStatusUseCase extends Mock
    implements QuickUpdateSurahStatusUseCase {}

class _FakeQuickActionRepository implements QuickActionRepository {
  @override
  Future<MemorizationStatus?> getLastUsedStatusAction() async =>
      MemorizationStatus.notStarted;

  @override
  Future<void> setLastUsedStatusAction(MemorizationStatus status) async {}

  @override
  Future<void> applyStatusToSurah({
    required int surahId,
    required MemorizationStatus status,
  }) async {}

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

  testWidgets('bulk mode apply memorized status to selected surahs', (
    tester,
  ) async {
    final bulkUpdateUseCase = _MockBulkUpdateSurahStatusUseCase();
    final quickUpdateUseCase = _MockQuickUpdateSurahStatusUseCase();

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => quickUpdateUseCase.call(
        surahId: any(named: 'surahId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    final surahs = [
      const Surah(
        id: 1,
        name: 'Al-Fatihah',
        nameArabic: 'الفاتحة',
        totalVerses: 7,
        juzStart: 1,
        revelation: 'Meccan',
        status: MemorizationStatus.notStarted,
      ),
      const Surah(
        id: 2,
        name: 'Al-Baqarah',
        nameArabic: 'البقرة',
        totalVerses: 286,
        juzStart: 1,
        revelation: 'Medinan',
        status: MemorizationStatus.inProgress,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => surahs),
          quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
            quickUpdateUseCase,
          ),
          bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
            bulkUpdateUseCase,
          ),
        ],
        child: const MaterialApp(home: SurahListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toggle-bulk-mode')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('surah-select-1')));
    await tester.tap(find.byKey(const Key('surah-select-2')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bulk-action-memorized')));
    await tester.pumpAndSettle();

    verify(
      () => bulkUpdateUseCase.call(
        surahIds: [1, 2],
        status: MemorizationStatus.memorized,
      ),
    ).called(1);
  });

  testWidgets('bulk action is disabled while quick action is loading', (
    tester,
  ) async {
    final bulkUpdateUseCase = _MockBulkUpdateSurahStatusUseCase();
    final quickUpdateUseCase = _MockQuickUpdateSurahStatusUseCase();
    final completer = Completer<void>();

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => completer.future);

    when(
      () => quickUpdateUseCase.call(
        surahId: any(named: 'surahId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    final surahs = [
      const Surah(
        id: 1,
        name: 'Al-Fatihah',
        nameArabic: 'الفاتحة',
        totalVerses: 7,
        juzStart: 1,
        revelation: 'Meccan',
        status: MemorizationStatus.notStarted,
      ),
      const Surah(
        id: 2,
        name: 'Al-Baqarah',
        nameArabic: 'البقرة',
        totalVerses: 286,
        juzStart: 1,
        revelation: 'Medinan',
        status: MemorizationStatus.inProgress,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => surahs),
          quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
            quickUpdateUseCase,
          ),
          bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
            bulkUpdateUseCase,
          ),
        ],
        child: const MaterialApp(home: SurahListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toggle-bulk-mode')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('surah-select-1')));
    await tester.tap(find.byKey(const Key('surah-select-2')));
    await tester.pumpAndSettle();

    final actionButton = find.byKey(const Key('bulk-action-memorized'));
    await tester.tap(actionButton);
    await tester.pump();

    final disabledButton = tester.widget<FilledButton>(actionButton);
    expect(disabledButton.onPressed, isNull);

    await tester.tap(actionButton);
    await tester.pump();

    verify(
      () => bulkUpdateUseCase.call(
        surahIds: [1, 2],
        status: MemorizationStatus.memorized,
      ),
    ).called(1);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('long press opens quick action sheet outside bulk mode', (
    tester,
  ) async {
    final bulkUpdateUseCase = _MockBulkUpdateSurahStatusUseCase();
    final quickUpdateUseCase = _MockQuickUpdateSurahStatusUseCase();
    final fakeRepository = _FakeQuickActionRepository();

    when(
      () => bulkUpdateUseCase.call(
        surahIds: any(named: 'surahIds'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => quickUpdateUseCase.call(
        surahId: any(named: 'surahId'),
        status: any(named: 'status'),
      ),
    ).thenThrow(Exception('Update failed'));

    final surahs = [
      const Surah(
        id: 1,
        name: 'Al-Fatihah',
        nameArabic: 'الفاتحة',
        totalVerses: 7,
        juzStart: 1,
        revelation: 'Meccan',
        status: MemorizationStatus.notStarted,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahListProvider.overrideWith((_) async => surahs),
          quickActionRepositoryProvider.overrideWithValue(fakeRepository),
          quickUpdateSurahStatusUseCaseProvider.overrideWithValue(
            quickUpdateUseCase,
          ),
          bulkUpdateSurahStatusUseCaseProvider.overrideWithValue(
            bulkUpdateUseCase,
          ),
        ],
        child: const MaterialApp(home: SurahListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();

    expect(find.byType(QuickStatusActionSheet), findsOneWidget);
  });
}
