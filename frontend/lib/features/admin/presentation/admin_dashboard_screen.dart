import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/admin/data/admin_repository.dart';
import 'package:seapedia/features/admin/presentation/admin_discount_controller.dart';
import 'package:seapedia/features/order/data/order_models.dart';

final adminMonitoringProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref)  async {
  return ref.watch(adminRepositoryProvider).getMonitoringData();
});

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
  bool _isSimulating = false;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _handleSimulateOverdue() async {
    setState(() => _isSimulating = true,);
    try {
      await ref.read(adminRepositoryProvider).simulateOverdue(5);
      ref.invalidate(adminMonitoringProvider);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulation successful! The system jumped 5 days ahead, and the Auto-Refund was executed.')));      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSimulating = false,);
    }
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

  void _showDiscountDetail(BuildContext context, Discount d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail: ${d.code}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${d.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount: Rp ${d.amount}'),
            Text('Created At: ${d.createdAt.toLocal().toString().split('.')[0]}'),
            Text('Expiry Date: ${d.expiryDate.toLocal().toString().split('.')[0]}'),
            if (d.type == 'VOUCHER') ...[
              const Divider(),
              Text('Remaining Quota: ${d.remainingUsage ?? "Unlimited"}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(adminDiscountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.monitor), text: 'Monitoring & Logs'),
              Tab(icon: Icon(Icons.discount), text: 'Voucher & Promo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer(builder: (context, ref, child) {
              final monitoringState = ref.watch(adminMonitoringProvider);
              return monitoringState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (data) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminMonitoringProvider),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Column(
                          children: [
                            const Text('The system will automatically check for orders that have exceeded the SLA (Instant: 24h, Next Day: 48h, Regular: 120h).', textAlign: TextAlign.center,),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: _isSimulating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.fast_forward),
                              label: const Text('Day Simulation (+5 Days)'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: _isSimulating ? null : _handleSimulateOverdue,
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Column(
                          children: [
                            ListTile(leading: const Icon(Icons.people), title: const Text('Total Users'), trailing: Text('${data['totalUsers']}', style: const TextStyle(fontSize: 20))),
                            ListTile(leading: const Icon(Icons.store), title: const Text('Total Stores'), trailing: Text('${data['totalStores']}', style: const TextStyle(fontSize: 20))),
                            ListTile(leading: const Icon(Icons.shopping_bag), title: const Text('Total Products'), trailing: Text('${data['totalProducts']}', style: const TextStyle(fontSize: 20))),
                            ListTile(leading: const Icon(Icons.receipt), title: const Text('Total Orders'), trailing: Text('${data['totalOrders']}', style: const TextStyle(fontSize: 20))),
                            ListTile(leading: const Icon(Icons.assignment_return, color: Colors.orange), title: const Text('Total Returned (All)'), trailing: Text('${data['totalReturnedOrders']}', style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold))),
                            ListTile(leading: const Icon(Icons.warning, color: Colors.red), title: const Text('SLA Auto-Refunded'), trailing: Text('${data['totalAutoRefunds']}', style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold))),
                            ListTile(leading: const Icon(Icons.discount), title: const Text('Total Discounts'), trailing: Text('${data['totalDiscounts']}', style: const TextStyle(fontSize: 20))),
                            ListTile(leading: const Icon(Icons.motorcycle), title: const Text('Active Deliveries'), trailing: Text('${data['activeDeliveries']}', style: const TextStyle(fontSize: 20))),
                          ]
                        )
                    ]
                  )
                )
              );
            }),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Discount Code')),
                      DropdownButton<String>(
                        value: _selectedType, isExpanded: true,
                        items: ['PROMO', 'VOUCHER'].map((e) => DropdownMenuItem(value: e, child: Text(e),)).toList(), 
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                      TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount (RP)'), keyboardType: TextInputType.number),
                      if (_selectedType == 'VOUCHER')
                        TextField(controller: _usageController, decoration: const InputDecoration(labelText: 'Remaining Usage (Quota)'),keyboardType: TextInputType.number,),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text(_selectedDate == null? 'No Expiry Date Selected' : 'Expiry: ${_selectedDate.toString().split(' ')[0]}')),
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now().add(const Duration(days: 1)));
                              if (date != null) setState(() => _selectedDate = date);
                            },
                            child: const Text('Select Date'),
                          )
                        ],
                      ),
                      ElevatedButton(onPressed: discountState.isLoading ? null : _handleCreate, child: discountState.isLoading ? const CircularProgressIndicator() : const Text('Create Discount'))
                    ],
                  ),
                ), 
                const Divider(),
                Expanded(
                  child: discountState.when(
                    data: (discounts) => ListView.builder(
                      itemCount: discounts.length,
                      itemBuilder: (context, index){
                        final d = discounts[index];
                        return ListTile(
                          title: Text('${d.code} (${d.type}) - Rp${d.amount}'),
                          subtitle: Text('Expires: ${d.expiryDate.toLocal().toString().split(' ')[0]}'),
                          trailing: const Icon(Icons.info_outline, color: Colors.blue),
                          onTap: () => _showDiscountDetail(context, d),
                        );
                      },
                    ), 
                    error: (err, _) => Center(child: Text('Error: $err'),), 
                    loading: () => const Center(child: CircularProgressIndicator(),)
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}