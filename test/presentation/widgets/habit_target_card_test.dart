import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/presentation/widgets/habit_target_card.dart';

void main() {
  testWidgets('HabitTargetCard shows target title and streak text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTargetCard(
            targetAyat: 10,
            completedAyat: 4,
            streakDays: 5,
            onContinueMurajaah: () {},
          ),
        ),
      ),
    );

    expect(find.text('Target Hari Ini'), findsOneWidget);
    expect(find.text('5 hari'), findsOneWidget);
    expect(find.text('Lanjut Murajaah'), findsOneWidget);
  });
}
