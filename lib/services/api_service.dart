import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.glowMatchBaseUrl;

  static Future<Map<String, dynamic>> analyzeFaceBytes(
    Uint8List imageBytes,
  ) async {
    final uri = Uri.parse('$baseUrl/analyze-face');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'face.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal analyze face: ${response.body}');
    }
  }
}