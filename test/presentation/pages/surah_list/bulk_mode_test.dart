import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/usecases/bulk_update_surah_status.dart';
import 'package:zikrq/domain/usecases/quick_update_surah_status.dart';
import 'package:zikrq/presentation/pages/surah_list/surah_list_page.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/providers/surah_list_provider.dart';

class _MockBulkUpdateSurahStatusUseCase extends Mock
    implements BulkUpdateSurahStatusUseCase {}

class _MockQuickUpdateSurahStatusUseCase extends Mock
    implements QuickUpdateSurahStatusUseCase {}

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
}
