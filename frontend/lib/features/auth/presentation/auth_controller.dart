import 'package:flutter/material.dart';
import 'package:seapedia/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState { guest, partial, authenticated }

class AuthController extends Notifier<AuthState> {
  List<String> availableRoles = [];

  @override
  AuthState build() {
    return AuthState.guest;
  }

  Future<void> register(
    String username,
    String password,
    List<String> roles,
  ) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.register(username, password, roles);
  }

  Future<void> login(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final response = await repository.login(username, password);
    availableRoles = response.availableRoles;

    state = AuthState.partial;
  }

  Future<void> selectRole(String activeRole) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.selectRole(activeRole);
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    state = AuthState.guest;
    availableRoles.clear();

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
    } catch (e) {
      debugPrint('Secure Storage Logout Error: $e');
    } finally {
      availableRoles.clear();
      state = AuthState.guest;
    }
  }

  void checkStatus(bool hasToken) {
    if (hasToken) {
      state = AuthState.authenticated;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
