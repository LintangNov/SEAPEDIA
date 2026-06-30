import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seapedia/core/widgets/seapedia_error_widget.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/driver/data/driver_repository.dart';
import 'package:seapedia/features/driver/presentation/driver_dashboard_controller.dart';
import 'package:seapedia/features/order/data/order_models.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';

class FindJobsController extends AsyncNotifier<List<OrderModel>> {
  @override
  FutureOr<List<OrderModel>> build() async {
    return ref.watch(driverRepositoryProvider).getAvailableJobs();
  }

  Future<void> takeJob(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(driverRepositoryProvider).takeJob(orderId);
      ref.invalidate(driverDashboardProvider);
      return [];
    });
  }
}

final findJobsProvider = AsyncNotifierProvider.autoDispose<FindJobsController, List<OrderModel>>(FindJobsController.new);

class FindJobsScreen extends ConsumerWidget {
  const FindJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(findJobsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/driver/find-jobs'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Available Delivery Jobs'),
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
          onRetry: () => ref.refresh(findJobsProvider),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(findJobsProvider),
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Text('No available jobs right now'),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(findJobsProvider),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Pickup from: ${job.storeName ?? "Unknown Store"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Delivery Method: ${job.deliveryMethod}'),
                        Text('Earning Potential: Rp ${job.deliveryFee}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Take Job'),
                                content: Text(
                                  'Are you sure you want to take this delivery job?\n\n'
                                  'Pickup: ${job.storeName ?? "Unknown Store"}\n'
                                  'Delivery: ${job.deliveryMethod}\n'
                                  'Earning Potential: Rp ${job.deliveryFee}'
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Take Job'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              try {
                                await ref.read(findJobsProvider.notifier).takeJob(job.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Job taken successfully!')),
                                  );
                                  context.pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                  final _ = ref.refresh(findJobsProvider);
                                }
                              }
                            }
                          },
                          child: const Text('Take Delivery Job'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}