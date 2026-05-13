import 'package:flutter/material.dart';
import 'product_page.dart';
import 'cart_page.dart';
import 'checkout_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.pink[100],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (!cartList.value.contains(product)) {
                  cartList.value = [...cartList.value, product];
                } else {
                  cartList.notifyListeners();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${product.name} ditambahkan ke keranjang",
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                );
              },
              child: Container(
                width: 54,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE75480),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFFE75480),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                     builder: (_) => CheckoutPage(
  products: [product],
  quantities: Map<Product, int>.from({
    product: 1,
  }),
  allSelectedProducts: [product],
),
            
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE75480),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    48,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: product.gambars.isNotEmpty
                  ? PageView(
                      children:
                          product.gambars.map<Widget>((img) {
                        return Image.network(
                          img.toString(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              const Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        );
                      }).toList(),
                    )
                  : product.image.isNotEmpty
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              const Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                          ),
                        ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE75480),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Kode: ${product.kode}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          title: "Kategori",
                          value: product.kategori,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _InfoBox(
                          title: "Warna",
                          value: product.warna,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ukuran, Stok & Harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (product.ukurans.isNotEmpty)
                    Column(
                      children:
                          product.ukurans.map<Widget>((u) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          padding:
                              const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFEEF3),
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: Text(
                            "${u['ukuran']} - Stok: ${u['stok']} - ${formatRupiah(int.tryParse(u['harga'].toString()) ?? 0)}",
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("-"),

                  const SizedBox(height: 20),

                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.deskripsi,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
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

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value.isNotEmpty ? value : "-",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}