import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

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
                      onPressed: isLoading ? null : () async {
                        setState(() {
                          isLoading = true;
                        });

                        if (password.text != confirmPassword.text) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Password tidak sama")),
                          );
                          return;
                        }

                        final response = await ApiService.register(
                          name: name.text,
                          email: email.text,
                          password: password.text,
                        );

                        print(response);
                        
                        if (response['success'] == true) {

                          // popup sukses
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Color(0xFFFFF1EF),
                                      child: Icon(
                                        Icons.mark_email_read_rounded,
                                        color: Colors.pink,
                                        size: 32,
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    const Text(
                                      "OTP Berhasil Dikirim ✨",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Kode verifikasi sudah dikirim ke ${email.text}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          // delay biar popup keliatan dulu
                          await Future.delayed(const Duration(seconds: 2));

                          Navigator.pop(context); // tutup dialog

                          setState(() {
                            isLoading = false;
                          });

                          if (!mounted) return;
                          // transisi smooth
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (_, animation, __) => OtpPage(
                                email: email.text,
                              ),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );

                        } else {

                          setState(() {
                            isLoading = false;
                          });


                          // kalau gagal kirim otp
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? "OTP gagal dikirim"),
                            ),
                          );
                        }
                      },
                      child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            "REGISTER",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text(
                        "Login dengan Google",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFF7C9C0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final googleSignIn = GoogleSignIn.instance;

                          final account = await googleSignIn.authenticate();

                          final response = await ApiService.loginWithGoogle(
                            name: account.displayName ?? 'Google User',
                            email: account.email,
                            googleId: account.id,
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? 'Login Google gagal'),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Google login error: $e')),
                          );
                        }
                      },
                    ),
                  ),

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