import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/order/data/order_models.dart';
import 'package:seapedia/features/order/data/order_repository.dart';

class SellerOrdersController extends AsyncNotifier<List<OrderModel>> {
  @override
  FutureOr<List<OrderModel>> build() async {
    return ref.watch(orderRepositoryProvider).getSellerIncoming();
  }

  Future<void> processOrder(String orderId) async {
    await AsyncValue.guard(() async {
      await ref.read(orderRepositoryProvider).processOrder(orderId);
      ref.invalidateSelf();
    });
  }
}

final sellerOrdersProvider = AsyncNotifierProvider.autoDispose<SellerOrdersController, List<OrderModel>>(SellerOrdersController.new);
