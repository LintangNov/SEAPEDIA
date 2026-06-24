import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/buyer/presentation/buyer_wallet_controller.dart';
import 'package:seapedia/features/cart/presentation/cart_controller.dart';
import 'package:seapedia/features/order/data/order_repository.dart';

class CheckoutController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> processCheckout(String method, String address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(orderRepositoryProvider);
      await repository.checkout(method, address);

      ref.invalidate(cartControllerProvider);
      ref.invalidate(buyerWalletControllerProvider);
    });
  }
}

final checkoutControllerProvider = AsyncNotifierProvider.autoDispose<CheckoutController, void>(
  CheckoutController.new
);