import 'package:flutter/material.dart';
import 'package:seapedia/core/widgets/seapedia_error_widget.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/order/presentation/seller_order_controller.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';

class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerOrdersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/seller/orders'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Seller Orders & Income'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => SeapediaErrorWidget(
        error: err,
        onRetry: () => ref.refresh(sellerOrdersProvider),
      ),
        data: (orders) {
          if (orders.isEmpty){
            return const Center(child: Text('No orders yet.'));
          }

          final totalIncome = orders
              .where((o) => o.status != 'RETURNED')
              .fold(
                0.0,
                (sum, order) => sum + (order.subtotal - order.discountAmount),
              );
          return Column(
            children: [
              ListTile(
                  title: const Text(
                    'Estimated Revenue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('(Subtotal - Discount)'),
                  trailing: Text(
                    'Rp ${totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Order ID: ${order.id.substring(0, 8)}...',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Status: ${order.status}',
                                style: TextStyle(
                                  color: order.status == 'BEING_PACKED'
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                              ),
                              Text('Total Buyer Paid: Rp ${order.finalTotal}'),
                              const SizedBox(height: 12),
                              if (order.status == 'BEING_PACKED')
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(sellerOrdersProvider.notifier)
                                        .processOrder(order.id);
                                  },
                                  child: const Text('Process Order'),
                                ),
                            ],
                          ),
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
