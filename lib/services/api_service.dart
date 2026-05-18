import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static Future<List<dynamic>> getGlowMatchHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analisis/history/$userId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception(
        'Gagal mengambil history Glow Match: ${response.statusCode} ${response.body}',
      );
    }
  }

  static String get glowMatchBaseUrl => AppConfig.glowMatchBaseUrl;

  static String get baseUrl => AppConfig.productBaseUrl;

  static Future<Map<String, dynamic>> analyzeFaceBytes(
    Uint8List imageBytes,
  ) async {
    final uri = Uri.parse('$glowMatchBaseUrl/analyze-face');

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

  static Future<void> saveGlowMatchHistory({
    required int userId,
    required String warnaKulit,
    required List<String> rekomendasiWarna,
    required double brightness,
    required double labL,
    required Uint8List imageBytes,
  }) async {
    final url = Uri.parse('$baseUrl/analisis');

    final request = http.MultipartRequest('POST', url);

    request.fields.addAll({
      'user_id': userId.toString(),
      'warna_kulit': warnaKulit,
      'rekomendasi_warna': rekomendasiWarna.join(','),
      'brightness': brightness.toString(),
      'lab_l': labL.toString(),
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        imageBytes,
        filename: 'glow_match_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Gagal menyimpan history Glow Match: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginWithGoogle({
    required String name,
    required String email,
    required String googleId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/google-login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'google_id': googleId,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'email': email,
      },
    );

    return jsonDecode(response.body);
  }
}