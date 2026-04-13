import 'package:flutter/material.dart';
class MaterialPageFilter extends StatelessWidget {
  const MaterialPageFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Material")),
      body: const Center(child: Text("Halaman Material")),
    );
  }
}