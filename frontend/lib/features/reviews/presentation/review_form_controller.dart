import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/reviews/data/review_repository.dart';
import 'package:seapedia/features/reviews/presentation/reviews_provider.dart';

class ReviewFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit(String reviewerName, int rating, String comment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reviewRepositoryProvider);
      await repository.submitReview(reviewerName, rating, comment);
      ref.invalidate(reviewsListProvider);
    });
  }
}

final reviewFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ReviewFormController, void>(
      ReviewFormController.new,
    );
