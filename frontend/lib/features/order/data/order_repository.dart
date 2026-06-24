import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(dio: ref.watch(dioProvider));
});

class OrderRepository {
  final Dio _dio;

  OrderRepository({required Dio dio}) : _dio = dio;

  Future<void> checkout(String deliveryMethod, String deliveryAddress) async {
    try {
      await _dio.post(
        '/order/checkout',
        data: {
          'deliveryMethod': deliveryMethod,
          'deliveryAddress': deliveryAddress,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Checkout failed");
    }
  }
}