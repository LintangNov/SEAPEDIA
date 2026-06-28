import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/buyer/presentation/buyer_wallet_controller.dart';
import 'package:seapedia/features/buyer/presentation/top_up_dialog.dart';
import '../../../core/widgets/debug_border.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';

final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
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
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
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
              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                          onPressed: () async {
                            final textController = TextEditingController(text: profile.username);
                            final newName = await showDialog<String>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Change Username'),
                                content: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(labelText: 'New Username'),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, textController.text.trim()),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );

                            if (newName != null && newName != profile.username && newName.length >= 3) {
                              try {
                                await ref.read(authRepositoryProvider).updateUsername(newName);
                                ref.invalidate(profileProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username updated')));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              }
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Active Role:', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: profile.roles.map((role) {
                        final isActive = profile.activeRole == role;
                        return ChoiceChip(
                          label: Text(role),
                          selected: isActive,
                          selectedColor: Colors.green.withAlpha(100),
                          onSelected: isActive ? null : (selected) async {
                            if (selected) {
                              try {
                                await ref.read(authControllerProvider.notifier).selectRole(role);
                                ref.invalidate(profileProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched role to $role')));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              if (profile.activeRole == 'BUYER')
                Consumer(
                  builder: (context, ref, child) {
                    final walletState = ref.watch(
                      buyerWalletControllerProvider,
                    );
                    return walletState.when(
                      loading: () => const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Loading Wallet...'),
                      ),
                      error: (error, _) => ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: const Text('Wallet Error'),
                        subtitle: Text(error.toString()),
                      ),
                      data: (balance) => ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blue,
                        ),
                        title: const Text('Wallet Balance'),
                        subtitle: Text('Rp ${balance.toStringAsFixed(2)}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const TopUpDialog(),
                            );
                          },
                          child: const Text('Top Up'),
                        ),
                      ),
                    );
                  },
                )
              else
                const ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.grey,
                  ),
                  title: Text('Wallet Balance'),
                  subtitle: Text('Switch to BUYER role to manage wallet'),
                ),

              ListTile(
                leading: const Icon(Icons.badge, color: Colors.purple),
                title: const Text('Owned Roles'),
                subtitle: Text(profile.roles.join(', ')),
              ),

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
                        context.go('/products');
                      },
                    ),
                    if (profile.activeRole == 'SELLER') ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withAlpha(51),
                          foregroundColor: Colors.orange.shade800,
                        ),
                        icon: const Icon(Icons.storefront),
                        label: const Text('Enter Seller Dashboard'),
                        onPressed: () => context.go('/seller/dashboard'),
                      ),
                    ],
                    if (profile.activeRole == 'BUYER') ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withAlpha(51),
                          foregroundColor: Colors.blue.shade800,
                        ),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Open Shopping Cart'),
                        onPressed: () {
                          context.push('/cart');
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withAlpha(51), foregroundColor: Colors.green.shade800),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('View Order History & Spending'),
                        onPressed: () => context.push('/buyer/orders'),
                      ),
                    ],
                    if (profile.activeRole == 'ADMIN') ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withAlpha(51),
                          foregroundColor: Colors.red.shade800,
                        ),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Open Admin Dashboard'),
                        onPressed: () => context.push('/admin/dashboard'),
                      ),
                    ],
                    if (profile.activeRole == 'DRIVER')...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.withAlpha(51),
                          foregroundColor: Colors.teal.shade800,
                        ),
                        icon: const Icon(Icons.two_wheeler),
                        label: const Text('Enter Driver Dashboard'),
                        onPressed: () => context.push('/driver/dashboard'),
                      ),
                    ]
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
