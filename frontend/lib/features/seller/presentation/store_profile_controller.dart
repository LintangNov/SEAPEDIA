import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seller_repository.dart';

class StoreProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateStoreName(String storeName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(sellerRepositoryProvider);
      await repository.updateStoreProfile(storeName);
    });
  }
}

final storeProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<StoreProfileController, void>(
  StoreProfileController.new,
);