import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Hara Hijabneeds User";
  String email = "user@hara-hijabneeds.com";
  String phone = "";
  String address = "";

  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('userName') ?? name;
      email = prefs.getString('userEmail') ?? email;
      phone = prefs.getString('phone') ?? phone;
      address = prefs.getString('address') ?? address;

      final imageString = prefs.getString('profileImage');

      if (imageString != null) {
        profileImage = base64Decode(imageString);
      }
    });
  }

  Future<void> saveProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
    required String newAddress,
    Uint8List? newImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', newName);
    await prefs.setString('email', newEmail);
    await prefs.setString('phone', newPhone);
    await prefs.setString('address', newAddress);

    if (newImage != null) {
      final imageString = base64Encode(newImage);
      await prefs.setString('profileImage', imageString);
    }

    setState(() {
      name = newName;
      email = newEmail;
      phone = newPhone;
      address = newAddress;
      profileImage = newImage;
    });
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          name: name,
          email: email,
          phone: phone,
          address: address,
          profileImage: profileImage,
        ),
      ),
    );

    if (result != null) {
      await saveProfile(
        newName: result['name'],
        newEmail: result['email'],
        newPhone: result['phone'],
        newAddress: result['address'],
        newImage: result['profileImage'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF7C9C0);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,

                    backgroundImage: profileImage != null
                        ? MemoryImage(profileImage!)
                        : null,

                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.black87,
                          )
                        : null,
                  ),

                  const SizedBox(height: 14),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Elegant hijab lover",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildProfileItem(
              icon: Icons.badge_outlined,
              title: "Nama",
              value: name,
            ),

            _buildProfileItem(
              icon: Icons.email_outlined,
              title: "Email",
              value: email,
            ),

            _buildProfileItem(
              icon: Icons.phone_outlined,
              title: "Nomor Telepon",
              value: phone.isEmpty ? "Belum ditambahkan" : phone,
            ),

            _buildProfileItem(
              icon: Icons.location_on_outlined,
              title: "Alamat",
              value: address.isEmpty ? "Belum ditambahkan" : address,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: _goToEditProfile,

                icon: const Icon(
                  Icons.edit,
                  color: Colors.black87,
                ),

                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: const BoxDecoration(
              color: Color(0xFFF7C9C0),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}