import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'product_page.dart';
import 'payment_page.dart';
import 'product_detail_page.dart';

import '../services/discount_service.dart';
import '../models/discount_model.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> products;
  final Map<Product, int> quantities;
  final List<Product> allSelectedProducts;

  const CheckoutPage({
    super.key,
    required this.products,
    required this.quantities,
    required this.allSelectedProducts,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Map<Product, int> quantities;

  String userName = "User";
  String userPhone = "-";
  String userAddress = "Alamat belum tersedia";

  // DISCOUNT
  bool isDiscountApplied = false;
  bool isLoadingDiscount = true;
  List<DiscountModel> availableDiscounts = [];
  DiscountModel? selectedDiscount;

  int get discountPercent => selectedDiscount?.discountPercent ?? 0;

  @override
  void initState() {
    super.initState();

    quantities = Map<Product, int>.from(
      widget.quantities,
    );

    loadProfileData();
    loadDiscounts();
  }

  Future<void> loadDiscounts() async {
    try {
      final discounts = await DiscountService.getDiscounts();

      if (!mounted) return;

      setState(() {
        availableDiscounts = discounts;
        selectedDiscount = discounts.isNotEmpty ? discounts.first : null;
        isLoadingDiscount = false;

        if (discounts.isEmpty) {
          isDiscountApplied = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        availableDiscounts = [];
        selectedDiscount = null;
        isLoadingDiscount = false;
        isDiscountApplied = false;
      });
    }
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName') ??
          prefs.getString('name') ??
          "User";

      userPhone = prefs.getString('phone') ??
          prefs.getString('no_telepon') ??
          "-";

      userAddress = prefs.getString('address') ??
          prefs.getString('alamat') ??
          "Alamat belum tersedia";
    });
  }

  int get subtotal {
    int total = 0;

    for (final item in widget.products) {
      total += item.price * (quantities[item] ?? 1);
    }

    return total;
  }

  // DISCOUNT REALTIME
  int get discountAmount {
    if (isDiscountApplied && selectedDiscount != null) {
      return (subtotal * discountPercent ~/ 100);
    }

    return 0;
  }

  // TOTAL FINAL
  int get total {
    return subtotal - discountAmount;
  }

  void increaseQty(Product product) {
    setState(() {
      quantities[product] = (quantities[product] ?? 1) + 1;
    });
  }

  void decreaseQty(Product product) {
    setState(() {
      if ((quantities[product] ?? 1) > 1) {
        quantities[product] = (quantities[product] ?? 1) - 1;
      }
    });
  }

  // APPLY DISCOUNT
  void applyDiscount() {
    if (selectedDiscount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belum ada discount yang tersedia"),
          backgroundColor: Color(0xFFF8C8C0),
        ),
      );
      return;
    }

    setState(() {
      isDiscountApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Discount ${selectedDiscount!.discountPercent}% berhasil digunakan",
        ),
        backgroundColor: const Color(0xFFF8C8C0),
      ),
    );
  }

  void cancelDiscount() {
    setState(() {
      isDiscountApplied = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Discount dibatalkan"),
        backgroundColor: Color(0xFFF8C8C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6B8AF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "CHECKOUT",
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B1B16),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6B5A55),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            _addressCard(),
            const SizedBox(height: 14),
            ...widget.products.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _productCard(item),
              );
            }),
            const SizedBox(height: 12),
            _discountCard(),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 22),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("$userName | $userPhone", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(userAddress, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 14),
          const Text(
            "Admin akan mengonfirmasi ongkir dan estimasi pengiriman melalui WhatsApp.",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product item) {
    final qty = quantities[item] ?? 1;
    final totalHarga = item.price * qty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    width: 105,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _emptyImage();
                    },
                  )
                : _emptyImage(),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1B16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(formatRupiah(item.price), style: const TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Total: ${formatRupiah(totalHarga)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  "Color: ${item.warna}\nSize: ${selectedSizeCart[item.kode] ?? '-'}",
                  style: const TextStyle(letterSpacing: 1, color: Color(0xFF3A2A25)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(onTap: () => decreaseQty(item), child: _qtyBox("-")),
                    _qtyBox("$qty"),
                    InkWell(onTap: () => increaseQty(item), child: _qtyBox("+")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountCard() {
    final bool hasDiscount = selectedDiscount != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Available Discount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF8C8C0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.discount, color: Color(0xFFE48A8A)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoadingDiscount
                            ? "MEMUAT DISCOUNT..."
                            : hasDiscount
                                ? "${selectedDiscount!.title.toUpperCase()} ${selectedDiscount!.discountPercent}%"
                                : "TIDAK ADA DISCOUNT",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoadingDiscount
                            ? "Sedang mengecek discount tersedia"
                            : hasDiscount
                                ? "Diskon spesial untuk semua produk"
                                : "Saat ini belum ada discount yang bisa digunakan",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasDiscount ? const Color(0xFFF8C8C0) : Colors.grey[300],
                  ),
                  onPressed: isLoadingDiscount || !hasDiscount
                      ? null
                      : isDiscountApplied
                          ? cancelDiscount
                          : applyDiscount,
                  child: Text(
                    isLoadingDiscount || !hasDiscount
                        ? "Unavailable"
                        : isDiscountApplied
                            ? "Cancel"
                            : "Apply",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          _summaryRow("Subtotal", formatRupiah(subtotal)),
          if (isDiscountApplied && selectedDiscount != null)
            _summaryRow("Discount $discountPercent%", "- ${formatRupiah(discountAmount)}"),
          const Divider(),
          _summaryRow("TOTAL", formatRupiah(total)),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      decoration: _cardDecoration(),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          onPressed: () {
            final hasEmptySize = widget.products.any(
              (item) => selectedSizeCart[item.kode] == null,
            );

            if (hasEmptySize) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ada produk yang belum memilih ukuran")),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  products: widget.products,
                  quantities: quantities,
                  totalPayment: total,
                ),
              ),
            );
          },
          child: const Text(
            "Checkout Sekarang",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _qtyBox(String text) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyImage() {
    return Container(
      width: 105,
      height: 130,
      color: Colors.grey[200],
      child: const Icon(Icons.image),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
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