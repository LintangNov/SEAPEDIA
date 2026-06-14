import 'package:seapedia/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState { guest, partial, authenticated }

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.guest;
  }

  Future<void> login(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.login(username, password);
    state = AuthState.partial;
  }

  Future<void> selectRole(String activeRole) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.selectRole(activeRole);
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = AuthState.guest;
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
