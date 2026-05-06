import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final Uint8List? profileImage;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  final ImagePicker picker = ImagePicker();
  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
    selectedImage = widget.profileImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImage = bytes;
    });
  }

  void _saveProfile() {
    Navigator.pop(context, {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'profileImage': selectedImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF7C9C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryPink,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: const Color(0xFFFFE4DF),
                    backgroundImage: selectedImage != null
                        ? MemoryImage(selectedImage!)
                        : null,
                    child: selectedImage == null
                        ? const Icon(
                            Icons.person,
                            size: 65,
                            color: Colors.black87,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: primaryPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap foto untuk ganti profile picture",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 28),

            _buildTextField(
              controller: nameController,
              label: 'Nama',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: addressController,
              label: 'Alamat',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 34),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFFFF5F3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF7C9C0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFF7C9C0),
            width: 2,
          ),
        ),
      ),
    );
  }
}