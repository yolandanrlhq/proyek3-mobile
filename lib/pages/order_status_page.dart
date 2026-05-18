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
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(order.orderCode),
                    subtitle: Text(
                      "${order.status}\nTotal: ${formatRupiah(order.totalPayment)}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
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