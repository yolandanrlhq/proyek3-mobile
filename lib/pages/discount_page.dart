import 'package:flutter/material.dart';
// Pastikan import halaman produkmu di sini
// import 'package:proyek3_mobile/pages/product_page.dart'; 
import 'product_page.dart';
class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8C8C0), // Warna pink peach sesuai desain
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Discount",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- BAGIAN YANG DIPERBAIKI (START) ---
            
            // Container luar hanya untuk padding & alignment
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8), // Sedikit napas di atas/bawah
              child: Material(
                color: Colors.transparent, // Transparan biar ClipRRect kelihatan
                child: InkWell(
                  // 1. Logika Klik & Navigasi
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Discount 10% applied! Happy Shopping..."),
                        backgroundColor: Color(0xFFF8C8C0),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // Navigasi ke ProductPage
                    Future.delayed(const Duration(milliseconds: 700), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductPage()),
                      );
                    });
                  },
                  // Efek klik Material (bulat sesuai card)
                  borderRadius: BorderRadius.circular(20),
                  splashColor: const Color(0xFFF8C8C0).withOpacity(0.3),
                  
                  // Container Utama dengan Bayangan Rapi
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background wajib putih biar shadow kelihatan
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // Ini bayangan yang diperhalus
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // Lebih halus
                          spreadRadius: 2, // Sebar lebih luas
                          blurRadius: 12, // Lebih nge-blur (halus)
                          offset: const Offset(0, 5), // Geser sedikit ke bawah
                        ),
                      ],
                      // Hapus border abu-abu yang kemarin biar makin halus
                    ),
                    child: Row(
                      children: [
                        // Bagian Gambar (Kiri) - Tetap Rapi dengan ClipRRect
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/banner.jpg', // SESUAIKAN PATH GAMBARMU
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        // Bagian Teks Promo (Kanan)
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center, // Centered teks
                              children: [
                                Text(
                                  "FLASH SALE!",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045, // Ukuran font ikut lebar layar
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  "10%",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.11, // Sedikit diperbesar
                                    fontWeight: FontWeight.w900, // Lebih tebal
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
                                
                                // Tombol USE NOW (Sekarang jadi bagian dari Column, biar makin rapi)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8C8C0), // Peach
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    "USE NOW",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900, // Sangat tebal
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "SPECIAL 2.2 ALL VARIAN",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
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
            
            // --- BAGIAN YANG DIPERBAIKI (END) ---
          ],
        ),
      ),
    );
  }
}