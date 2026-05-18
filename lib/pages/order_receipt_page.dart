import 'package:flutter/material.dart';
import 'order_model.dart';
import 'product_page.dart';

class OrderReceiptPage extends StatelessWidget {
  final OrderModel order;

  const OrderReceiptPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5C8C3),
        centerTitle: true,
        title: const Text(
          "Struk Pemesanan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "HARA HIJABNEEDS",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const Divider(height: 30),

              _row("Kode", order.orderCode),
              _row("Status", order.status),
              _row("Metode", order.method),

              const SizedBox(height: 14),

              const Text(
                "Data Pemesan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              _row("Nama", order.customerName),
              _row("No HP", order.customerPhone),
              _row("Alamat", order.customerAddress),

              const Divider(height: 30),

              const Text(
                "Detail Produk",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...order.products.map((item) {
                final qty = order.quantities[item.kode] ?? 1;
                final total = item.price * qty;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text("${item.name} x$qty")),
                      Text(formatRupiah(total)),
                    ],
                  ),
                );
              }),

              const Divider(height: 30),

              _row(
                "Total",
                formatRupiah(order.totalPayment),
                isBold: true,
              ),

              const SizedBox(height: 18),

              const Text(
                "Admin akan menghubungi melalui WhatsApp untuk konfirmasi ongkir, estimasi pengiriman, dan instruksi pembayaran.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}