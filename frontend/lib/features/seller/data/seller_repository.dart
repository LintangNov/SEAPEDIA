import 'package:dio/dio.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  return SellerRepository(dio: ref.watch(dioProvider));
});

class SellerRepository {
  final Dio _dio;

  SellerRepository({required Dio dio}) : _dio = dio;

  Future<void> updateStoreProfile(String storeName) async {
    try {
      await _dio.patch(
        '/users/seller/store',
        data: {'storeName' : storeName},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update store profile');
    }
  }
}