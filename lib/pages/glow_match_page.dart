import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  String _resultTitle = '';
  String _resultDescription = '';

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
    if (_selectedXFile == null || _selectedImageBytes == null) return;

    setState(() {
      _viewState = GlowMatchViewState.loading;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _resultTitle = 'Warm Glow Recommendation';
      _resultDescription =
          'Kulitmu terdeteksi cocok dengan tone warm-neutral. '
          'Rekomendasi awal: pilih base makeup dengan undertone warm beige, '
          'blush peach, dan highlighter gold champagne.';
      _viewState = GlowMatchViewState.result;
    });
  }

  void _retakePhoto() {
    setState(() {
      _selectedXFile = null;
      _selectedImageBytes = null;
      _resultTitle = '';
      _resultDescription = '';
      _errorMessage = null;
    });

    _openCameraLive();
  }

  void _backToHome() {
    setState(() {
      _selectedXFile = null;
      _selectedImageBytes = null;
      _resultTitle = '';
      _resultDescription = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Glow Match',
          style: TextStyle(fontWeight: FontWeight.w700),
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
            'Ambil foto wajah langsung dari kamera live atau upload dari galeri untuk melihat rekomendasi Glow Match.',
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildSelectedImage(height: 240),
            ),
          const SizedBox(height: 20),
          Text(
            _resultTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _resultDescription,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Awal',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text('• Foundation: Warm Beige / Natural Honey'),
                Text('• Blush: Peach Coral'),
                Text('• Lip color: Warm Nude / Rose Brown'),
                Text('• Highlighter: Champagne Gold'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _backToHome,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Selesai'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _retakePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Scan Lagi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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