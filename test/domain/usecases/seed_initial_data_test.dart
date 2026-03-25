import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/seed_initial_data.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late SeedInitialDataUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = SeedInitialDataUseCase(repo);
  });

  test('delegates to repository seedIfEmpty', () async {
    when(() => repo.seedIfEmpty()).thenAnswer((_) async {});
    await useCase();
    verify(() => repo.seedIfEmpty()).called(1);
  });
}
