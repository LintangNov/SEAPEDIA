import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/order/presentation/seller_order_controller.dart';

class SeapediaBottomNavBar extends ConsumerWidget {
  final String currentPath;

  const SeapediaBottomNavBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(activeRoleProvider);
    if (activeRole == null) {
      return const SizedBox.shrink();
    }

    bool showOrdersBadge = false;
    if (activeRole == 'SELLER') {
      final sellerOrdersState = ref.watch(sellerOrdersProvider);
      showOrdersBadge = sellerOrdersState.maybeWhen(
        data: (orders) => orders.any((o) => o.status == 'BEING_PACKED'),
        orElse: () => false,
      );
    }

    final List<Map<String, dynamic>> items;
    if (activeRole == 'BUYER') {
      items = [
        {'path': '/products', 'icon': Icons.shopping_bag_outlined, 'label': 'Catalog'},
        {'path': '/cart', 'icon': Icons.shopping_cart_outlined, 'label': 'Cart'},
        {'path': '/buyer/orders', 'icon': Icons.receipt_long_outlined, 'label': 'Orders'},
        {'path': '/profile', 'icon': Icons.person_outline, 'label': 'Profile'},
      ];
    } else if (activeRole == 'SELLER') {
      items = [
        {'path': '/seller/dashboard', 'icon': Icons.storefront_outlined, 'label': 'Dashboard'},
        {'path': '/seller/orders', 'icon': Icons.receipt_outlined, 'label': 'Orders'},
        {'path': '/seller/store-profile', 'icon': Icons.store_outlined, 'label': 'Store'},
        {'path': '/profile', 'icon': Icons.person_outline, 'label': 'Profile'},
      ];
    } else if (activeRole == 'DRIVER') {
      items = [
        {'path': '/driver/dashboard', 'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
        {'path': '/driver/find-jobs', 'icon': Icons.search_outlined, 'label': 'Find Jobs'},
        {'path': '/driver/history', 'icon': Icons.history_outlined, 'label': 'History'},
        {'path': '/profile', 'icon': Icons.person_outline, 'label': 'Profile'},
      ];
    } else if (activeRole == 'ADMIN') {
      items = [
        {'path': '/admin/dashboard', 'icon': Icons.admin_panel_settings_outlined, 'label': 'Dashboard'},
        {'path': '/profile', 'icon': Icons.person_outline, 'label': 'Profile'},
      ];
    } else {
      return const SizedBox.shrink();
    }

    int currentIndex = items.indexWhere((item) {
      final path = item['path'] as String;
      if (path == '/profile') {
        return currentPath == '/profile';
      }
      return currentPath.startsWith(path);
    });

    if (currentIndex == -1) {
      currentIndex = 0;
    }

    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {
          context.go(items[index]['path'] as String);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items.map((item) {
        final path = item['path'] as String;
        final isOrdersTab = path == '/seller/orders';

        Widget iconWidget = Icon(item['icon'] as IconData);
        if (isOrdersTab && showOrdersBadge) {
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item['icon'] as IconData),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        }

        return BottomNavigationBarItem(
          icon: iconWidget,
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}
