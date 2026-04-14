import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const HaraApp());
}

class HaraApp extends StatelessWidget {
  const HaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Jakarta', // atau 'Poppins'
      ),
      home: const SplashScreen(), // ⬅️ arahkan ke splash
    );
  }
}