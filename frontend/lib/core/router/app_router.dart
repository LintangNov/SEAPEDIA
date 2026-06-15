import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/auth/presentation/login_screen.dart';
import 'package:seapedia/features/auth/presentation/register_screen.dart';
import 'package:seapedia/features/auth/presentation/select_role_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/products',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      final isGoingToLogin = state.uri.toString() == '/login';
      final isGoingToRegister = state.uri.toString() == '/register';
      final isGoingToSelectRole = state.uri.toString() == '/select-role';

      final isGoingToPublicRoute =
          state.uri.toString().startsWith('/products') ||
          state.uri.toString().startsWith('/reviews');

      if (authState == AuthState.guest) {
        if (!isGoingToLogin && !isGoingToRegister && !isGoingToPublicRoute) {
          return '/login';
        }
      } else if (authState == AuthState.partial) {
        if (!isGoingToSelectRole) {
          return '/select-role';
        }
      } else if (authState == AuthState.authenticated) {
        if (isGoingToLogin || isGoingToRegister || isGoingToSelectRole) {
          return '/profile';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Register Screen'))),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const SelectRoleScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile Screen'))),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Product Catalog (Public)')),
        ),
      ),
      GoRoute(
        path: '/reviews',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('App Reviews (Public)'))),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
