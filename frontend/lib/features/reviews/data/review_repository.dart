import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'review_models.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(dio: ref.watch(dioProvider));
});

class ReviewRepository {
  final Dio _dio;

  ReviewRepository({required Dio dio}) : _dio = dio;

  Future<List<Review>> getReviews() async {
    try {
      final response = await _dio.get('/reviews');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load reviews');
    }
  }

  Future<void> submitReview(
    String reviewerName,
    int rating,
    String comment,
  ) async {
    try {
      await _dio.post(
        '/reviews',
        data: {
          'reviewerName': reviewerName,
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit review');
    }
  }
}
