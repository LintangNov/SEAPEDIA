import 'package:flutter/material.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/auth/presentation/auth_controller.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';
import 'products_provider.dart';

class ProductCatalogScreen extends ConsumerWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final isGuest = authState != AuthState.authenticated;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/products'),
      appBar: AppBar(
        title: const Text('Public Catalog'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.rate_review),
            tooltip: 'Application Reviews',
            onPressed: () => context.push('/reviews'),
          ),
          if (isGuest)
            IconButton(
              icon: const Icon(Icons.login_outlined),
              tooltip: 'Login',
              onPressed: () => context.go('/login'),
            ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => ref.refresh(productsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Store: ${product.storeName}\nPrice: Rp${product.price}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.push('/products/${product.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
