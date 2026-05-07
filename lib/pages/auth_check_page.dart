import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final isLogin = await AuthService.isLoggedIn();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLogin ? const HomePage() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color softPink = Color(0xFFFFF1EF);

    return Scaffold(
      backgroundColor: softPink,
      body: Center(
        child: Image.asset(
          'assets/images/logo_hara.png',
          height: 130,
        ),
      ),
    );
  }
}