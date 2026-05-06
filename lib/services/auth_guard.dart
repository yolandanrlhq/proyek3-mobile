import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import 'auth_service.dart';

class AuthGuard {
  static Future<void> check(
    BuildContext context,
    Widget page,
  ) async {
    final isLogin = await AuthService.isLoggedIn();

    if (!isLogin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}