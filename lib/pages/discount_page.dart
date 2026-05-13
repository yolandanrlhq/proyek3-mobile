import 'package:flutter/material.dart';
import 'product_page.dart';
import 'app_drawer.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      drawer: const AppDrawer(currentPage: "Discount"),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7C9C0),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Discount",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                          "Discount 10% applied! Happy Shopping...",
                        ),
                        backgroundColor: Color(0xFFF7C9C0),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 700), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductPage(),
                        ),
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: const Color(0xFFF7C9C0).withOpacity(0.3),
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
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7C9C0),
                                    borderRadius: BorderRadius.circular(15),
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
                                    color: Colors.grey,
                                  ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
    bool replace = false,
    bool isCurrentPage = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentPage ? Colors.black87 : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        if (isCurrentPage) return;

        if (replace) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        }
      },
    );
  }
}