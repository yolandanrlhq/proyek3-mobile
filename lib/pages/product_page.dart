import 'package:flutter/material.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'discount_page.dart';
import 'faq_page.dart';
import 'cart_page.dart';
import 'filter_by/category_page.dart';
import 'filter_by/color_page.dart';
import 'filter_by/type_page.dart';
import 'filter_by/price_page.dart';
import 'filter_by/material_page.dart';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isAscending = true;

  void sortProducts() {
    setState(() {
      if (isAscending) {
        products.sort((a, b) => a.name.compareTo(b.name));
      } else {
        products.sort((a, b) => b.name.compareTo(a.name));
      }
    });
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favoriteList.contains(product)) {
        favoriteList.remove(product);
      } else {
        favoriteList.add(product);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoritePage(favorites: favoriteList),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B8AF),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFF7C9C0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Product"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.discount),
              title: const Text("Discount"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiscountPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorite"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(favorites: favoriteList),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("FAQ"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqPage()),
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    ).then((_) {
                      setState(() {}); // refresh setelah balik dari cart
                    });
                  },
                ),

                // 🔥 BADGE ANGKA
                if (cartList.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2), // 🔽 dari 4 → 2
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14, // 🔽 dari 18 → 14
                        minHeight: 14,
                      ),
                      child: Text(
                        '${cartList.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9, // 🔽 dari 12 → 9
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // FILTER & SORT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FILTER
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "FILTER BY",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // ✅ FIX BUTTON FILTER
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (context) {
                            return const FilterDialog();
                          },
                        );
                      },
                      icon: const Icon(Icons.tune, color: Colors.black),
                      label: const Text(
                        "View Filter",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),

                // SORT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SORT BY",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "SORT BY",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 🔥 ASCENDING
                                  ListTile(
                                    title: const Text("Newest"),
                                    onTap: () {
                                      isAscending = true;
                                      sortProducts();
                                      Navigator.pop(context);
                                    },
                                  ),

                                  // 🔥 DESCENDING
                                  ListTile(
                                    title: const Text("Oldest"),
                                    onTap: () {
                                      isAscending = false;
                                      sortProducts();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.swap_vert, color: Colors.black),
                      label: const Text(
                        "Newest",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // GRID PRODUK
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  isFavorite: favoriteList.contains(product),
                  onFavorite: () => toggleFavorite(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// MODEL PRODUCT
////////////////////////////////////////////////////////////
class Product {
  final String name;
  final int price;
  final String image;

  Product({required this.name, required this.price, required this.image});
}

////////////////////////////////////////////////////////////
/// DATA PRODUK
////////////////////////////////////////////////////////////
List<Product> products = [
  Product(
    name: "Pashmina Rayon",
    price: 275000,
    image: "assets/images/hijab_model.jpg",
  ),
  Product(
    name: "Segi Empat Square",
    price: 275000,
    image: "assets/images/model_square.jpg",
  ),
  Product(
    name: "Pashmina Jersey",
    price: 275000,
    image: "assets/images/hijab_sport.jpg",
  ),
  Product(
    name: "Pashmina Viscose",
    price: 275000,
    image: "assets/images/viscos_hijab.jpg",
  ),
];

String formatRupiah(int number) {
  String result = number.toString();

  final buffer = StringBuffer();
  int counter = 0;

  for (int i = result.length - 1; i >= 0; i--) {
    buffer.write(result[i]);
    counter++;

    if (counter == 3 && i != 0) {
      buffer.write('.');
      counter = 0;
    }
  }

  return "RP${buffer.toString().split('').reversed.join()},00";
}
////////////////////////////////////////////////////////////
/// PRODUCT CARD
////////////////////////////////////////////////////////////
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name),
                const SizedBox(height: 4),
                Text(
  formatRupiah(product.price),
  style: const TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
  ),
),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FILTER DIALOG
////////////////////////////////////////////////////////////
class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "FILTER BY:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _btn(context, "CATEGORY"),
            _btn(context, "COLOR"),
            _btn(context, "TYPE"),
            _btn(context, "PRICE"),
            _btn(context, "MATERIAL"),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE6D5C3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.pop(context);

            if (text == "CATEGORY") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryPage()),
              );
            } else if (text == "COLOR") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ColorPage()),
              );
            } else if (text == "TYPE") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TypePage()),
              );
            } else if (text == "PRICE") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PricePage()),
              );
            } else if (text == "MATERIAL") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaterialPageFilter()),
              );
            }
          },
          child: Text(text, style: const TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}

List<Product> favoriteList = [];
List<Product> cartList = [];
