import 'package:flutter/material.dart';
import 'order_model.dart';
import 'order_receipt_page.dart';
import 'product_page.dart';
import 'app_drawer.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Bersihkan list global terlebih dahulu saat memuat halaman 
    // agar data pesanan akun sebelumnya tidak mengintip secara sekilas
    setState(() {
      orderList = [];
    });

    // Memuat pesanan berdasarkan session email aktif dari SharedPreferences
    await loadOrders();
    print("ORDER LOADED: ${orderList.length}");

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: "Pesanan"),
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5C8C3),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black87,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orderList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada pesanan",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                // Menggunakan model data yang benar (OrderModel)
                final OrderModel order = orderList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFFE75480),
                    ),
                    title: Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Status: ${order.status}\nTotal: ${formatRupiah(order.totalPayment)}",
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.black54,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderReceiptPage(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}