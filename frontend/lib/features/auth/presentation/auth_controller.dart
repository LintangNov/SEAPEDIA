import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seapedia/core/storage/secure_storage_provider.dart';
import 'package:seapedia/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState { guest, partial, authenticated }

class ActiveRoleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setRole(String? role) {
    state = role;
  }
}

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, String?>(() {
  return ActiveRoleNotifier();
});

String? decodeActiveRole(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final data = json.decode(resp);
    return data['activeRole']?.toString();
  } catch (_) {
    return null;
  }
}

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
    await login(username, password);
  }

  Future<void> login(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final response = await repository.login(username, password);
    availableRoles = response.availableRoles;

    if (availableRoles.length == 1) {
      await selectRole(availableRoles[0]);
    } else {
      state = AuthState.partial;
    }
  }

  Future<void> selectRole(String activeRole) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.selectRole(activeRole);
    ref.read(activeRoleProvider.notifier).setRole(activeRole);
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    state = AuthState.guest;
    availableRoles.clear();
    ref.read(activeRoleProvider.notifier).setRole(null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
    } catch (e) {
      debugPrint('Secure Storage Logout Error: $e');
    } finally {
      await ref.read(secureStorageProvider).delete(key: 'jwt');
      availableRoles.clear();
      state = AuthState.guest;
      ref.read(activeRoleProvider.notifier).setRole(null);
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
