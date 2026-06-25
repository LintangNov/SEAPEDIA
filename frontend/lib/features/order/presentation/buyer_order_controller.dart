import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/order/data/order_models.dart';
import 'package:seapedia/features/order/data/order_repository.dart';

class BuyerOrdersController extends AsyncNotifier<List<OrderModel>> {
  @override
  FutureOr<List<OrderModel>> build() async {
    return ref.watch(orderRepositoryProvider).getBuyerHistory();
  }
}

final buyerOrdersProvider = AsyncNotifierProvider.autoDispose<BuyerOrdersController, List<OrderModel>>(BuyerOrdersController.new);
