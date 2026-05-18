import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'product_page.dart';
import 'discount_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'order_status_page.dart';
import '../services/auth_guard.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  final String currentPage;

  const AppDrawer({
    super.key,
    required this.currentPage,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = "Guest";
  String userEmail = "";
  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    await AuthService.refreshUserData();
    await loadUser();
  }

  Future<void> loadUser() async {
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();

    final prefs = await SharedPreferences.getInstance();
    final imageString = prefs.getString('profileImage');

    if (!mounted) return;

    setState(() {
      userName = name ?? "Guest";
      userEmail = email ?? "";

      if (imageString != null && imageString.isNotEmpty) {
        profileImage = base64Decode(imageString);
      } else {
        profileImage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  onTap: () {
                    Navigator.pop(context);
                    AuthGuard.check(context, const ProfilePage());
                  },
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        profileImage != null ? MemoryImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 38,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _item(
            context,
            icon: Icons.home,
            title: "Home",
            page: const HomePage(),
          ),
          _item(
            context,
            icon: Icons.shopping_bag,
            title: "Product",
            page: const ProductPage(),
          ),
          _item(
            context,
            icon: Icons.receipt_long,
            title: "Pesanan",
            page: const OrderStatusPage(),
          ),
          _item(
            context,
            icon: Icons.discount,
            title: "Discount",
            page: const DiscountPage(),
          ),
          _item(
            context,
            icon: Icons.favorite,
            title: "Favorite",
            page: FavoritePage(favorites: favoriteList),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    final bool active = widget.currentPage == title;

    return ListTile(
      leading: Icon(
        icon,
        color: active ? Colors.black87 : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        if (active) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => page),
          (route) => route.isFirst,
        );
      },
    );
  }
}