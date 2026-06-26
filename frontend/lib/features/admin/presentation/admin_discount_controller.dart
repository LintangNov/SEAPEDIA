import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/features/admin/data/admin_repository.dart';
import 'package:seapedia/features/order/data/order_models.dart';

class AdminDiscountController extends AsyncNotifier<List<Discount>> {
  @override
  FutureOr<List<Discount>> build() async {
    return ref.watch(adminRepositoryProvider).getDiscounts();
  }

  Future<void> createDiscount(String code, String type, double amount, DateTime expiryDate, int? remainingUsage) async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async{
      await ref.read(adminRepositoryProvider).getDiscounts();
      return await ref.read(adminRepositoryProvider).getDiscounts();
    });
  }
}

final adminDiscountProvider = AsyncNotifierProvider.autoDispose<AdminDiscountController, List<Discount>>(
  AdminDiscountController.new,
);