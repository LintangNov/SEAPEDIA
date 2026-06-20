import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/products/data/product_repository.dart';
import '../../../core/widgets/debug_border.dart';
import '../../products/presentation/products_provider.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(sellerProductsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Profile',
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            tooltip: 'Go to Public Catalog',
            onPressed: () => context.push('/products'),
          ),
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'Edit Store Profile',
            onPressed: () => context.push('/seller/store-profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/seller/products/new'),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              const Text('Did you set up your Store Profile first?'),
              ElevatedButton(
                onPressed: () => ref.refresh(sellerProductsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('You have no products. Add one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return DebugBorder(
                color: Colors.teal,
                label: 'Seller Product Item',
                child: ListTile(
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Stock: ${product.stock} | Price: Rp${product.price}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push('/seller/products/new', extra: product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            try {
                              await ref.read(productRepositoryProvider).deleteProduct(product.id);
                              ref.invalidate(sellerProductsProvider);
                              ref.invalidate(productsListProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
