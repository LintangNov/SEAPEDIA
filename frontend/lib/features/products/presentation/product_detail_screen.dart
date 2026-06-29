import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/cart/presentation/cart_controller.dart';
import 'products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp${product.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Stock: ${product.stock} items available'),
                      const SizedBox(height: 16),
                      const Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(product.description),
                    ],
                  ),
                const SizedBox(height: 24),
                Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Add to Cart'),
                        onPressed: () async {
                          try {
                            await ref
                                .read(cartControllerProvider.notifier)
                                .addToCart(product.id, 1);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product added to cart'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            final errorMessage = e.toString().replaceAll('Exception: ', '').trim();

                            if (errorMessage.toLowerCase().contains(
                                  'single-store',
                                ) ||
                                errorMessage.toLowerCase().contains(
                                  'another store',
                                )) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  content: Text(
                                    'You can only buy products from one store at a time.\n\n'
                                    'Do you want to clear your current cart and add this product from ${product.storeName} instead?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .clearCart();
                                        await ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .addToCart(product.id, 1);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Cart cleared and new product added.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Clear & Add'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
