import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:seapedia/features/order/data/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(dio: ref.watch(dioProvider));
});

class OrderRepository {
  final Dio _dio;

  OrderRepository({required Dio dio}) : _dio = dio;

  Future<void> checkout(
    String deliveryMethod,
    String deliveryAddress,
    String? discountCode,
  ) async {
    try {
      await _dio.post(
        '/order/checkout',
        data: {
          'deliveryMethod': deliveryMethod,
          'deliveryAddress': deliveryAddress,
          if (discountCode != null && discountCode.isNotEmpty)
            'discountCode': discountCode,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Checkout failed");
    }
  }

  Future<List<Discount>> getActiveDiscounts() async {
    try {
      final response = await _dio.get('/discounts');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((e) => Discount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<OrderModel>> getBuyerHistory() async {
    try {
      final response = await _dio.get('/order/buyer/history');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load order history',
      );
    }
  }

  Future<List<OrderModel>> getSellerIncoming() async {
    try {
      final response = await _dio.get('/order/seller/incoming');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load incoming orders',
      );
    }
  }

  Future<void> processOrder(String orderId) async {
    try {
      await _dio.patch('/order/seller/$orderId/process');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to process order');
    }
  }
}
