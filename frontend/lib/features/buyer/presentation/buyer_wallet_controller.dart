import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/buyer/data/buyer_repository.dart';

class BuyerWalletController extends AsyncNotifier<double> {
  @override
  FutureOr<double> build() async {
    final repository = ref.watch(buyerRepositoryProvider);
    return repository.getWalletBalance();
  }

  Future<void> topUp(double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(buyerRepositoryProvider);
      return await repository.topUp(amount);
    });
  }
}

final buyerWalletControllerProvider =
    AsyncNotifierProvider.autoDispose<BuyerWalletController, double>(
      BuyerWalletController.new,
    );
