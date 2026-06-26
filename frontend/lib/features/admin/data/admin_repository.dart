import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:seapedia/features/order/data/order_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(dio: ref.watch(dioProvider));
});

class AdminRepository {
  final Dio _dio;
  AdminRepository({required Dio dio}) : _dio = dio;

  Future<void> createDiscount(String code, String type, double amount, DateTime expiryDate, int? remainingUsage) async{
    try {
      await _dio.post('/dicounts', data: {
        'code': code,
        'type': type,
        'amount': amount,
        'expiryDate': expiryDate.toIso8601String(),
        if (type == 'VOUCHER' && remainingUsage != null) 'remainingUsage':remainingUsage,

      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create discount");
    }
  }

  Future<List<Discount>> getDiscounts() async {
    try {
      final response = await _dio.get('/discounts');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load discounts');
    }
  }
}