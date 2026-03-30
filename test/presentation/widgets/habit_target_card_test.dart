import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/presentation/widgets/habit_target_card.dart';
import 'package:zikrq/presentation/widgets/memorization_progress_bar.dart';

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

  testWidgets('HabitTargetCard invokes continue callback when tapped', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTargetCard(
            targetAyat: 10,
            completedAyat: 4,
            streakDays: 5,
            onContinueMurajaah: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lanjut Murajaah'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('HabitTargetCard normalizes non-positive target for display', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTargetCard(
            targetAyat: 0,
            completedAyat: 3,
            streakDays: 2,
            onContinueMurajaah: () {},
          ),
        ),
      ),
    );

    expect(find.text('3 / 1 ayat'), findsOneWidget);
    expect(find.textContaining('/ 0 ayat'), findsNothing);
  });

  testWidgets('HabitTargetCard bounds overflow progress to valid range', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitTargetCard(
            targetAyat: 10,
            completedAyat: 50,
            streakDays: 1,
            onContinueMurajaah: () {},
          ),
        ),
      ),
    );

    final progressBar = tester.widget<MemorizationProgressBar>(
      find.byType(MemorizationProgressBar),
    );

    expect(progressBar.value, inInclusiveRange(0.0, 1.0));
    expect(progressBar.value, 1.0);
  });
}
