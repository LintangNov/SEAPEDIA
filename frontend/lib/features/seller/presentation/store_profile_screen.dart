import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/debug_border.dart';
import 'store_profile_controller.dart';

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
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile')),
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
            DebugBorder(
              color: Colors.blue,
              label: 'Store Name Input',
              child: TextField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                ),
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
