import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/core/widgets/debug_border.dart';
import 'package:seapedia/features/driver/data/driver_repository.dart';
import 'package:seapedia/features/driver/presentation/driver_dashboard_controller.dart';
import 'package:seapedia/features/order/data/order_models.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Available Delivery Jobs'),),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: () => ref.refresh(findJobsProvider), child: const Text('Retry'))
            ],
          )
        ),
        data: (jobs) {
          if (jobs.isEmpty) return const Center(child: Text('No available jibs right now'),);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return DebugBorder(
                color: Colors.purpleAccent, label: 'Job List',
                child: Card(
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
                            try {
                              await ref.read(findJobsProvider.notifier).takeJob(job.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job taken successfully!')));
                                context.pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                final _ = ref.refresh(findJobsProvider);
                              }
                            }
                          },
                          child: const Text('Take Delivery Job'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}