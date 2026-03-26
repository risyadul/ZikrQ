import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge shows correct label for memorized', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: MemorizationStatus.memorized)),
      ),
    );
    expect(find.text('Sudah Hafal'), findsOneWidget);
  });

  testWidgets('StatusBadge shows correct label for needsReview', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: MemorizationStatus.needsReview),
        ),
      ),
    );
    expect(find.text('Perlu Murojaah'), findsOneWidget);
  });
}
