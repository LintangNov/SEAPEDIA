import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/auth/presentation/auth_controller.dart';
import '../../../core/widgets/debug_border.dart';
import 'products_provider.dart';

final cartVisibilityProvider = Provider.autoDispose<bool>((ref) {
  final authState = ref.watch(authControllerProvider);

  if (authState != AuthState.authenticated) {
    return false;
  }

  return ref.watch(activeRoleProvider) == 'BUYER';
});

class ProductCatalogScreen extends ConsumerWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCart = ref.watch(cartVisibilityProvider);
    final productsAsync = ref.watch(productsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Catalog'),
        actions: [
          if (showCart)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Open Shopping Cart',
              onPressed: () => context.push('/cart'),
            ),

          IconButton(
            icon: const Icon(Icons.rate_review),
            tooltip: 'Application Reviews',
            onPressed: () => context.push('/reviews'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final authState = ref.read(authControllerProvider);
              if (authState == AuthState.authenticated) {
                context.go('/profile');
              } else if (authState == AuthState.partial) {
                context.go('/select-role');
              } else {
                context.go('/login');
              }
            },
            tooltip: 'Profile / Login',
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
              return DebugBorder(
                color: Colors.blue,
                label: 'Product Item Card',
                child: ListTile(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
