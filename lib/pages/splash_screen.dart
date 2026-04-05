import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 🔥 Fade + Slide (kayak Shopee feel)
            final tween = Tween(
              begin: const Offset(0.0, 0.2), // dari bawah dikit
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color customPinkBackground = Color(0xFFF7C9C0);

    return Scaffold(
      backgroundColor: customPinkBackground,
      body: Center(
        child: Image.asset(
          'assets/images/logo_hara.png',
          width: 250,
        ),
      ),
    );
  }
}