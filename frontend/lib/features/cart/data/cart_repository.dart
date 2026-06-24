import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:seapedia/features/cart/data/cart_models.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(dio: ref.watch(dioProvider));
});

class CartRepository {
  final Dio _dio;

  CartRepository({required Dio dio}) : _dio = dio;

  Future<CartSummary?> getCart() async {
    try {
      final response = await _dio.get('/cart');
      if (response.data['data'] == null) return null;
      return CartSummary.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch cart');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await _dio.post('/cart/items', data: {
        'productId': productId,
        'quantity': quantity
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add to cart');
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _dio.patch('/cart/items/$cartItemId', data: {'quantity': quantity});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update quantity');
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    try {
      await _dio.delete('/cart/items/$cartItemId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed ro remove item');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to clear cart');
    }
  }
}