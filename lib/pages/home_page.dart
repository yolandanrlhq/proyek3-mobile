import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_page.dart';
import 'discount_page.dart';
import 'favorite_page.dart';
import 'glow_match_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import '../services/auth_guard.dart';
import '../services/auth_service.dart';
import 'settings_page.dart';
import 'app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> bannerImages = [
    'assets/images/banner.jpg',
    'assets/images/gambar_home.jpeg',
    'assets/images/home.jpeg',
  ];

  String userName = "Guest";
  String userEmail = "";
  Uint8List? profileImage;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await AuthService.refreshUserData();
    await loadUser();

    await playMusic();
    showDiscountPopup();
  });
}

  Future<void> playMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.2);

      await _audioPlayer.play(
        AssetSource('music/audio_hara.mp3'),
      );

      debugPrint("Audio berhasil diputar");
    } catch (e) {
      debugPrint("ERROR AUDIO: $e");
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      debugPrint("Audio dihentikan");
    } catch (e) {
      debugPrint("ERROR STOP AUDIO: $e");
    }
  }

  void showDiscountPopup() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.25),
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 45),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F7),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black45,
                      ),
                    ),
                  ),

                  Container(
                    height: 58,
                    width: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7C9C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.black87,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "🎀 Special Promo!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Claim diskon 10% untuk belanja hijab favoritmu hari ini!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await stopMusic();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiscountPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7C9C0),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "CLAIM NOW",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final isLogin = await AuthService.isLoggedIn();

    if (!isLogin) {
      setState(() {
        userName = "Guest";
        userEmail = "";
        profileImage = null;
      });
      return;
    }

    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();

    final prefs = await SharedPreferences.getInstance();
    final imageString = prefs.getString('profileImage');

    setState(() {
      userName = name ?? "Guest";
      userEmail = email ?? "";

      if (imageString != null) {
        profileImage = base64Decode(imageString);
      } else {
        profileImage = null;
      }
    });
  }

  Future<void> _openProfilePage() async {
    await stopMusic();
    await AuthGuard.check(context, const ProfilePage());
    await loadUser();
  }

  Future<void> _openSettingsPage() async {
    await stopMusic();

    await AuthGuard.check(
      context,
      const SettingsPage(),
    );

    await loadUser();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF7C9C0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_hara.png',
          height: 100,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () async {
                    unreadCartCount.value = 0;

                    await stopMusic();

                    AuthGuard.check(
                      context,
                      const CartPage(),
                    );
                  },
                ),
                ValueListenableBuilder<int>(
                  valueListenable: unreadCartCount,
                  builder: (context, count, _) {
                    if (count == 0) return const SizedBox();

                    return Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// SLIDESHOW BANNER
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
                      viewportFraction: 1,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      enlargeCenterPage: false,
                    ),
                    items: bannerImages.map((image) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.08),
                                      Colors.black.withOpacity(0.45),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      await stopMusic();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE4E0),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "SHOP NOW!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// GLOW MATCH INFO CARD
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF8F7), Color(0xFFFDE4E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFF37B7B), size: 18),
            SizedBox(width: 8),
            Text(
              "FACE GLOW INSTANTLY!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.8,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Discover the perfect hijab colour\nfor your skin tone glow 💖",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorDot(const Color(0xFFE6A4A4)),
            _buildColorDot(const Color(0xFFD9B08C)),
            _buildColorDot(const Color(0xFFC8B6A6)),
            _buildColorDot(const Color(0xFFBFA2DB)),
            _buildColorDot(const Color(0xFFF7C9C0)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 16, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                "Tap the camera button below to begin",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 30),
            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(
                    icon: Icons.home,
                    onTap: () {},
                  ),

                  const SizedBox(width: 80),

                  _buildNavIcon(
                    icon: Icons.settings,
                    onTap: _openSettingsPage,
                  ),
                ],
              ),
            ),

            Positioned(
              top: -10,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await stopMusic();

                      AuthGuard.check(
                        context,
                        const GlowMatchScanPage(),
                      );
                    },
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color: primaryPink,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 35,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "GLOW MATCH",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      drawer: const AppDrawer(currentPage: "Home"),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFF7C9C0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black54,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}