import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/presentation/pages/settings/settings_page.dart';
import 'package:zikrq/presentation/providers/habit_provider.dart';

void main() {
  testWidgets('SettingsPage shows personalization labels', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsFormStateProvider.overrideWith(
            (_) async => const SettingsFormState(
              dailyTargetAyat: 5,
              activeDays: {1, 2, 3, 4, 5, 6, 7},
              reminderEnabled: true,
              reminderHour: 5,
              reminderMinute: 0,
              snoozeMinutes: 10,
              defaultQuickAction: MemorizationStatus.inProgress,
              hapticEnabled: true,
            ),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Target Ayat Harian'), findsOneWidget);
    expect(find.text('Pengingat Harian'), findsOneWidget);
    expect(find.text('Durasi Snooze (menit)'), findsOneWidget);
    expect(find.text('Aksi Cepat Default'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Haptic Feedback'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Haptic Feedback'), findsOneWidget);
  });
}
