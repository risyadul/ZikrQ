import 'package:meta/meta.dart';

@immutable
class MemorizationStats {
  const MemorizationStats({
    required this.memorized,
    required this.inProgress,
    required this.needsReview,
    required this.notStarted,
    required this.total,
    required this.memorizedVerseCount,
  });

  final int memorized;
  final int inProgress;
  final int needsReview;
  final int notStarted;
  final int total;
  final int memorizedVerseCount;

  double get memorizedPercent => total == 0 ? 0 : memorized / total;

  @override
  bool operator ==(Object other) =>
      other is MemorizationStats &&
      other.memorized == memorized &&
      other.inProgress == inProgress &&
      other.needsReview == needsReview &&
      other.notStarted == notStarted &&
      other.total == total &&
      other.memorizedVerseCount == memorizedVerseCount;

  @override
  int get hashCode => Object.hash(
    memorized,
    inProgress,
    needsReview,
    notStarted,
    total,
    memorizedVerseCount,
  );
}
