class Discount {
  final String id;
  final String code;
  final String type;
  final double amount;
  final DateTime expiryDate;
  final int? remainingUsage;
  final DateTime createdAt;

  Discount({
    required this.id,
    required this.code,
    required this.type,
    required this.amount,
    required this.expiryDate,
    this.remainingUsage,
    required this.createdAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'PROMO',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      expiryDate:
          DateTime.tryParse(json['expiryDate']?.toString() ?? '') ??
          DateTime.now(),
      remainingUsage: (json['remainingUsage'] as num?)?.toInt(),
      createdAt: 
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? 
          DateTime.now(),
    );
  }
}

class OrderModel {
  final String id;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double finalTotal;
  final String status;
  final String deliveryMethod;
  final String? storeName;
  final DateTime createdAt;
  final List<OrderStatusHistory> history;

  OrderModel({
    required this.id,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.taxAmount,
    required this.finalTotal,
    required this.status,
    required this.deliveryMethod,
    this.storeName,
    required this.createdAt,
    required this.history,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final historyList = json['statusHistory'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discountAmount:
          double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      deliveryFee:
          double.tryParse(json['deliveryFee']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      finalTotal: double.tryParse(json['finalTotal']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'UNKNOWN',
      deliveryMethod: json['deliveryMethod']?.toString() ?? 'REGULAR',
      storeName: json['seller']?['storeName']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      history: historyList.map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class OrderStatusHistory {
  final String status;
  final DateTime createdAt;

  OrderStatusHistory({required this.status, required this.createdAt});

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: json['status']?.toString() ?? 'unknown',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
