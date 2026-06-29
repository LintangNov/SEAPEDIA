import 'package:flutter/material.dart';
import 'package:seapedia/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'store_profile_controller.dart';
import 'package:seapedia/core/widgets/seapedia_bottom_nav_bar.dart';

class StoreProfileScreen extends ConsumerStatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  ConsumerState<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends ConsumerState<StoreProfileScreen> {
  final _storeNameController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final storeName = _storeNameController.text.trim();
    if (storeName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store name must be at least 3 characters'),
        ),
      );
      return;
    }

    await ref
        .read(storeProfileControllerProvider.notifier)
        .updateStoreName(storeName);

    final state = ref.read(storeProfileControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Store profile updated successfully')),
        );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/seller/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeProfileControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const SeapediaBottomNavBar(currentPath: '/seller/store-profile'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Store Profile'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Before adding products, you must set up a unique store name.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isLoading ? null : _handleSubmit,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Store Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
