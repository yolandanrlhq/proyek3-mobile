import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const HaraApp());
}

class HaraApp extends StatelessWidget {
  const HaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ⬅️ arahkan ke splash
    );
  }
}