import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/debug_border.dart';
import 'auth_controller.dart';

class SelectRoleScreen extends ConsumerStatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  ConsumerState<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends ConsumerState<SelectRoleScreen> {
  bool _isLoading = false;

  Future<void> _handleSelectRole(String role) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).selectRole(role);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableRoles = ref
        .read(authControllerProvider.notifier)
        .availableRoles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Active Role'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please select your active role for this session:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (availableRoles.isEmpty)
              const Text('No roles available', textAlign: TextAlign.center),

            ...availableRoles.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DebugBorder(
                  color: Colors.blueAccent,
                  label: 'Role Selection Button',
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _handleSelectRole(role),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Login as $role'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
