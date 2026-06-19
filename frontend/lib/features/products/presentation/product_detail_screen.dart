import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/debug_border.dart';
import 'products_provider.dart';

class ProductDetailScreen extends ConsumerWidget{
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail'),),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DebugBorder(
                  color: Colors.orange,
                  label: 'Image Placeholder',
                  child: Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DebugBorder(
                  color: Colors.green,
                  label: 'Product Info',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp${product.price}', 
                        style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text('Store: ${product.storeName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Stock: ${product.stock} items available'),
                      const SizedBox(height: 16),
                      const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.description),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DebugBorder(
                  color: Colors.red,
                  label: 'Action Buttons',
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart (Level 3 Feature)'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add to cart')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}