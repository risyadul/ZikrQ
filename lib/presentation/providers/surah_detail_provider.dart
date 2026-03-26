// lib/presentation/providers/surah_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/verse_with_mark.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

// Provides List<VerseWithMark> for a given surahId
final surahDetailProvider = FutureProvider.family<List<VerseWithMark>, int>((
  ref,
  surahId,
) async {
  final getVerses = ref.watch(getVersesBySurahUseCaseProvider);
  // TODO(mvp): Replace with a use case that returns Set<int> of marked
  // verse numbers in a single query, to avoid N+1 isVerseMark calls
  // and keep the presentation layer decoupled from the repository.
  final repo = ref.watch(quranRepositoryProvider);

  final verses = await getVerses(surahId);
  final versesWithMark = await Future.wait(
    verses.map((v) async {
      final isMarked = await repo.isVerseMark(surahId, v.number);
      return VerseWithMark(verse: v, isMarked: isMarked);
    }),
  );
  return versesWithMark;
});
