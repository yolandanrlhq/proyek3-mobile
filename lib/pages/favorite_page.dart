import 'package:flutter/material.dart';
import 'product_page.dart';
import 'product_detail_page.dart';
import 'app_drawer.dart';

class FavoritePage extends StatefulWidget {
  final List<Product> favorites;

  const FavoritePage({
    super.key,
    required this.favorites,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  void unlikeProduct(Product product) async {
    setState(() {
      favoriteList.removeWhere((item) => item.kode == product.kode);
    });

    await saveCartAndFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      drawer: const AppDrawer(currentPage: "Favorite"),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7C9C0),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "My Wishlist (${favoriteList.length} items)",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: favoriteList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada favorit",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: favoriteList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final item = List<Product>.from(favoriteList)[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: item),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        child: item.image.isNotEmpty
                                            ? Image.network(
                                                item.image,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    alignment:
                                                        Alignment.center,
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.image),
                                              ),
                                      ),

                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: InkWell(
                                          onTap: () {
                                            unlikeProduct(item);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  formatRupiah(item.price),
                                  style: const TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7C9C0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        for (final item in favoriteList) {
                          if (!cartList.value.contains(item)) {
                            cartList.value.add(item);
                          }
                        }

                        cartList.notifyListeners();
                        await saveCartAndFavorite();
                        unreadCartCount.value = 1;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("All items moved to cart 🛒"),
                          ),
                        );
                      },
                      child: const Text(
                        "MOVE ALL TO CART",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}