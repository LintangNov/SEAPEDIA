import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/debug_border.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getProfile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            tooltip: 'Logout',
          )
        ],
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => ref.refresh(profileProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
        data: (profile) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DebugBorder(
                color: Colors.blue,
                label: 'User Info Card',
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.username,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Role: ${profile.activeRole}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DebugBorder(
                color: Colors.purple,
                label: 'System Actions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Go to Product Catalog'),
                      onPressed: () {
                        // TODO: navigasi ke halaman produk
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}