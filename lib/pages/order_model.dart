import 'product_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // Memastikan integrasi dengan session login Anda

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

  // Mengubah objek objek OrderModel menjadi format Map/JSON untuk SharedPreferences
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

  // Membaca data JSON dari SharedPreferences kembali menjadi bentuk objek OrderModel
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

// Global state list yang diakses oleh OrderStatusPage
List<OrderModel> orderList = [];

// --- MENYIMPAN PESANAN BERDASARKAN SESSION EMAIL PENGGUNA ---
Future<void> saveOrders() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Mengambil session email dari AuthService Anda (menggunakan key 'userEmail')
  final String? email = await AuthService.getUserEmail(); 

  // Menentukan Key unik penyimpanan local, jika kosong otomatis masuk ke kelompok 'guest'
  String userKey = (email != null && email.isNotEmpty) ? email : 'guest';
    
  await prefs.setString(
    'orderList_$userKey',
    jsonEncode(orderList.map((e) => e.toJson()).toList()),
  );
}

// --- MEMUAT PESANAN BERDASARKAN SESSION EMAIL PENGGUNA ---
Future<void> loadOrders() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Mengambil session email dari AuthService Anda
  final String? email = await AuthService.getUserEmail(); 
  
  String userKey = (email != null && email.isNotEmpty) ? email : 'guest';

  final orderString = prefs.getString('orderList_$userKey');

  // Proteksi Krusial: Jika data local kosong, langsung hapus sisa data di memori 
  // agar histori akun sebelumnya tidak bocor atau menyangkut di layar.
  if (orderString == null) {
    orderList.clear();
    return;
  }

  final List decoded = jsonDecode(orderString);

  orderList.clear();
  orderList.addAll(
    decoded
        .map((item) => OrderModel.fromJson(item))
        .toList()
        .cast<OrderModel>(),
  );
}