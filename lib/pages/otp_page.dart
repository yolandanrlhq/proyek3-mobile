import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class OtpPage extends StatelessWidget {
  final String email;
  final TextEditingController otp = TextEditingController();

  OtpPage({super.key, required this.email});

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
              "Kode OTP sudah dikirim ke:\n$email",
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
                    email: email,
                    otpCode: otp.text,
                  );

                  print(response);

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
                  print(e);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              child: const Text("Verifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}