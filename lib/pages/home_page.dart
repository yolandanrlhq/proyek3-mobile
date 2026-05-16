import 'dart:convert';
import 'dart:typed_data';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "Guest";
  String userEmail = "";
  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();
    loadUser();
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
    await AuthGuard.check(context, const ProfilePage());
    await loadUser();
  }

Future<void> _openSettingsPage() async {
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
                  onPressed: () {
                    AuthGuard.check(context, const CartPage());
                  },
                ),
                ValueListenableBuilder<List<Product>>(
                  valueListenable: cartList,
                  builder: (context, cart, _) {
                    if (cart.isEmpty) return const SizedBox();

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
                          '${cart.length}',
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
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: Image.asset(
                      'assets/images/banner.jpg',
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: ElevatedButton(
                    onPressed: () {
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "FACE GLOW INSTANTLY!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "LET'S TRY THE GLOW MATCH FEATURE\nAND FIND THE BEST HIJAB COLOUR!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                      ),
                      child: const Center(
                        child: Text("Color Swatches & Model Image"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
                    onTap: () {
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

      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF8F7),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFF7C9C0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _openProfilePage();
                    },
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: profileImage != null
                          ? ClipOval(
                              child: Image.memory(
                                profileImage!,
                                fit: BoxFit.cover,
                                width: 68,
                                height: 68,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 38,
                              color: Colors.black,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  if (userName == "Guest" || userEmail.isEmpty) ...[
                    const Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Hara Hijabneeds",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            _buildDrawerItem(
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _buildDrawerItem(
              icon: Icons.shopping_bag,
              title: "Product",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductPage(),
                  ),
                );
              },
            ),

            _buildDrawerItem(
              icon: Icons.discount,
              title: "Discount",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiscountPage(),
                  ),
                );
              },
            ),

            _buildDrawerItem(
              icon: Icons.favorite,
              title: "Favorite",
              onTap: () {
                Navigator.pop(context);
                AuthGuard.check(
                  context,
                  FavoritePage(favorites: favoriteList),
                );
              },
            ),
          ],
        ),
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