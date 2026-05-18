import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otp = TextEditingController();

  int resendSeconds = 60;
  Timer? resendTimer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      resendSeconds = 60;
    });

    resendTimer?.cancel();

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  Future<void> resendOtp() async {
    try {
      final response = await ApiService.resendOtp(
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'].toString()),
        ),
      );

      startResendTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    otp.dispose();
    resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFF7C9C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi OTP"),
        backgroundColor: pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Kode OTP sudah dikirim ke:\n${widget.email}",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            TextField(
              controller: otp,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Kode OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await ApiService.verifyOtp(
                    email: widget.email,
                    otpCode: otp.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'].toString()),
                    ),
                  );

                  if (response['user'] != null) {
                    final user = response['user'];

                    await AuthService.saveSession(
                      id: user['id'],
                      name: user['name'],
                      email: user['email'],
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              child: const Text("Verifikasi"),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: canResend ? resendOtp : null,
              child: Text(
                canResend
                    ? "Kirim ulang OTP"
                    : "Kirim ulang OTP dalam $resendSeconds detik",
              ),
            ),
          ],
        ),
      ),
    );
  }
}