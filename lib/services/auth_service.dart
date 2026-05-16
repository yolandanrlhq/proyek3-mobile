import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  static Future<void> saveSession({
    required int id,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
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
        return true;
      }

      await logout();
      return false;
    } catch (e) {
      print('VALIDATE ERROR: $e');
      await logout();
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('profileImage');
    await prefs.clear();
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