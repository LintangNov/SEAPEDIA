import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import 'products_provider.dart';

class ProductFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    String? id,
    required String name,
    required String description,
    required double price,
    required int stock,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final dto = {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      };

      if (id == null) {
        await repository.createProduct(dto);
      } else {
        await repository.updateProduct(id, dto);
      }

      ref.invalidate(sellerProductsProvider);
      ref.invalidate(productsListProvider);
    });
  }
}

final productFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ProductFormController, void>(
  ProductFormController.new,
);