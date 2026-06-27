import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:seapedia/features/driver/data/driver_models.dart';
import 'package:seapedia/features/order/data/order_models.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref){
  return DriverRepository(dio: ref.watch(dioProvider));
});

class DriverRepository {
  final Dio _dio;
  DriverRepository({required Dio dio}) : _dio = dio;

  Future<DriverProfileData> getProfile() async {
    try {
      final response = await _dio.get('driver/me');
      return DriverProfileData.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load driver profile');
    }
  }

  Future<List<OrderModel>> getAvailableJobs() async {
    try {
      final response = await _dio.get('/driver/jobs/available');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load jobs');
    }
  }

  Future<void> takeJob(String orderId) async {
    try {
      await _dio.post('/driver/jobs/$orderId/take');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to take job');
    }
  }

  Future<void> completeJob(String orderId) async {
    try {
      await _dio.post('/driver/jobs/$orderId/complete');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to complete job');
    }
  }

  Future<List<OrderModel>> getHistory() async {
    try {
      final response = await _dio.get('/driver/jobs/history');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((job) => OrderModel.fromJson(job['order'])).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load history');
    }
  }
}