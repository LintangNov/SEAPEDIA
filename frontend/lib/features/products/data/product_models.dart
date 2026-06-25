class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String storeName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.storeName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final sellerObj = json['seller'] as Map<String, dynamic>?;
    final extractedStoreName =
        sellerObj?['storeName']?.toString() ??
        json['storeName']?.toString() ??
        'Unknown Store';

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      description:
          json['description']?.toString() ?? 'No description provided.',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      storeName: extractedStoreName,
    );
  }
}
