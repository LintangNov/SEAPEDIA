import 'package:flutter/material.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/driver/presentation/driver_dashboard_controller.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverDashboardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/driver/dashboard'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Driver Dashboard'),
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
        data: (profile) {
          final activeJob = profile.activeOrder;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: Colors.green, size: 24,),
                    title: const Text('Total Earnings'),
                    subtitle: Text('Rp ${profile.earnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 24,),

                if (activeJob != null)...[
                  const Text('Active Delivery Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Order ID: ${activeJob.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Delivery Fee (Your Pay): Rp ${activeJob.deliveryFee}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const Divider(),
                            Text('Status: ${activeJob.status}'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Confirm Delivery Complete'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Complete Job'),
                                    content: const Text('Have you successfully delivered the order to the buyer?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Completed')),
                                    ],
                                  )
                                );
                                if (confirm == true) {
                                  await ref.read(driverDashboardProvider.notifier).completeJob(activeJob.id);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    )
                ] else...[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Find Available Jobs'),
                          onPressed: () => context.push('/driver/find-jobs'),
                        ),
                      ],
                    ),
                ],
                const SizedBox(height: 16,),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View Delivery History'),
                  onPressed: () => context.push('/driver/history'),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}