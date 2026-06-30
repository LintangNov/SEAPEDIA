import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/cart/data/cart_models.dart';
import 'package:seapedia/features/cart/data/cart_repository.dart';

class CartController extends AsyncNotifier<CartSummary?> {
  @override
  FutureOr<CartSummary?> build() async {
    final repository = ref.watch(cartRepositoryProvider);
    return repository.getCart();
  }

  Future<void> addToCart(String productId, int quantity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(cartRepositoryProvider);
      await repository.addToCart(productId, quantity);
      return repository.getCart();
    });
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) {
      return removeItem(cartItemId);
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(cartRepositoryProvider);
      await repository.updateQuantity(cartItemId, newQuantity);
      return repository.getCart();
    });
  }

  Future<void> removeItem(String cartItemId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(cartRepositoryProvider);
      await repository.removeCartItem(cartItemId);
      return repository.getCart();
    });
  }

  Future<void> clearCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(cartRepositoryProvider);
      await repository.clearCart();
      return null;
    });
  }
}

final cartControllerProvider =
    AsyncNotifierProvider<CartController, CartSummary?>(
      CartController.new,
    );
