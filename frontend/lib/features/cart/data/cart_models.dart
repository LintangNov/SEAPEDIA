class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: product['name']?.toString() ?? 'Unknown Product',
      price: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
    );
  }
}

class CartSummary {
  final String id;
  final String? sellerId;
  final List<CartItem> items;

  CartSummary({
    required this.id,
    this.sellerId,
    required this.items,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return CartSummary(
      id: json['id']?.toString() ?? '',
      sellerId: json['sellerId']?.toString(),
      items: itemsList.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}