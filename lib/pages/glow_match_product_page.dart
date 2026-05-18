import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_page.dart';
import 'product_detail_page.dart';

class GlowMatchProductPage extends StatelessWidget {
  final List<dynamic> products;
  final List<String> colors;

  const GlowMatchProductPage({
    super.key,
    required this.products,
    required this.colors,
  });

  String formatRupiah(dynamic price) {
    final number = int.tryParse(price.toString()) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Produk'),
        backgroundColor: const Color(0xFFE7C1BC),
        foregroundColor: const Color(0xFF3A2323),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Belum ada produk yang cocok'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = (product['image_url'] ??
                        product['foto'] ??
                        product['gambar'] ??
                        product['image'] ??
                        '')
                    .toString();

                final nama = (product['nama_produk'] ??
                        product['nama'] ??
                        product['name'] ??
                        'Produk')
                    .toString();

                final harga = (product['harga'] ??
                        product['harga_jual'] ??
                        product['price'] ??
                        'Harga tidak tersedia')
                    .toString();
                final warna = (product['warna'] ?? '-').toString();

                final productModel = Product.fromJson(product);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: productModel),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              warna,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupiah(harga),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                );
              },
            ),
    );
  }
}