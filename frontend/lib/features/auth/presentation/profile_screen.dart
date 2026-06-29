import 'package:flutter/material.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/buyer/presentation/buyer_wallet_controller.dart';
import 'package:seapedia/features/buyer/presentation/top_up_dialog.dart';
import 'package:seapedia/features/cart/presentation/cart_controller.dart';
import 'package:seapedia/features/order/presentation/buyer_order_controller.dart';
import 'package:seapedia/features/order/presentation/seller_order_controller.dart';
import 'package:seapedia/features/products/presentation/products_provider.dart';
import 'package:seapedia/features/driver/presentation/driver_dashboard_controller.dart';
import 'package:seapedia/features/driver/presentation/driver_history_screen.dart';
import 'package:seapedia/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsyncValue = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/profile'),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(profileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(context, ref, profile, theme, isDark),
              const SizedBox(height: 16),
              _buildStatsRow(ref, profile.activeRole, theme, isDark, context),
              const SizedBox(height: 16),
              _buildSwitchRoleCard(context, ref, profile, theme, isDark),
              const SizedBox(height: 16),
              _buildActionsSection(context, ref, profile, theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Widget _buildHeaderCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primary.withAlpha(25),
            child: Icon(
              Icons.person,
              size: 44,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Active Role: ${profile.activeRole}',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsCard(
    String value,
    String label,
    IconData icon,
    ThemeData theme,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    WidgetRef ref,
    String activeRole,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    if (activeRole == 'BUYER') {
      final walletState = ref.watch(buyerWalletControllerProvider);
      final cartState = ref.watch(cartControllerProvider);
      final ordersState = ref.watch(buyerOrdersProvider);

      final balanceStr = walletState.maybeWhen(
        data: (balance) => 'Rp ${balance.toStringAsFixed(0)}',
        orElse: () => 'Rp 0',
      );
      final cartCount = cartState.maybeWhen(
        data: (cart) => cart?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0,
        orElse: () => 0,
      );
      final ordersCount = ordersState.maybeWhen(
        data: (orders) => orders.length,
        orElse: () => 0,
      );

      return Row(
        children: [
          _buildMiniStatsCard(
            balanceStr,
            'Wallet Balance',
            Icons.account_balance_wallet_outlined,
            theme,
            isDark,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const TopUpDialog(),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$cartCount items',
            'In Cart',
            Icons.shopping_cart_outlined,
            theme,
            isDark,
            onTap: () => context.push('/cart'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$ordersCount orders',
            'Total Orders',
            Icons.receipt_long_outlined,
            theme,
            isDark,
            onTap: () => context.push('/buyer/orders'),
          ),
        ],
      );
    } else if (activeRole == 'SELLER') {
      final sellerOrdersState = ref.watch(sellerOrdersProvider);
      final sellerProductsState = ref.watch(sellerProductsProvider);

      final revenue = sellerOrdersState.maybeWhen(
        data: (orders) => orders
            .where((o) => o.status != 'RETURNED')
            .fold(0.0, (sum, o) => sum + (o.subtotal - o.discountAmount)),
        orElse: () => 0.0,
      );
      final productCount = sellerProductsState.maybeWhen(
        data: (products) => products.length,
        orElse: () => 0,
      );
      final pendingCount = sellerOrdersState.maybeWhen(
        data: (orders) => orders.where((o) => o.status == 'PENDING' || o.status == 'Sedang Dikemas').length,
        orElse: () => 0,
      );

      return Row(
        children: [
          _buildMiniStatsCard(
            'Rp ${revenue.toStringAsFixed(0)}',
            'Total Revenue',
            Icons.monetization_on_outlined,
            theme,
            isDark,
            onTap: () => context.push('/seller/orders'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$productCount prod',
            'Products',
            Icons.shopping_bag_outlined,
            theme,
            isDark,
            onTap: () => context.go('/seller/dashboard'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$pendingCount orders',
            'Pending Orders',
            Icons.pending_actions_outlined,
            theme,
            isDark,
            onTap: () => context.push('/seller/orders'),
          ),
        ],
      );
    } else if (activeRole == 'DRIVER') {
      final driverState = ref.watch(driverDashboardProvider);
      final driverHistoryState = ref.watch(driverHistoryProvider);

      final earnings = driverState.maybeWhen(
        data: (data) => data.earnings,
        orElse: () => 0.0,
      );
      final completedCount = driverHistoryState.maybeWhen(
        data: (history) => history.length,
        orElse: () => 0,
      );
      final activeJob = driverState.maybeWhen(
        data: (data) => data.activeOrder != null ? 'Active' : 'None',
        orElse: () => 'None',
      );

      return Row(
        children: [
          _buildMiniStatsCard(
            'Rp ${earnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.motorcycle_outlined,
            theme,
            isDark,
            onTap: () => context.push('/driver/dashboard'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$completedCount jobs',
            'Completed',
            Icons.check_circle_outline,
            theme,
            isDark,
            onTap: () => context.push('/driver/history'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            activeJob,
            'Current Job',
            Icons.local_shipping_outlined,
            theme,
            isDark,
            onTap: () => context.push('/driver/dashboard'),
          ),
        ],
      );
    } else if (activeRole == 'ADMIN') {
      final adminMonitoringState = ref.watch(adminMonitoringProvider);

      final totalUsers = adminMonitoringState.maybeWhen(
        data: (data) => data['totalUsers'] ?? 0,
        orElse: () => 0,
      );
      final totalStores = adminMonitoringState.maybeWhen(
        data: (data) => data['totalStores'] ?? 0,
        orElse: () => 0,
      );
      final totalOrders = adminMonitoringState.maybeWhen(
        data: (data) => data['totalOrders'] ?? 0,
        orElse: () => 0,
      );

      return Row(
        children: [
          _buildMiniStatsCard(
            '$totalUsers users',
            'Total Users',
            Icons.people_outline,
            theme,
            isDark,
            onTap: () => context.push('/admin/dashboard'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$totalStores stores',
            'Total Stores',
            Icons.storefront_outlined,
            theme,
            isDark,
            onTap: () => context.push('/admin/dashboard'),
          ),
          const SizedBox(width: 12),
          _buildMiniStatsCard(
            '$totalOrders orders',
            'Total Orders',
            Icons.receipt_long_outlined,
            theme,
            isDark,
            onTap: () => context.push('/admin/dashboard'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSwitchRoleCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Switch Role',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            children: profile.roles.map((role) {
              final isActive = profile.activeRole == role;
              return ChoiceChip(
                label: Text(role),
                selected: isActive,
                selectedColor: theme.colorScheme.primary.withAlpha(100),
                onSelected: isActive
                    ? null
                    : (selected) async {
                        if (selected) {
                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .selectRole(role);
                            ref.invalidate(profileProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Switched role to $role')),
                              );
                              if (role == 'SELLER') {
                                context.go('/seller/dashboard');
                              } else if (role == 'DRIVER') {
                                context.go('/driver/dashboard');
                              } else if (role == 'ADMIN') {
                                context.go('/admin/dashboard');
                              } else {
                                context.go('/products');
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        }
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            title: const Text('Change Username'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangeUsernameDialog(context, ref, profile),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.redAccent),
            onTap: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeUsernameDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}
