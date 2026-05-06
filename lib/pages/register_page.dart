import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF7C9C0);
    const Color softPink = Color(0xFFFFF1EF);

    return Scaffold(
      backgroundColor: softPink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo_hara.png',
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Daftar dulu untuk menikmati semua fitur",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: name,
                    decoration: _inputDecoration(
                      "Nama",
                      Icons.person_outline,
                      softPink,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: email,
                    decoration: _inputDecoration(
                      "Email",
                      Icons.email_outlined,
                      softPink,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: _inputDecoration(
                      "Password",
                      Icons.lock_outline,
                      softPink,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: confirmPassword,
                    obscureText: true,
                    decoration: _inputDecoration(
                      "Confirm Password",
                      Icons.lock_reset_outlined,
                      softPink,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        if (password.text != confirmPassword.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password tidak sama"),
                            ),
                          );
                          return;
                        }

                        final response = await ApiService.register(
                          name: name.text,
                          email: email.text,
                          password: password.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message']),
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
                      },
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sudah punya akun? Login",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    Color fillColor,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}