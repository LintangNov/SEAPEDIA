import 'package:seapedia/features/order/data/order_models.dart';

class DriverProfileData {
  final double earnings;
  final OrderModel? activeOrder;

  DriverProfileData({required this.earnings, this.activeOrder});

  factory DriverProfileData.fromJson(Map<String, dynamic> json) {
    OrderModel? order;
    if (json['activeJob'] != null && json['activeJob']['order'] != null) {
      order = OrderModel.fromJson(json['activeJob']['order']);
    }

    return DriverProfileData(
      earnings: double.tryParse(json['earnings']?.toString() ?? '0') ?? 0.0,
      activeOrder: order,
    );
  }
}