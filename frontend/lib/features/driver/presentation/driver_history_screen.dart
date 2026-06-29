import 'package:flutter/material.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/driver/data/driver_repository.dart';
import 'package:seapedia/features/order/data/order_models.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';

final driverHistoryProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return ref.watch(driverRepositoryProvider).getHistory();
});

class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverHistoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/driver/history'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Delivery History'),
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
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (history) {
          if (history.isEmpty) return const Center(child: Text('You have not completed any deliveries yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final job = history[index];
              return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Order ID: ${job.id.length >= 8 ? job.id.substring(0, 8) : job.id}...'),
                    subtitle: Text('Earned: Rp ${job.deliveryFee}\nDate: ${job.createdAt.toLocal().toString().split('.')[0]}'),
                    isThreeLine: true,
                  ),
                );
            },
          );
        },
      ),
    );
  }
}