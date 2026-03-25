import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zikrq/domain/repositories/quran_repository.dart';
import 'package:zikrq/domain/usecases/toggle_verse_mark.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late MockQuranRepository repo;
  late ToggleVerseMarkUseCase useCase;

  setUp(() {
    repo = MockQuranRepository();
    useCase = ToggleVerseMarkUseCase(repo);
  });

  test('delegates to repository with correct args', () async {
    when(() => repo.toggleVerseMark(1, 5)).thenAnswer((_) async {});
    await useCase(1, 5);
    verify(() => repo.toggleVerseMark(1, 5)).called(1);
  });
}
