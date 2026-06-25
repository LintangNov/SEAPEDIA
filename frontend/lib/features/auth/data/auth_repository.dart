import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/network/dio_provider.dart';
import 'package:seapedia/core/storage/secure_storage_provider.dart';
import 'package:seapedia/features/auth/data/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final dynamic _storage;

  AuthRepository({required Dio dio, required dynamic storage})
    : _dio = dio,
      _storage = storage;

  Future<void> register(
    String username,
    String password,
    List<String> roles,
  ) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'username': username, 'password': password, 'roles': roles},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      final data = LoginResponse.fromJson(response.data);
      await _storage.write(key: 'accessToken', value: data.accessToken);
      return data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<SelectRoleResponse> selectRole(String activeRole) async {
    try {
      final response = await _dio.post(
        '/auth/select-role',
        data: {'activeRole': activeRole},
      );

      final data = SelectRoleResponse.fromJson(response.data);
      await _storage.write(key: 'accessToken', value: data.accessToken);
      return data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to set active role',
      );
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return UserProfile.fromJson(response.data['profile']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
  }
}
