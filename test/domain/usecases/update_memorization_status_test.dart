import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/entities/memorization_status.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/update_memorization_status.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late UpdateMemorizationStatusUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = UpdateMemorizationStatusUseCase(repo);
  });

  test('delegates to repository with correct args', () async {
    when(
      () => repo.updateMemorizationStatus(1, MemorizationStatus.memorized),
    ).thenAnswer((_) async {});
    await useCase(1, MemorizationStatus.memorized);
    verify(
      () => repo.updateMemorizationStatus(1, MemorizationStatus.memorized),
    ).called(1);
  });
}
