import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_stats.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/get_memorization_stats.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late GetMemorizationStatsUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = GetMemorizationStatsUseCase(repo);
  });

  test('returns stats from repository', () async {
    const expected = MemorizationStats(
      total: 114,
      notStarted: 110,
      inProgress: 2,
      memorized: 1,
      needsReview: 1,
      memorizedVerseCount: 7,
    );
    when(() => repo.getMemorizationStats()).thenAnswer((_) async => expected);
    final result = await useCase();
    expect(result, expected);
  });
}
