import 'package:flutter/material.dart';
import 'package:seapedia/core/widgets/seapedia_error_widget.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/order/presentation/buyer_order_controller.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';
import 'package:seapedia/core/widgets/seapedia_shimmer.dart';

class BuyerOrdersScreen extends ConsumerWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyerOrdersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/buyer/orders'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Orders & Spending'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: state.when(
        loading: () {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surface : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 140,
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surface : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SeapediaShimmer(
                                  width: 150,
                                  height: 18,
                                ),
                                SeapediaShimmer(
                                  width: 24,
                                  height: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const SeapediaShimmer(width: 200, height: 14),
                            const SizedBox(height: 6),
                            const SeapediaShimmer(width: 120, height: 14),
                            const SizedBox(height: 12),
                            const SeapediaShimmer(width: 80, height: 12),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(2, (i) => const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: SeapediaShimmer(width: 180, height: 12),
                              )),
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
        error: (err, _) => SeapediaErrorWidget(
        error: err,
        onRetry: () => ref.refresh(buyerOrdersProvider),
      ),
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text('No orders found.'));

          final totalSpent = orders.where((o) => o.status != 'RETURNED').fold(0.0, (sum, order) => sum + order.finalTotal);

          return Column(
            children: [
              ListTile(
                  title: const Text('Total Spending', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('Rp ${totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('Store: ${order.storeName ?? "Unknown"}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${order.status}\nTotal: Rp ${order.finalTotal}'),
                              const SizedBox(height: 4,),
                              const Text(
                                'Timeline:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),...order.history.map((h) => Text('- ${h.status} (${h.createdAt.toLocal().toString().split('.')[0]})', style: const TextStyle(fontSize: 12),))
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.receipt_long),
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