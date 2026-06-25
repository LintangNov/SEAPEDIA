import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'product_models.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(dio: ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;

  ProductRepository({required Dio dio}) : _dio = dio;

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch product catalog',
      );
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load product detail',
      );
    }
  }

  Future<List<Product>> getSellerProducts() async {
    try {
      final response = await _dio.get('/products/seller/mine');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch seller products',
      );
    }
  }

  Future<void> createProduct(Map<String, dynamic> dto) async {
    try {
      await _dio.post('/products', data: dto);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create product',
      );
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> dto) async {
    try {
      await _dio.patch('/products/$id', data: dto);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update product',
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete product',
      );
    }
  }
}
