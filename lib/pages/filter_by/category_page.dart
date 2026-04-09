import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category"),
        backgroundColor: Colors.grey[200],
      ),
      body: const Center(
        child: Text("Halaman Category"),
      ),
    );
  }
}