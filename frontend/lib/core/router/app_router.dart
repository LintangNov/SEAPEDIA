import 'package:seapedia/features/products/presentation/product_form_screen.dart';
import 'package:seapedia/features/reviews/presentation/reviews_screen.dart';
import 'package:seapedia/features/seller/presentation/seller_dashboard_screen.dart';
import 'package:seapedia/features/seller/presentation/store_profile_screen.dart';
import '../../features/products/presentation/product_catalog_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/auth/presentation/login_screen.dart';
import 'package:seapedia/features/auth/presentation/profile_screen.dart';
import 'package:seapedia/features/auth/presentation/register_screen.dart';
import 'package:seapedia/features/auth/presentation/select_role_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
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
        path: '/select-role',
        builder: (context, state) => const SelectRoleScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductCatalogScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetailScreen(productId: productId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const ReviewsScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/seller/dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/seller/store-profile',
        builder: (context, state) => const StoreProfileScreen(),
      ),
      GoRoute(
        path: '/seller/products/new',
        builder: (context, state) => const ProductFormScreen(),
      ),
    ],
  );

  ref.listen(authControllerProvider, (previous, next){
    router.refresh();
  });

  return router;
});
