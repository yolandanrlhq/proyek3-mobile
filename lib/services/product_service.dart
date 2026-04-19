import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ProductService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  static Future<bool> addProduct({
    required String namaProduk,
    required String harga,
    required String stok,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Accept': 'application/json'},
      body: {
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      },
    );

    return response.statusCode == 201;
  }
}