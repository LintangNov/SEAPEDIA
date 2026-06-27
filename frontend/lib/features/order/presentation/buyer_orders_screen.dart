import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/order/presentation/buyer_order_controller.dart';
import '../../../core/widgets/debug_border.dart';

class BuyerOrdersScreen extends ConsumerWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyerOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders & Spending')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text('No orders found.'));

          final totalSpent = orders.where((o) => o.status != 'RETURNED').fold(0.0, (sum, order) => sum + order.finalTotal);

          return Column(
            children: [
              DebugBorder(
                color: Colors.green, label: 'Spending Report',
                child: ListTile(
                  title: const Text('Total Spending', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('Rp ${totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return DebugBorder(
                      color: Colors.blue, label: 'Order Status Tracker',
                      child: Card(
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