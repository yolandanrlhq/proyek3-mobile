import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'product_page.dart';
import 'discount_page.dart';
import 'favorite_page.dart';
import 'faq_page.dart';
import 'home_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String name = "Hara Hijabneeds User";
  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final imageString = prefs.getString('profileImage');

    setState(() {
      name = prefs.getString('name') ?? "Hara Hijabneeds User";

      if (imageString != null) {
        profileImage = base64Decode(imageString);
      }
    });
  }

  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFF7C9C0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImage != null
                      ? MemoryImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.black87,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text("Welcome back!"),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => _goTo(context, const HomePage()),
          ),

          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Product"),
            onTap: () => _goTo(context, const ProductPage()),
          ),

          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text("Discount"),
            onTap: () => _goTo(context, const DiscountPage()),
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favorite"),
            onTap: () {
              _goTo(
                context,
                FavoritePage(favorites: favoriteList),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("FAQ"),
            onTap: () => _goTo(context, const FaqPage()),
          ),
        ],
      ),
    );
  }
}