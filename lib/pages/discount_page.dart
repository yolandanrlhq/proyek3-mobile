import 'package:flutter/material.dart';
import 'product_page.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'faq_page.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔥 DRAWER (BARU)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF7C9C0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Hara Hijabneeds",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Welcome back!"),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Product"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.discount),
              title: const Text("Discount"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorite"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritePage(favorites: favoriteList),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("FAQ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqPage()),
                );
              },
            ),
          ],
        ),
      ),

      // 🔥 APPBAR (DITAMBAH MENU ICON)
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8C8C0),
        elevation: 0,

        // 🔥 BUKA DRAWER
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: const Text(
          "Discount",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Discount 10% applied! Happy Shopping..."),
                        backgroundColor: Color(0xFFF8C8C0),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 700), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductPage()),
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor:
                      const Color(0xFFF8C8C0).withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/banner.jpg',
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "FLASH SALE!",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  "10%",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.11,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  "DISCOUNT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8C8C0),
                                    borderRadius:
                                        BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    "USE NOW",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "SPECIAL 2.2 ALL VARIAN",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}