import 'package:meta/meta.dart';

@immutable
class DailyProgress {
  const DailyProgress({
    required this.date,
    required this.completedAyat,
    required this.targetAyat,
    required this.goalMet,
    required this.updatedAt,
    required this.localChangeVersion,
  });

  final DateTime date;
  final int completedAyat;
  final int targetAyat;
  final bool goalMet;
  final DateTime updatedAt;
  final int localChangeVersion;

  DailyProgress copyWith({
    DateTime? date,
    int? completedAyat,
    int? targetAyat,
    bool? goalMet,
    DateTime? updatedAt,
    int? localChangeVersion,
  }) => DailyProgress(
    date: date ?? this.date,
    completedAyat: completedAyat ?? this.completedAyat,
    targetAyat: targetAyat ?? this.targetAyat,
    goalMet: goalMet ?? this.goalMet,
    updatedAt: updatedAt ?? this.updatedAt,
    localChangeVersion: localChangeVersion ?? this.localChangeVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is DailyProgress &&
      other.date == date &&
      other.completedAyat == completedAyat &&
      other.targetAyat == targetAyat &&
      other.goalMet == goalMet &&
      other.updatedAt == updatedAt &&
      other.localChangeVersion == localChangeVersion;

  @override
  int get hashCode => Object.hash(
    date,
    completedAyat,
    targetAyat,
    goalMet,
    updatedAt,
    localChangeVersion,
  );
}
