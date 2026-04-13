import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8C8C0), // Peach khas Hara Hijab
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Hubungi Kami",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Punya pertanyaan atau kendala?\nTim kami siap membantu!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 30),
            
            // Pilihan Hubungi via WA
            _buildContactMethod(
              icon: Icons.chat_rounded,
              title: "WhatsApp Admin",
              subtitle: "Respon cepat (08.00 - 20.00)",
              color: Colors.green.shade600,
              onTap: () => print("Buka WA Admin..."),
            ),
            
            const SizedBox(height: 16),
            
            // Pilihan via Instagram
            _buildContactMethod(
              icon: Icons.camera_alt_rounded,
              title: "Instagram",
              subtitle: "@hara_hijabneeds",
              color: const Color(0xFFE4405F),
              onTap: () => print("Buka Instagram..."),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              "Atau tinggalkan pesan di sini:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Form Pesan Singkat
            TextField(
              decoration: InputDecoration(
                hintText: "Tulis pertanyaanmu...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8C8C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Kirim Pesan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Card Pilihan Hubungi
  Widget _buildContactMethod({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}