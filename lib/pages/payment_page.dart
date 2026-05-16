import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_page.dart';
import 'cart_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> products;
  final Map<Product, int> quantities;
  final int totalPayment;

  const PaymentPage({
    super.key,
    required this.products,
    required this.quantities,
    required this.totalPayment,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  String selectedMethod = "Delivery";

  bool paymentSuccess = false;

  final TextEditingController fullAddressController =
      TextEditingController(
    text: "Karangbaru, Muara Dua, Lhokseumawe",
  );

  final TextEditingController houseNoController =
      TextEditingController(
    text: "No. 12",
  );

  final TextEditingController mapsController =
      TextEditingController(
    text: "https://maps.google.com/",
  );

  final TextEditingController notesController =
      TextEditingController(
    text: "Dekat toko utama",
  );

  @override
  void dispose() {
    fullAddressController.dispose();
    houseNoController.dispose();
    mapsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  int get totalItems {
    int total = 0;

    for (final item in widget.products) {
      total += widget.quantities[item] ?? 1;
    }

    return total;
  }

  int get subtotal {
    int total = 0;

    for (final item in widget.products) {
      total += item.price *
          (widget.quantities[item] ?? 1);
    }

    return total;
  }

  Future<void> continuePayment() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User belum login"),
      ),
    );
    return;
  }

  for (final product in widget.products) {
    final qty = widget.quantities[product] ?? 1;

    final response = await http.post(
      Uri.parse('${AppConfig.productBaseUrl}/penjualan'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_produk': product.kode,
        'id_pelanggan': userId,
        'jumlah': qty,
        'harga': product.price,
        'total': product.price * qty,
        'status': 'Dalam Proses',
        'metode': selectedMethod,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan penjualan"),
        ),
      );
      return;
    }
  }

  setState(() {
    paymentSuccess = true;
  });

  await Future.delayed(const Duration(seconds: 2));

  final userName = "Customer";

  final message = '''
╔══════════════════╗
      HARA HIJABNEEDS
╚══════════════════╝

🧾 *DETAIL PESANAN*

👤 Nama:
$userName

📍 Pengiriman:
$selectedMethod

━━━━━━━━━━━━━━━━━━
🛍 Produk:
${widget.products.map((e) => '• ${e.name} x${widget.quantities[e]}').join('\n')}

💰 Subtotal:
${formatRupiah(subtotal)}

━━━━━━━━━━━━━━━━━━
💳 *TOTAL BAYAR*
${formatRupiah(widget.totalPayment)}
━━━━━━━━━━━━━━━━━━

🔐 Mohon kirim kode pembayaran
untuk menyelesaikan transaksi.

Terima kasih 🤍
''';
    final Uri url = Uri.parse(
      "https://wa.me/6285321163909?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (paymentSuccess) {
      return _successPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5C8C3),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "PAYMENT SELECTION",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () =>
              Navigator.pop(context),
        ),

        actions: [

          Padding(
            padding:
                const EdgeInsets.only(right: 10),

            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),

              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const CartPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            if (selectedMethod == "Delivery")
              _recipientAddressCard(),

            if (selectedMethod == "Pick Up")
              _storeCard(),

            const SizedBox(height: 14),

            _deliveryMethodSelector(),

            const SizedBox(height: 14),

            _orderPreviewCard(),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF6464),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5),
                  ),
                ),

                onPressed: () async {
                  await continuePayment();
                },

                child: Text(
                  "CONTINUE PAYMENT",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryMethodSelector() {
    return Row(
      children: [

        Expanded(
          child: _methodCard(
            title: "DELIVERY",
            icon: Icons.local_shipping,
            value: "Delivery",
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _methodCard(
            title: "PICK UP",
            icon: Icons.store,
            value: "Pick Up",
          ),
        ),
      ],
    );
  }

  Widget _methodCard({
    required String title,
    required IconData icon,
    required String value,
  }) {

    final bool isSelected =
        selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },

      child: Container(
        height: 110,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(8),

          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B6B)
                : Colors.grey.shade300,
            width: 2,
          ),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 34,
              color: Colors.grey,
            ),

            const SizedBox(height: 8),

            Text(
              title,

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipientAddressCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: _boxDecoration(),

      child: Column(
        children: [

          const Text(
            "RECIPIENT ADDRESS",

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          _addressField(
            fullAddressController,
            Icons.home,
          ),

          _addressField(
            houseNoController,
            Icons.list_alt,
          ),

          _addressField(
            mapsController,
            Icons.map,
          ),

          _addressField(
            notesController,
            Icons.edit,
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,

            child: Container(
              width: 90,
              height: 36,

              decoration: BoxDecoration(
                color:
                    const Color(0xFFF5C8C3),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              alignment: Alignment.center,

              child: const Text(
                "EDIT",

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressField(
    TextEditingController controller,
    IconData icon,
  ) {

    return Container(
      height: 46,

      margin:
          const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
        ),
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          suffixIcon: Icon(
            icon,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _storeCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: _boxDecoration(),

      child: Column(
        children: [

          const Text(
            "OUR STORE",

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            height: 170,
            width: double.infinity,

            decoration: BoxDecoration(
              color: Colors.grey.shade200,

              border: Border.all(
                color: Colors.black26,
              ),
            ),

            child: const Center(
              child: Icon(
                Icons.store,
                size: 80,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderPreviewCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: _boxDecoration(),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "ORDER DETAIL",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Total Product: $totalItems item",
          ),

          const SizedBox(height: 6),

          Text(
            "Payment Method: $selectedMethod",
          ),

          const SizedBox(height: 6),

          Text(
            "Total Payment: ${formatRupiah(widget.totalPayment)}",

            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _successPage() {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8F4),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF5C8C3),

        elevation: 0,
        centerTitle: true,

        title: const Text(
          "PAYMENT SELECTION",

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),

          decoration: _boxDecoration(),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Container(
                width: 150,
                height: 150,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color:
                        const Color(0xFF2DBE4E),
                    width: 8,
                  ),
                ),

                child: const Icon(
                  Icons.check,
                  size: 90,
                  color: Color(0xFF2DBE4E),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
  "ORDER CREATED!",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Your payment has been processed.\nPlease wait while we confirm your order.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  _dot(false),
                  _dot(true),
                  _dot(false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: active ? 12 : 9,
      height: active ? 12 : 9,

      margin:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),

      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFFFC7C2),

        shape: BoxShape.circle,
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(8),

      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(2, 3),
        ),
      ],
    );
  }

  String formatRupiah(int number) {
    return "Rp${number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )},00";
  }
}