import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/review_models.dart';
import '../data/review_repository.dart';

final reviewsListProvider = FutureProvider.autoDispose<List<Review>>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getReviews();
});