import 'package:flutter/material.dart';
import 'contact_us_page.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8C8C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FaQ",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
        child: Column(
          children: [
            // Header: Greeting Box
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hai Sobat Hara! Ada yang bisa kami bantu?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactUsPage()),
                      );
                    },
                    child: const Text(
                      "Tanya lebih Lanjut ->",
                      style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Topik Utama Grid
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Topik utama", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 10),
            _buildMainTopics(),

            // List Pertanyaan (Kategori)
            _buildCategorySection(
              title: "Akun & Profil",
              iconColor: Colors.green.shade900,
              question: "Apakah alamat rumah boleh lebih dari satu?",
              answer: "Pastikan alamat diubah ketika anda akan mencekout untuk mempermudah proses pengiriman barang sampai ke tangan anda dengan selamat.",
            ),
            _buildCategorySection(
              title: "Layanan & Fitur",
              iconColor: Colors.blue.shade400,
              question: "Apakah bisa pilih jasa kirim?",
              answer: "Pada saat checkout, sistem akan menampilkan beberapa pilihan jasa pengiriman seperti J&T, JNE, dan SiCepat sesuai jangkauan area anda.",
            ),
            _buildCategorySection(
              title: "Pembayaran",
              iconColor: Colors.orange,
              question: "Kenapa proses pembayaran sering terjadi gagal transaksi?",
              answer: "Pastikan saldo anda cukup, gunakan data internet yang stabil, atau coba gunakan metode pembayaran lain seperti E-Wallet atau Transfer Bank.",
            ),

            const SizedBox(height: 20),

            // Footer (DIBERESIN BIAR CANTIK)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              color: const Color(0xFFF8C8C0).withOpacity(0.4),
              child: Column(
                children: [
                  const Text(
                    "\"Belum menemukan jawaban? Sampaikan pertanyaanmu kepada tim kami.\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIconButton(Icons.chat_bubble, Colors.green.shade600),
                      const SizedBox(width: 25),
                      _socialIconButton(Icons.camera_alt, const Color(0xFFE4405F)),
                      const SizedBox(width: 25),
                      _socialIconButton(Icons.music_note, Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI HELPER (Ditaruh di dalam class FaqPage) ---

  Widget _buildMainTopics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _topicItem(Icons.circle, Colors.green.shade900, "Akun & Profil"),
                const Divider(height: 1),
                _topicItem(Icons.circle, Colors.blue.shade400, "Layanan & Fitur"),
              ],
            ),
          ),
          Container(width: 1, height: 100, color: Colors.grey.shade300),
          Expanded(
            child: _topicItem(Icons.circle, Colors.orange, "Pembayaran"),
          ),
        ],
      ),
    );
  }

  Widget _topicItem(IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategorySection({required String title, required Color iconColor, required String question, required String answer}) {
    bool isExpanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Icon(isExpanded ? Icons.expand_less : Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      if (isExpanded) ...[
                        const Divider(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(answer, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialIconButton(IconData icon, Color color) {
    return InkWell(
      onTap: () => print("Opening Social Media..."),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}