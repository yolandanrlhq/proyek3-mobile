import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'dart:convert';
import 'dart:typed_data';

class AuthService {
  static Future<void> saveSession({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? address,
    String? foto,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('phone', phone ?? '');
    await prefs.setString('address', address ?? '');

    if (foto != null && foto.isNotEmpty) {
      await prefs.setString('profileImage', foto);
    } else {
      await prefs.remove('profileImage');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();

    final isLogin = prefs.getBool('isLoggedIn') ?? false;
    final userId = prefs.getInt('userId');
    final userEmail = prefs.getString('userEmail');

    print('LOCAL isLogin: $isLogin');
    print('LOCAL userId: $userId');
    print('LOCAL email: $userEmail');

    if (!isLogin || userId == null || userEmail == null) {
      await logout();
      return false;
    }

    try {
      final url = Uri.parse(
        '${AppConfig.productBaseUrl}/check-user/$userId?email=$userEmail',
      );

      print('CHECK URL: $url');

      final response = await http.get(url);

      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        await prefs.setString('userName', user['name'] ?? '');
        await prefs.setString('userEmail', user['email'] ?? '');
        await prefs.setString('phone', user['no_telepon'] ?? '');
        await prefs.setString('address', user['alamat'] ?? '');

        if (user['foto'] != null && user['foto'].toString().isNotEmpty) {
          await prefs.setString('profileImage', user['foto']);
        } else {
          await prefs.remove('profileImage');
        }

        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return true;
    }
  }

  static Future<void> refreshUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) return;

    final response = await http.get(
      Uri.parse('${AppConfig.productBaseUrl}/check-user/$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      await saveSession(
        id: user['id'],
        name: user['name'],
        email: user['email'],
        phone: user['no_telepon'],
        address: user['alamat'],
        foto: user['foto'],
      );
    }
  }

  static Future<bool> updateProfile({
    required int userId,
    required String name,
    required String phone,
    required String address,
    Uint8List? profileImage,
    bool removeImage = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.productBaseUrl}/update-profile'),
        body: {
          'user_id': userId.toString(),
          'name': name,
          'phone': phone,
          'address': address,
          'remove_image': removeImage ? '1' : '0',
          if (profileImage != null)
            'profile_image': base64Encode(profileImage),
        },
      );

      print('UPDATE STATUS: ${response.statusCode}');
      print('UPDATE BODY: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('UPDATE PROFILE ERROR: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('phone');
    await prefs.remove('address');
    await prefs.remove('profileImage');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}