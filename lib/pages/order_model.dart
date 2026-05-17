import 'product_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderModel {
  final String orderCode;
  final List<Product> products;
  final Map<String, int> quantities;
  final int totalPayment;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String method;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.orderCode,
    required this.products,
    required this.quantities,
    required this.totalPayment,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderCode': orderCode,
      'products': products.map((e) => e.toJson()).toList(),
      'quantities': quantities,
      'totalPayment': totalPayment,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<Product> productList =
        (json['products'] as List)
            .map((e) => Product.fromJson(e))
            .toList();

    final Map<String, dynamic> qtyJson =
        Map<String, dynamic>.from(json['quantities'] ?? {});

    return OrderModel(
      orderCode: json['orderCode'] ?? '',
      products: productList,
      quantities: qtyJson.map(
        (key, value) => MapEntry(key, value as int),
      ),
      totalPayment: json['totalPayment'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

List<OrderModel> orderList = [];

Future<void> loadOrders() async {
  final prefs = await SharedPreferences.getInstance();

  final orderString = prefs.getString('orderList');

  if (orderString == null) return;

  final List decoded = jsonDecode(orderString);

  orderList.clear();

  orderList.addAll(
    decoded
        .map((item) => OrderModel.fromJson(item))
        .toList()
        .cast<OrderModel>(),
  );
}