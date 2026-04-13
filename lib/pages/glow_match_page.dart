import 'package:flutter/material.dart';

void main() {
  runApp(const GlowMatchApp());
}

class GlowMatchApp extends StatelessWidget {
  const GlowMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glow Match',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F2F1),
        fontFamily: 'Sans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8C2BB)),
      ),
      home: const GlowMatchScanPage(),
    );
  }
}

class GlowMatchScanPage extends StatefulWidget {
  const GlowMatchScanPage({super.key});

  @override
  State<GlowMatchScanPage> createState() => _GlowMatchScanPageState();
}

class _GlowMatchScanPageState extends State<GlowMatchScanPage> {
  bool isScanning = false;

  // Dummy result sementara.
  final List<Color> recommendedColors = const [
    Color(0xFFDAB2A2),
    Color(0xFFE80019),
    Color(0xFF000000),
    Color(0xFF173F9D),
    Color(0xFFC8D4C0),
    Color(0xFFC96AA3),
    Color(0xFFE2D678),
  ];

  Future<void> _simulateScan() async {
    setState(() => isScanning = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => isScanning = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan selesai. Nanti hasil AI/PCD bisa dimunculkan di sini.'),
      ),
    );
  }

  void _showAnotherRecommendation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nanti tombol ini bisa ambil rekomendasi warna hijab lain dari AI.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScanCard(),
                    const SizedBox(height: 22),
                    const Text(
                      'YOUR BEST-HIJAB MATCH COLOUR!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFF3B2724),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: recommendedColors
                          .map((color) => _ColorCircle(color: color))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    _buildHijabPreviewCard(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showAnotherRecommendation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBC4BC),
                          foregroundColor: const Color(0xFF3A2320),
                          elevation: 4,
                          shadowColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'SEE ANOTHER RECOMMENDATION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Catatan: halaman ini masih versi sederhana untuk UI. Nanti bagian scan wajah pakai PCD dan hasil rekomendasi dari AI bisa dihubungkan ke backend atau model inference.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A6764),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFE8C2BB),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF6B5B57),
          ),
          const Expanded(
            child: Text(
              'GLOW MATCH',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Color(0xFF2E1E1A),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
            color: const Color(0xFF6B5B57),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DEDB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIGHT\nSKIN TONE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: Color(0xFF2E1E1A),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'CERAH MERONA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF6D5C59),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isScanning ? null : _simulateScan,
              icon: Icon(isScanning ? Icons.autorenew_rounded : Icons.face_retouching_natural),
              label: Text(isScanning ? 'Scanning wajah...' : 'Scan wajah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E1E1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHijabPreviewCard() {
    return Center(
      child: Container(
        width: 270,
        height: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'AI Preview',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B3632),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;

  const _ColorCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
