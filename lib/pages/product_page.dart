import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_drawer.dart';
import 'cart_page.dart';
import '../config/app_config.dart';
import 'product_detail_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isLoading = true;
  List<Product> products = [];
  
  // State untuk menampung data yang sudah di-filter & sort
  List<Product> filteredProducts = [];

  // State parameter filter & sort terpilih
  String? _selectedCategory;
  String? _selectedColor;
  String? _selectedSize;
  int? _selectedPrice;
  String _currentSort = "Newest";

  // Data master opsi filter sesuai isi database tabel Anda
  final List<String> _categories = ["Instant Syar'i", "Square Hijab", "Pashmina"];
  final List<String> _colors = [
    "Ivory", "Sky Blue", "Taupe", "Dark Choco", "Black", "Shadow",
    "Grey Latte", "Walnute", "Dark Brown", "Pearl", "Charcoal",
    "Smoke", "Dusty Pink", "Navy", "Biscuit", "Soft Yellow",
    "Golden Brown", "Grey Seal", "Latte", "Coral", "Peach"
  ];
  final List<String> _sizes = ["S", "M", "L"];
  final List<int> _prices = [60000, 80000, 85000, 150000];

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
          // Terapkan filter & sort awal setelah data berhasil dimuat
          _applyFilterAndSort();
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('ERROR FETCH PRODUCT = $e');
      setState(() => isLoading = false);
    }
  }

  // Fungsi Logika Memproses Filter dan Sorting Data
  void _applyFilterAndSort() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchCategory = _selectedCategory == null || product.kategori == _selectedCategory;
        final matchColor = _selectedColor == null || product.warna == _selectedColor;
        
        // Pengecekan ukuran di dalam array ukurans produk
        bool matchSize = _selectedSize == null;
        if (_selectedSize != null) {
          matchSize = product.ukurans.any((u) => u['ukuran'] == _selectedSize);
        }

        // Filter harga di bawah atau sama dengan opsi terpilih
        final matchPrice = _selectedPrice == null || product.price <= _selectedPrice!;

        return matchCategory && matchColor && matchSize && matchPrice;
      }).toList();

      // Logika Pengurutan (Sorting)
      if (_currentSort == "Newest") {
        // Jika di database Anda tidak ada kolom tanggal, pengurutan dibalik berdasarkan kode produk (ID) terbaru
        filteredProducts.sort((a, b) => b.kode.compareTo(a.kode));
      } else if (_currentSort == "Harga Terendah") {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (_currentSort == "Harga Tertinggi") {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  // --- POPUP MODAL DIALOG UNTUK FILTER BY (Sesuai Gambar UI) ---
  // --- POPUP MODAL DIALOG UNTUK FILTER BY ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            width: MediaQuery.of(context).size.width * 0.8,
            // HAPUS mainAxisSize dari sini! Container tidak punya properti ini.
            child: Column(
              mainAxisSize: MainAxisSize.min, // Sifat ini seharusnya ada di sini (sudah benar)
              children: [
                const Text(
                  "FILTER BY:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilterMenuButton("CATEGORY", () => _showSubFilterOptions("Category", _categories)),
                _buildFilterMenuButton("COLOR", () => _showSubFilterOptions("Color", _colors)),
                _buildFilterMenuButton("TYPE / SIZE", () => _showSubFilterOptions("Size", _sizes)),
                _buildFilterMenuButton("PRICE", () => _showSubFilterOptions("Price", _prices.map((e) => "≤ ${formatRupiah(e)}").toList())),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedColor = null;
                      _selectedSize = null;
                      _selectedPrice = null;
                    });
                    _applyFilterAndSort();
                    Navigator.pop(context);
                  },
                  child: const Text("Reset Filter", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterMenuButton(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFBF1EB),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // Modal Sub-Opsi untuk memilih item spesifik di dalam kategori filter
  void _showSubFilterOptions(String type, List<String> options) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select $type", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        setState(() {
                          if (type == "Category") _selectedCategory = option;
                          if (type == "Color") _selectedColor = option;
                          if (type == "Size") _selectedSize = option;
                          if (type == "Price") _selectedPrice = _prices[index];
                        });
                        _applyFilterAndSort();
                        Navigator.pop(context); // Tutup BottomSheet
                        Navigator.pop(context); // Tutup Filter Dialog Utama
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL BOTTOM SHEET UNTUK SORT BY ---
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("SORT BY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Newest"),
              trailing: _currentSort == "Newest" ? const Icon(Icons.check, color: Color(0xFFE75480)) : null,
              onTap: () {
                setState(() => _currentSort = "Newest");
                _applyFilterAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text("Harga Terendah"),
              trailing: _currentSort == "Harga Terendah" ? const Icon(Icons.check, color: Color(0xFFE75480)) : null,
              onTap: () {
                setState(() => _currentSort = "Harga Terendah");
                _applyFilterAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text("Harga Tertinggi"),
              trailing: _currentSort == "Harga Tertinggi" ? const Icon(Icons.check, color: Color(0xFFE75480)) : null,
              onTap: () {
                setState(() => _currentSort = "Harga Tertinggi");
                _applyFilterAndSort();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void toggleFavorite(Product product) async {
    setState(() {
      final exists = favoriteList.any((item) => item.kode == product.kode);

      if (exists) {
        favoriteList.removeWhere((item) => item.kode == product.kode);
      } else {
        favoriteList.add(product);
      }
    });

    await saveCartAndFavorite();
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
          ValueListenableBuilder<int>(
            valueListenable: unreadCartCount,
            builder: (context, count, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () async {
                      final loggedIn = await AuthService.isLoggedIn();

                      if (!loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(),
                          ),
                        );
                        return;
                      }

                      unreadCartCount.value = 0;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- BAR ATAS: FILTER & SORT YANG LEBIH EYE-CATCHING ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30), // Membuat bar melengkung halus
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7C9C0).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5), // Efek bayangan lembut di bawah bar
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Tombol Filter
                          Expanded(
                            child: InkWell(
                              onTap: _showFilterDialog,
                              borderRadius: BorderRadius.circular(25),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFEEF3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFFE75480)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Filter By",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Colors.black87,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Garis Pembatas Tengah (Divider)
                          VerticalDivider(
                            color: Colors.grey.withOpacity(0.2),
                            thickness: 1.5,
                            indent: 5,
                            endIndent: 5,
                          ),
                          
                          // Tombol Sort
                          Expanded(
                            child: InkWell(
                              onTap: _showSortBottomSheet,
                              borderRadius: BorderRadius.circular(25),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFEEF3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.swap_vert_rounded, size: 16, color: Color(0xFFE75480)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _currentSort,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- GRID DATA PRODUK ---
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "Produk tidak ditemukan.",
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];

                            return ProductCard(
                              product: product,
                              isFavorite: favoriteList.any((item) => item.kode == product.kode),
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'kode_produk': kode,
      'kategori': kategori,
      'warna': warna,
      'deskripsi': deskripsi,
      'ukurans': ukurans,
      'gambars': gambars,
    };
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

Future<void> saveCartAndFavorite() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'cartList',
    jsonEncode(
      cartList.value.map((item) => item.toJson()).toList(),
    ),
  );

  await prefs.setString(
    'favoriteList',
    jsonEncode(
      favoriteList.map((item) => item.toJson()).toList(),
    ),
  );

  await prefs.setString(
    'selectedSizeCart',
    jsonEncode(selectedSizeCart),
  );
}

Future<void> loadCartAndFavorite() async {
  final prefs = await SharedPreferences.getInstance();

  final cartString = prefs.getString('cartList');
  final favoriteString = prefs.getString('favoriteList');
  final selectedSizeString = prefs.getString('selectedSizeCart');

  if (cartString != null) {
    final List decoded = jsonDecode(cartString);

    cartList.value = decoded
        .map((item) => Product.fromJson(item))
        .toList()
        .cast<Product>();
  }

  if (favoriteString != null) {
    final List decoded = jsonDecode(favoriteString);

    favoriteList.clear();
    favoriteList.addAll(
      decoded
          .map((item) => Product.fromJson(item))
          .toList()
          .cast<Product>(),
    );
  }

  if (selectedSizeString != null) {
    final Map<String, dynamic> decoded =
        jsonDecode(selectedSizeString);

    selectedSizeCart.clear();

    decoded.forEach((key, value) {
      selectedSizeCart[key] = value.toString();
    });
  }
}

List<Product> favoriteList = [];
ValueNotifier<List<Product>> cartList = ValueNotifier([]);
ValueNotifier<int> unreadCartCount = ValueNotifier(0);
Map<String, String> selectedSizeCart = {};