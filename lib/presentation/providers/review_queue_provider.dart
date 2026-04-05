import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikrq/domain/entities/review_task.dart';
import 'package:zikrq/presentation/providers/core_providers.dart';

final reviewQueueProvider = FutureProvider<List<ReviewTask>>((ref) {
  final useCase = ref.watch(generateTodayReviewQueueUseCaseProvider);
  return useCase();
});
