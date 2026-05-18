import 'package:flutter/material.dart';

class GlowMatchHistoryPage extends StatelessWidget {
  final List<dynamic> histories;
  final Function(dynamic item) onSelected;

  const GlowMatchHistoryPage({
    super.key,
    required this.histories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Glow Match'),
        backgroundColor: const Color(0xFFE7C1BC),
        foregroundColor: const Color(0xFF3A2323),
      ),
      body: histories.isEmpty
          ? const Center(child: Text('Belum ada history scan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final item = histories[index];
                final warnaKulit =
                    (item['warna_kulit'] ?? '-').toString();
                final rekomendasi =
                    (item['rekomendasi_warna'] ?? '-').toString();
                final tanggal = (item['created_at'] ?? '').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.face_retouching_natural),
                    title: Text(
                      warnaKulit.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$rekomendasi\n${tanggal.length >= 10 ? tanggal.substring(0, 10) : tanggal}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item);
                    },
                  ),
                );
              },
            ),
    );
  }
}