import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/product_service.dart';

enum GlowMatchViewState {
  choosing,
  cameraLive,
  preview,
  loading,
  result,
  error,
}

class GlowMatchScanPage extends StatefulWidget {
  const GlowMatchScanPage({super.key});

  @override
  State<GlowMatchScanPage> createState() => _GlowMatchScanPageState();
}

class _GlowMatchScanPageState extends State<GlowMatchScanPage>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  GlowMatchViewState _viewState = GlowMatchViewState.choosing;

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;

  XFile? _selectedXFile;
  Uint8List? _selectedImageBytes;

  bool _isCameraInitializing = false;
  bool _isCapturing = false;
  bool _isUsingFrontCamera = true;
  String? _errorMessage;

  String _skinToneLabel = '';
  String _skinToneSubtitle = '';
  List<Color> _recommendedColors = [];
  List<String> _recommendedColorNames = []; 
  List<dynamic> _filteredProducts = [];     
  String _recommendedHijabImage = 'assets/images/hijab_recommendation.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed &&
        _viewState == GlowMatchViewState.cameraLive) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _isCameraInitializing = true;
        _errorMessage = null;
      });

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan di device ini.');
      }

      CameraDescription selectedCamera;

      if (_isUsingFrontCamera) {
        selectedCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
      } else {
        selectedCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      }

      await _cameraController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController = controller;
      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _viewState = GlowMatchViewState.cameraLive;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _viewState = GlowMatchViewState.error;
        _errorMessage = 'Gagal membuka kamera: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isCameraInitializing = false;
      });
    }
  }

  Future<void> _openCameraLive() async {
    await _initCamera();
  }

  Future<void> _switchCamera() async {
    _isUsingFrontCamera = !_isUsingFrontCamera;
    await _initCamera();
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile file = await controller.takePicture();
      final Uint8List bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedXFile = file;
        _selectedImageBytes = bytes;
        _viewState = GlowMatchViewState.preview;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _viewState = GlowMatchViewState.error;
        _errorMessage = 'Gagal mengambil foto: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();

      setState(() {
        _selectedXFile = file;
        _selectedImageBytes = bytes;
        _viewState = GlowMatchViewState.preview;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _viewState = GlowMatchViewState.error;
        _errorMessage = 'Gagal memilih gambar: $e';
      });
    }
  }

  Future<void> _analyzeFace() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _viewState = GlowMatchViewState.loading;
    });

    try {
      final result =
          await ApiService.analyzeFaceBytes(_selectedImageBytes!);

      final colors = (result['recommended_colors'] as List)
          .map((e) => e.toString())
          .toList();

      final products = await ProductService.getProducts();

      final filtered = products.where((p) {
        final warna = (p['warna'] ?? '').toString().toLowerCase();

        return colors.any((c) => warna.contains(c.toLowerCase()));
      }).toList();

      final colorObjects =
        colors.map((c) => _mapColorNameToColor(c)).toList();

      setState(() {
        _skinToneLabel = result['skin_tone'].toString().toUpperCase();
        _skinToneSubtitle = 'HASIL ANALISIS';

        _recommendedColorNames = colors;
        _recommendedColors = colorObjects; // 👈 INI PENTING
        _filteredProducts = filtered;

        _viewState = GlowMatchViewState.result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _viewState = GlowMatchViewState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _showAnotherRecommendation() {
    setState(() {
      _recommendedColors = [
        const Color(0xFF8D6E63),
        const Color(0xFFC48B9F),
        const Color(0xFF7A8F57),
        const Color(0xFF7C6CB0),
        const Color(0xFF2F4F4F),
        const Color(0xFFE7C18A),
      ];
    });
  }

  void _retakePhoto() {
    setState(() {
      _selectedXFile = null;
      _selectedImageBytes = null;
      _skinToneLabel = '';
      _skinToneSubtitle = '';
      _recommendedColors = [];
      _errorMessage = null;
    });

    _openCameraLive();
  }

  void _backToHome() {
    setState(() {
      _selectedXFile = null;
      _selectedImageBytes = null;
      _skinToneLabel = '';
      _skinToneSubtitle = '';
      _recommendedColors = [];
      _errorMessage = null;
      _viewState = GlowMatchViewState.choosing;
    });
  }

  Widget _buildSelectedImage({
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (_selectedImageBytes == null) {
      return const Center(
        child: Text('Tidak ada gambar.'),
      );
    }

    return Image.memory(
      _selectedImageBytes!,
      width: double.infinity,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Color _mapColorNameToColor(String name) {
    switch (name.toLowerCase()) {
      case 'soft pink':
        return const Color(0xFFF8BBD0);
      case 'peach':
        return const Color(0xFFFFCCBC);
      case 'nude':
        return const Color(0xFFD7A98C);
      case 'baby blue':
        return const Color(0xFFBBDEFB);
      case 'dusty pink':
        return const Color(0xFFD8A7B1);
      case 'olive':
        return const Color(0xFF808000);
      case 'cream':
        return const Color(0xFFFFFDD0);
      case 'terracotta':
        return const Color(0xFFE2725B);
      case 'mocha':
        return const Color(0xFF967969);
      case 'maroon':
        return const Color(0xFF800000);
      case 'mustard':
        return const Color(0xFFFFDB58);
      case 'army green':
        return const Color(0xFF4B5320);
      case 'emerald':
        return const Color(0xFF50C878);
      case 'navy':
        return const Color(0xFF000080);
      case 'burgundy':
        return const Color(0xFF800020);
      case 'gold':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7C1BC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF3A2323)),
        title: const Text(
          'GLOW MATCH',
          style: TextStyle(
            color: Color(0xFF3A2323),
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewState) {
      case GlowMatchViewState.choosing:
        return _buildChoosingView();
      case GlowMatchViewState.cameraLive:
        return _buildCameraView();
      case GlowMatchViewState.preview:
        return _buildPreviewView();
      case GlowMatchViewState.loading:
        return _buildLoadingView();
      case GlowMatchViewState.result:
        return _buildResultView();
      case GlowMatchViewState.error:
        return _buildErrorView();
    }
  }

  Widget _buildChoosingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.face_retouching_natural,
                size: 90,
                color: Colors.pinkAccent,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Find your perfect glow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ambil foto wajah langsung dari kamera live atau upload dari galeri untuk melihat rekomendasi warna hijab terbaik.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _openCameraLive,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Buka Kamera Live'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Upload dari Galeri'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 16),
            const Text(
              'Catatan web: kamera live bergantung pada izin browser dan sebaiknya dijalankan di localhost atau HTTPS.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _cameraController;

    if (_isCameraInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 220,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 18,
                    left: 18,
                    right: 18,
                    child: Text(
                      'Posisikan wajah di dalam frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _backToHome,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _switchCamera,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.all(14),
                ),
                icon: const Icon(Icons.flip_camera_ios),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isCapturing ? null : _capturePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(_isCapturing ? 'Memotret...' : 'Capture'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    if (_selectedImageBytes == null) {
      return const Center(child: Text('Tidak ada gambar.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 420,
              width: double.infinity,
              child: _buildSelectedImage(),
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Preview wajah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pastikan wajah terlihat jelas, terang, dan tidak blur.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retakePhoto,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Ambil Ulang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _analyzeFace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Gunakan Foto'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text(
            'Analyzing your glow...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tunggu sebentar, kami sedang membaca tone wajahmu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEDDDD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: _buildSelectedImage(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _skinToneLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          height: 1.3,
                          color: Color(0xFF2D1B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _skinToneSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'YOUR BEST-HIJAB MATCH COLOUR!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF2D1B1B),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _recommendedColors
                  .map(
                    (color) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildColorDot(color),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                _recommendedHijabImage,
                height: 330,
                width: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAnotherRecommendation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAC1BB),
                foregroundColor: const Color(0xFF2D1B1B),
                elevation: 5,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'SEE ANOTHER RECOMENDATION',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _backToHome,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 24),
          const Text(
            'RECOMMENDED HIJAB FOR YOU',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filteredProducts.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada produk yang cocok'),
                    )
                  ]
                : _filteredProducts.map((product) {
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Image.network(
                            product['image_url'],
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Text(product['nama_produk']),
                          Text(product['harga']),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Oops, ada masalah',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _backToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}