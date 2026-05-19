import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/discount_model.dart';

class DiscountService {
  static const String baseUrl = String.fromEnvironment(
    'PRODUCT_BASE_URL',
    defaultValue: 'http://192.168.0.101:8000/api',
  );

  static Future<List<DiscountModel>> getDiscounts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/discounts'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json['data'] ?? [];

      return data
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Gagal mengambil discount: ${response.statusCode}',
    );
  }
}