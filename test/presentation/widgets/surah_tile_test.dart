import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/entities/surah.dart';
import 'package:zikrq/presentation/widgets/surah_tile.dart';

void main() {
  testWidgets('SurahTile renders surah name and verse count', (tester) async {
    const surah = Surah(
      id: 1,
      name: 'Al-Fatihah',
      nameArabic: 'الفاتحة',
      totalVerses: 7,
      juzStart: 1,
      revelation: 'Meccan',
      status: MemorizationStatus.notStarted,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurahTile(surah: surah, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('7 Ayat'), findsOneWidget);
  });
}
