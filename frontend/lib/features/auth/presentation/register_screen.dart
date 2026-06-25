import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/debug_border.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _availableRoles = ['SELLER', 'BUYER', 'DRIVER'];
  final List<String> _selectedRoles = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleRole(String role, bool? isChecked) {
    setState(() {
      if (isChecked == true) {
        _selectedRoles.add(role);
      } else {
        _selectedRoles.remove(role);
      }
    });
  }

  Future<void> _handleRegister() async {
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one role')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            _usernameController.text,
            _passwordController.text,
            _selectedRoles,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DebugBorder(
              color: Colors.orange,
              label: 'Username Input',
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(hintText: 'Enter username'),
              ),
            ),
            DebugBorder(
              color: Colors.purple,
              label: 'Password Input',
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter password (min. 6 chars)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            DebugBorder(
              color: Colors.teal,
              label: 'Role Selection (Multi-select)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _availableRoles.map((role) {
                  return CheckboxListTile(
                    title: Text(role),
                    value: _selectedRoles.contains(role),
                    onChanged: (bool? value) => _toggleRole(role, value),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            DebugBorder(
              color: Colors.red,
              label: 'Submit Action',
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}
