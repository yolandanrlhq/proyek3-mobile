import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_drawer.dart';
import 'cart_page.dart';
import '../config/app_config.dart';
import 'product_detail_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isLoading = true;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    print('BASE URL = ${AppConfig.productBaseUrl}');
    print('REQUEST URL = ${AppConfig.productBaseUrl}/produk');

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.productBaseUrl}/produk'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('STATUS CODE = ${response.statusCode}');
      print('BODY = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productData = data['data'] ?? [];

        setState(() {
          products = productData.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('ERROR FETCH PRODUCT = $e');
      setState(() => isLoading = false);
    }
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favoriteList.contains(product)) {
        favoriteList.remove(product);
      } else {
        favoriteList.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),

  drawer: const AppDrawer(currentPage: "Product"),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7C9C0),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Product",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartPage(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.68,
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
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Widget page,
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}

class Product {
  final String name;
  final int price;
  final String image;
  final String kode;
  final String kategori;
  final String warna;
  final String deskripsi;
  final List<dynamic> ukurans;
  final List<dynamic> gambars;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.kode,
    required this.kategori,
    required this.warna,
    required this.deskripsi,
    required this.ukurans,
    required this.gambars,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      kode: json['kode_produk'] ?? '',
      kategori: json['kategori'] ?? '',
      warna: json['warna'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      ukurans: json['ukurans'] ?? [],
      gambars: json['gambars'] ?? [],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.image.isNotEmpty
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 42),
                          )
                        : const Center(
                            child: Icon(Icons.image_not_supported, size: 42),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.pink,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      color: Color(0xFFE75480),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.kategori,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE75480),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Product> favoriteList = [];
ValueNotifier<List<Product>> cartList = ValueNotifier([]);