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
}
