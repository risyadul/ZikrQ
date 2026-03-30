import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quick_action_repository.dart';
import 'package:zikrq/domain/usecases/bulk_update_surah_status.dart';

class MockQuickActionRepository extends Mock implements QuickActionRepository {}

void main() {
  late MockQuickActionRepository repository;
  late BulkUpdateSurahStatusUseCase useCase;

  setUp(() {
    repository = MockQuickActionRepository();
    useCase = BulkUpdateSurahStatusUseCase(repository);
    registerFallbackValue(MemorizationStatus.notStarted);
  });

  test('delegates ids and status to repository', () async {
    const surahIds = [2, 18, 36];
    const status = MemorizationStatus.needsReview;

    when(
      () => repository.applyStatusToSurahs(surahIds: surahIds, status: status),
    ).thenAnswer((_) async {});
    when(
      () => repository.setLastUsedStatusAction(status),
    ).thenAnswer((_) async {});

    await useCase(surahIds: surahIds, status: status);

    verify(
      () => repository.applyStatusToSurahs(surahIds: surahIds, status: status),
    ).called(1);
    verify(() => repository.setLastUsedStatusAction(status)).called(1);
  });
}
