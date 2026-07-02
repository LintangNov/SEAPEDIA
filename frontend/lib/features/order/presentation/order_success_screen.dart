import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScaleAnimation;

  late AnimationController _truckController;
  late Animation<double> _truckSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Checkmark bounce animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _checkScaleAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkController.forward();

    // Truck slide animation
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _truckSlideAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _truckController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _truckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScaleTransition(
              scale: _checkScaleAnimation,
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _truckSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_truckSlideAnimation.value, 0.0),
                        child: child,
                      );
                    },
                    child: const Icon(Icons.local_shipping, size: 48, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Waiting for Driver...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your order is being prepared by the seller and will be assigned to a delivery driver soon.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Back to Profile'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('/products'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
