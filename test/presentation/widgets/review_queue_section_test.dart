import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/presentation/widgets/review_queue_section.dart';

void main() {
  final now = DateTime(2026, 3, 30);

  ReviewTask task({required String id, required int surahId}) {
    return ReviewTask(
      id: id,
      surahId: surahId,
      source: ReviewTaskSource.needsReview,
      scheduledDate: now,
      priorityScore: 10,
      updatedAt: now,
      localChangeVersion: 1,
    );
  }

  testWidgets('ReviewQueueSection renders queue items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewQueueSection(
            queue: [
              task(id: 'a', surahId: 2),
              task(id: 'b', surahId: 18),
            ],
            onQuickActionPressed: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Antrean Murajaah'), findsOneWidget);
    expect(find.text('Surah 2'), findsOneWidget);
    expect(find.text('Surah 18'), findsOneWidget);
  });

  testWidgets('ReviewQueueSection exposes quick action callback per item', (
    tester,
  ) async {
    ReviewTask? tapped;
    final queueItem = task(id: 'q1', surahId: 36);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewQueueSection(
            queue: [queueItem],
            onQuickActionPressed: (task) => tapped = task,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('review-quick-action-q1')));
    await tester.pump();

    expect(tapped, queueItem);
  });

  testWidgets('ReviewQueueSection disables quick action when disabled', (
    tester,
  ) async {
    ReviewTask? tapped;
    final queueItem = task(id: 'q-disabled', surahId: 55);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewQueueSection(
            queue: [queueItem],
            isActionEnabled: false,
            onQuickActionPressed: (task) => tapped = task,
          ),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('review-quick-action-q-disabled')),
    );

    expect(button.onPressed, isNull);

    await tester.tap(
      find.byKey(const ValueKey('review-quick-action-q-disabled')),
    );
    await tester.pump();

    expect(tapped, isNull);
  });

  testWidgets('ReviewQueueSection returns empty widget when queue is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewQueueSection(
            queue: const [],
            onQuickActionPressed: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Antrean Murajaah'), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('ReviewQueueSection adapts action button on narrow width', (
    tester,
  ) async {
    final queueItem = task(id: 'q-narrow', surahId: 99);

    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: ReviewQueueSection(
              queue: [queueItem],
              onQuickActionPressed: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('review-quick-action-q-narrow')),
      findsOneWidget,
    );
  });
}
