import 'package:flutter/material.dart';
import 'product_page.dart';
import 'app_drawer.dart';

class FavoritePage extends StatelessWidget {
  final List<Product> favorites;

  const FavoritePage({
    super.key,
    required this.favorites,
  });

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
            icon: const Icon(
              Icons.menu,
              color: Colors.black87,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: Text(
          "My Wishlist (${favorites.length} items)",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: favorites.isEmpty
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
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final item = favorites[index];

                      return Container(
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(14),

                                  child: item.image.isNotEmpty
                                      ? Image.network(
                                          item.image,
                                          width: double.infinity,
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
                                          alignment:
                                              Alignment.center,
                                          child: const Icon(
                                            Icons.image,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                item.name,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    formatRupiah(item.price),
                                    style: const TextStyle(
                                      color: Colors.pink,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
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
                        backgroundColor:
                            const Color(0xFFF7C9C0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: () {
                        cartList.value.addAll(favorites);
                        cartList.notifyListeners();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "All items moved to cart 🛒",
                            ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
    bool isCurrentPage = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentPage
            ? Colors.black87
            : Colors.black54,
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: isCurrentPage
              ? FontWeight.bold
              : FontWeight.w500,
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