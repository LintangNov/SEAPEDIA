import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';

final buyerRepositoryProvider = Provider<BuyerRepository>((ref) {
  return BuyerRepository(dio: ref.watch(dioProvider));
});

class BuyerRepository {
  final Dio _dio;

  BuyerRepository({required Dio dio}): _dio = dio;

  Future<double> getWalletBalance() async {
    try {
      final response = await _dio.get('users/me');

      return double.tryParse(response.data['profile']?['walletBalance']?.toString() ?? '0') ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> topUp(double amount) async {
    try {
      final response = await _dio.post(
        '/buyer/topup',
        data: {'amount': amount},
      );
      return double.tryParse(response.data['balance']?.toString() ?? '0') ?? 0.0;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to top up wallet');
    }
  }
}