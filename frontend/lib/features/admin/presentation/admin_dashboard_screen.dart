import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/admin/presentation/admin_discount_controller.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  final _usageController = TextEditingController();
  String _selectedType = 'PROMO';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final code = _codeController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final usage = int.tryParse(_usageController.text);

    if (code.isEmpty || amount <= 0 || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code, Valid Amount, and Expiry Date are required')));
      return;
    }

    await ref.read(adminDiscountProvider.notifier).createDiscount(code, _selectedType, amount, _selectedDate!, usage);
    
    final state = ref.read(adminDiscountProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else if (mounted) {
      _codeController.clear();
      _amountController.clear();
      _usageController.clear();
      setState(() => _selectedDate = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discount Created')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDiscountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Discount Code'),
                ),
                DropdownButton(items: ['PROMO', 'VOUCHER'].map((e) => DropdownMenuItem(value: e, child: Text(e),)).toList(), 
                onChanged: (val) => setState(() => _selectedType = val!),
                ),
                TextField(
                  controller:  _amountController,
                  decoration: const InputDecoration(labelText: 'Amount (RP)'),
                  keyboardType: TextInputType.number,
                ),
                if (_selectedType == 'VOUCHER')
                  TextField(controller: _usageController, decoration: const InputDecoration(labelText: 'Remaining Usage (Quota)'),keyboardType: TextInputType.number,),
                const SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(child: Text(_selectedDate == null? 'NoExpiry Date Selected' : 'Expiry: ${_selectedDate.toString().split(' ')[0]}')),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now().add(const Duration(days: 1)));
                        if (date != null) setState(() => _selectedDate = date);
                      },
                      child: const Text('Select Date'),
                    )
                  ],
                ),
                ElevatedButton(onPressed: state.isLoading ? null : _handleCreate, child: state.isLoading ? const CircularProgressIndicator() : const Text('Create Discount'))
              ],
            ),
          )
        ],
      ),
    );
  }
}