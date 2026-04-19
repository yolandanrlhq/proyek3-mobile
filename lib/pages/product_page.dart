import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  bool isLoading = true;

  // ✅ FIX UTAMA
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final String baseUrl = const String.fromEnvironment(
        'BASE_URL',
        // ⚠️ kalau emulator Android pakai ini
        defaultValue: 'http://10.0.2.2:8000/api',
      );

      final response = await http.get(Uri.parse('$baseUrl/produk'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productData = data['data'] ?? [];

        setState(() {
          products =
              productData.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Gagal memuat data produk (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF7C9C0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Hara Hijabneeds",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DiscountPage()),
                );
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
                    builder: (context) =>
                        FavoritePage(favorites: favoriteList),
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
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartPage()),
                    ).then((_) {
                      setState(() {});
                    });
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

      body: Column(
        children: [
          const SizedBox(height: 16),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

class Product {
  final String name;
  final int price;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      image: json['image'] ?? '',
    );
  }
}

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
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Text(product.name),
          Text(formatRupiah(product.price)),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: onFavorite,
          ),
        ],
      ),
    );
  }
}

List<Product> favoriteList = [];
ValueNotifier<List<Product>> cartList = ValueNotifier([]);