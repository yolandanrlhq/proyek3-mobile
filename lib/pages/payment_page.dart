import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_page.dart';
import 'cart_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'order_model.dart';
import 'order_receipt_page.dart';
import 'order_status_page.dart';

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
  bool isEditingAddress = false;

  final TextEditingController fullAddressController = TextEditingController();
  final TextEditingController mapsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserAddress();
  }

  Future<void> loadUserAddress() async {
    final prefs = await SharedPreferences.getInstance();

    fullAddressController.text =
        prefs.getString('address') ??
        prefs.getString('alamat') ??
        "";

    mapsController.text = "";
    notesController.text = "";
  }

  @override
  void dispose() {
    fullAddressController.dispose();
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
      total += item.price * (widget.quantities[item] ?? 1);
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

    if (selectedMethod == "Delivery" &&
        fullAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alamat pengiriman wajib diisi"),
        ),
      );
      return;
    }

    final userName = prefs.getString('userName') ?? "Customer";
    final userPhone = prefs.getString('phone') ?? "-";
    final userAddress = fullAddressController.text.isNotEmpty
        ? fullAddressController.text
        : "Alamat belum diisi";

    await loadOrders();

    final order = OrderModel(
      orderCode: "HARA-${DateTime.now().millisecondsSinceEpoch}",
      products: widget.products,
      quantities: widget.quantities.map(
        (key, value) => MapEntry(key.kode, value),
      ),
      totalPayment: widget.totalPayment,
      customerName: userName,
      customerPhone: userPhone,
      customerAddress: userAddress,
      method: selectedMethod,
      status: "Menunggu Konfirmasi Admin",
      createdAt: DateTime.now(),
    );

    orderList.add(order);
    await saveOrders();

    print("ORDER SAVED: ${orderList.length}");

    for (final product in widget.products) {
      final qty = widget.quantities[product] ?? 1;

      final response = await http.post(
        Uri.parse('${AppConfig.productBaseUrl}/penjualan'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'id_pelanggan': userId,
          'id_produk': product.kode,
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

    final message = '''
Halo Admin Hara Hijabneeds, saya ingin melakukan pemesanan.

*DATA PEMESAN*
Nama: $userName
No. HP: $userPhone
Metode: $selectedMethod

*ALAMAT / CATATAN*
Alamat: $userAddress
Maps: ${mapsController.text.isNotEmpty ? mapsController.text : "-"}
Catatan: ${notesController.text.isNotEmpty ? notesController.text : "-"}

*DETAIL PRODUK*
${widget.products.map((e) {
      final qty = widget.quantities[e] ?? 1;
      return '- ${e.name} x$qty = ${formatRupiah(e.price * qty)}';
    }).join('\n')}

*TOTAL PEMBAYARAN*
${formatRupiah(widget.totalPayment)}

Mohon konfirmasi ongkir, estimasi pengiriman, dan instruksi pembayaran ya. Terima kasih.
''';

    final Uri url = Uri.parse(
      "https://wa.me/6285321163909?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    for (final item in widget.products) {
      selectedSizeCart.remove(item.kode);
    }

    cartList.value = cartList.value
        .where((item) => !widget.products.contains(item))
        .toList();

    cartList.notifyListeners();
    await saveCartAndFavorite();

    if (!mounted) return;

    setState(() {
      paymentSuccess = true;
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
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
            if (selectedMethod == "Delivery") _recipientAddressCard(),
            if (selectedMethod == "Pick Up") _storeCard(),
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
                  backgroundColor: const Color(0xFFFF6464),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () async {
                  await continuePayment();
                },
                child: const Text(
                  "BUAT PESANAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
    final bool isSelected = selectedMethod == value;

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
          borderRadius: BorderRadius.circular(8),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isEditingAddress = !isEditingAddress;
                });
              },
              child: Container(
                width: 90,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C8C3),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  isEditingAddress ? "SAVE" : "EDIT",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        controller: controller,
        readOnly: !isEditingAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          suffixIcon: Icon(
            icon,
            size: 20,
            color: isEditingAddress ? Colors.black54 : Colors.grey,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5C8C3),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductPage(),
              ),
              (route) => false,
            );
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
                    color: const Color(0xFF2DBE4E),
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
                "Pesanan berhasil dibuat.\nAdmin akan menghubungi kamu melalui WhatsApp.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(false),
                  _dot(true),
                  _dot(false),
                ],
              ),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderStatusPage(),
                    ),
                  );
                },
                child: const Text("Lihat Status Pesanan"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Kembali ke Katalog"),
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
      margin: const EdgeInsets.symmetric(
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
      borderRadius: BorderRadius.circular(8),
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