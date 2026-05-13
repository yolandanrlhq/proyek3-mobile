import 'package:flutter/material.dart';

import 'home_page.dart';
import 'product_page.dart';
import 'discount_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import '../services/auth_guard.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({
    super.key,
    required this.currentPage,
  });

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
                  child: const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
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
    final bool active = currentPage == title;

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}