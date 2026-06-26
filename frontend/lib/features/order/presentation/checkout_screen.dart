import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/debug_border.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/order_models.dart';
import '../data/order_repository.dart';
import 'checkout_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  String _selectedDeliveryMethod = 'REGULAR';
  Discount? _appliedDiscount;
  List<Discount> _availableDiscounts = [];

  final Map<String, double> _deliveryFees = {
    'INSTANT': 20000.0,
    'NEXT_DAY': 15000.0,
    'REGULAR': 10000.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchDiscounts();
  }

  Future<void> _fetchDiscounts() async {
    final discounts = await ref
        .read(orderRepositoryProvider)
        .getActiveDiscounts();
    setState(() {
      _availableDiscounts = discounts;
    });
  }

  void _applyDiscount() {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    try {
      final discount = _availableDiscounts.firstWhere(
        (d) =>
            d.code.toUpperCase() == code.toUpperCase() &&
            d.expiryDate.isAfter(DateTime.now()),
      );
      setState(() => _appliedDiscount = discount);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Discount applied!')));
    } catch (e) {
      setState(() => _appliedDiscount = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired discount code.')),
      );
    }
  }

  Future<void> _handleCheckout() async {
    final address = _addressController.text.trim();
    if (address.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a complete delivery address'),
        ),
      );
      return;
    }

    await ref
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          _selectedDeliveryMethod,
          address,
          _appliedDiscount?.code,
        );

    final state = ref.read(checkoutControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else if (mounted) {
      context.go('/order-success');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _discountController.dispose();
    super.dispose();
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
          if (cart == null || cart.items.isEmpty){
            return const Center(child: Text('Your cart is empty.'));
          }
          double subtotal = cart.items.fold(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );
          double discountAmount = _appliedDiscount?.amount ?? 0.0;

          double discountedSubtotal = subtotal - discountAmount;
          if (discountedSubtotal < 0) discountedSubtotal = 0;

          double deliveryFee = _deliveryFees[_selectedDeliveryMethod]!;
          double tax = discountedSubtotal * 0.12;
          double finalTotal = discountedSubtotal + deliveryFee + tax;

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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _deliveryFees.keys
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              '$method (Rp ${_deliveryFees[method]})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null){
                        setState(() => _selectedDeliveryMethod = val);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                DebugBorder(
                  color: Colors.purple,
                  label: 'Voucher / Promo Code',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          decoration: const InputDecoration(
                            hintText: 'Enter code (e.g., PROMO10)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyDiscount,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DebugBorder(
                  color: Colors.green,
                  label: 'Payment Summary',
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: subtotal),
                      if (discountAmount > 0)
                        _SummaryRow(
                          label: 'Discount',
                          value: -discountAmount,
                          color: Colors.green,
                        ),
                      _SummaryRow(label: 'Delivery Fee', value: deliveryFee),
                      _SummaryRow(label: 'PPN (12%)', value: tax),
                      const Divider(thickness: 2),
                      _SummaryRow(
                        label: 'Total Payment',
                        value: finalTotal,
                        isTotal: true,
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
                      : const Text(
                          'Confirm & Pay',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
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
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

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
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rp ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? Colors.blue.shade800 : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
