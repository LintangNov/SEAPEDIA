import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_models.dart';
import '../data/product_repository.dart';

final productsListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

final sellerProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getSellerProducts();
});