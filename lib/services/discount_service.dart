import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/discount_model.dart';

class DiscountService {

  static Future<List<DiscountModel>> getDiscounts() async {

    final response = await http.get(
      Uri.parse('hhttp://127.0.0.1:8000/api/discounts'),
    );

    if (response.statusCode == 200) {

      final json = jsonDecode(response.body);

      List data = json['data'];

      return data
          .map((e) => DiscountModel.fromJson(e))
          .toList();
    }

    throw Exception('Gagal mengambil discount');
  }
}