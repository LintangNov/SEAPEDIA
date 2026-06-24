import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/core/widgets/debug_border.dart';
import 'package:seapedia/features/cart/presentation/cart_controller.dart';
import 'package:seapedia/features/order/presentation/checkout_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _selectedDeliveryMethod = 'REGULAR';

  final Map<String, double> _deliveryFees = {
    'INSTANT': 20000.0,
    'NEXT_DAY': 15000.0,
    'REGULAR': 10000.0,
  };

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final address = _addressController.text.trim();
    if (address.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complete delivery address')),
      );
      return;
    }

    await ref.read(checkoutControllerProvider.notifier).processCheckout(_selectedDeliveryMethod, address);
    final state = ref.read(checkoutControllerProvider);
    if(state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString()))
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout successfull!'))
      );

      context.go('/profile'); // TODO: ganti ke halaman riwayat di lv 4
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          double subtotal = cart.items.fold(0, (sum, item) => sum + (item.price * item.quantity));
          double deliveryFee = _deliveryFees[_selectedDeliveryMethod]!;
          double tax = subtotal * 0.12;
          double finalTotal = subtotal + deliveryFee + tax;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DebugBorder(
                  color: Colors.blue,
                  label: 'Delivery Address',
                  child: TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Full Delivery Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DebugBorder(
                  color: Colors.orange,
                  label: 'Delivery Method',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDeliveryMethod,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _deliveryFees.keys.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text('$method (Rp ${_deliveryFees[method]})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDeliveryMethod = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                DebugBorder(
                  color: Colors.green,
                  label: 'Payment Summary',
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: subtotal),
                      _SummaryRow(label: 'Delivery Fee', value: deliveryFee),
                      _SummaryRow(label: 'PPN (12%)', value: tax),
                      const Divider(thickness: 2),
                      _SummaryRow(
                        label: 'Total Payment', 
                        value: finalTotal, 
                        isTotal: true
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: checkoutState.isLoading ? null : _handleCheckout,
                  child: checkoutState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm & Pay', style: TextStyle(fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: isTotal ? 18 : 14, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
            )
          ),
          Text(
            'Rp ${value.toStringAsFixed(2)}', 
            style: TextStyle(
              fontSize: isTotal ? 18 : 14, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue.shade800 : Colors.black,
            )
          ),
        ],
      ),
    );
  }
}