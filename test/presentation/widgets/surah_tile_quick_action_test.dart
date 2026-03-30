import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

class _FakeQuickActionRepository implements QuickActionRepository {
  _FakeQuickActionRepository({this.lastUsedStatus});

  MemorizationStatus? lastUsedStatus;

  @override
  Future<MemorizationStatus?> getLastUsedStatusAction() async => lastUsedStatus;

  @override
  Future<void> setLastUsedStatusAction(MemorizationStatus status) async {
    lastUsedStatus = status;
  }

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
  const surah = Surah(
    id: 1,
    name: 'Al-Fatihah',
    nameArabic: 'الفاتحة',
    totalVerses: 7,
    juzStart: 1,
    revelation: 'Meccan',
    status: MemorizationStatus.notStarted,
  );

  testWidgets('long press opens quick status action sheet', (tester) async {
    final fakeRepository = _FakeQuickActionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quickActionRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SurahTile(surah: surah, onTap: () {}),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();

    expect(find.text('Not Started'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Memorized'), findsOneWidget);
    expect(find.text('Needs Review'), findsOneWidget);
  });

  testWidgets(
    'existing status bottom sheet path remains available on normal tap',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SurahTile(
              surah: surah,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Al-Fatihah'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    },
  );

  testWidgets('quick action sheet highlights last-used status first', (
    tester,
  ) async {
    final fakeRepository = _FakeQuickActionRepository(
      lastUsedStatus: MemorizationStatus.memorized,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quickActionRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SurahTile(surah: surah, onTap: () {}),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();

    final actionTiles = tester.widgetList<ListTile>(find.byType(ListTile));
    final firstTitle = actionTiles.first.title! as Text;

    expect(firstTitle.data, 'Memorized');
    expect(find.byKey(const Key('quick-status-memorized')), findsOneWidget);
  });
}
