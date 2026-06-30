import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/cart/presentation/cart_controller.dart';
import 'package:seapedia/core/widgets/seapedia_error_widget.dart';
import 'products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedThumbnailIndex = 0;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SeapediaErrorWidget(
          error: error,
          onRetry: () => ref.refresh(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          final thumbnails = [
            'https://dummyjson.com/image/600x600/f4f7fa/2d3748?text=${Uri.encodeComponent(product.name)}',
            'https://dummyjson.com/image/600x600/e2e8f0/1a202c?text=Side%20View',
            'https://dummyjson.com/image/600x600/edf2f7/4a5568?text=Back%20View',
            'https://dummyjson.com/image/600x600/f7fafc/718096?text=Sole%20View',
          ];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surface : Colors.grey[100],
                        ),
                        child: Image.network(
                          thumbnails[_selectedThumbnailIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) => const Center(
                            child: Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: thumbnails.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedThumbnailIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedThumbnailIndex = index;
                                });
                              },
                              child: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(thumbnails[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Rp ${product.price}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(20),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.store_outlined, size: 14, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.storeName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(20),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stock: ${product.stock}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isAddingToCart
                          ? null
                          : () async {
                              setState(() {
                                _isAddingToCart = true;
                              });
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

                                if (errorMessage.toLowerCase().contains('single-store') ||
                                    errorMessage.toLowerCase().contains('another store')) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Clear Cart?'),
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
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            setState(() {
                                              _isAddingToCart = true;
                                            });
                                            try {
                                              await ref
                                                  .read(cartControllerProvider.notifier)
                                                  .clearCart();
                                              await ref
                                                  .read(cartControllerProvider.notifier)
                                                  .addToCart(product.id, 1);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Cart cleared and new product added.'),
                                                  ),
                                                );
                                              }
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isAddingToCart = false;
                                                });
                                              }
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
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isAddingToCart = false;
                                  });
                                }
                              }
                            },
                      child: _isAddingToCart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined),
                                SizedBox(width: 8),
                                Text('Add to Cart'),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
