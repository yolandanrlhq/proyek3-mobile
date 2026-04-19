import 'package:flutter/material.dart';
import 'product_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<Product, int> qty = {};
  Map<Product, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();

    for (var item in cartList.value) {
      qty[item] = qty[item] ?? 1;
      selectedItems[item] = selectedItems[item] ?? true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    for (var item in cartList.value) {
      qty[item] = qty[item] ?? 1;
      selectedItems[item] = selectedItems[item] ?? true;
    }
  }

  int getTotalPrice() {
    int total = 0;

    for (var item in cartList.value) {
      if (selectedItems[item] == true) {
        int price = item.price;
        total += price * (qty[item] ?? 1);
      }
    }

    return total;
  }

  void syncCartData() {
    for (var item in cartList.value) {
      qty[item] = qty[item] ?? 1;
      selectedItems[item] = selectedItems[item] ?? true;
    }

    qty.removeWhere((key, value) => !cartList.value.contains(key));
    selectedItems.removeWhere((key, value) => !cartList.value.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    syncCartData();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6B8AF),
        title: const Text("SHOPPING CART"),
        centerTitle: true,
      ),
      body: cartList.value.isEmpty
          ? const Center(child: Text("Cart masih kosong"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartList.value.length,
                    itemBuilder: (context, index) {
                      final item = cartList.value[index];
                      final int itemQty = qty[item] ?? 1;
                      final int price = item.price;
                      final int totalItem = price * itemQty;
                      final bool isSelected = selectedItems[item] ?? true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  selectedItems[item] = value ?? false;
                                });
                              },
                            ),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.broken_image,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(formatRupiah(price)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _qtyBtn("-", () {
                                        if (itemQty > 1) {
                                          setState(() {
                                            qty[item] = itemQty - 1;
                                          });
                                        }
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text("$itemQty"),
                                      ),
                                      _qtyBtn("+", () {
                                        setState(() {
                                          qty[item] = itemQty + 1;
                                        });
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      cartList.value.remove(item);
                                      qty.remove(item);
                                      selectedItems.remove(item);
                                      cartList.notifyListeners();
                                    });
                                  },
                                ),
                                Text(
                                  "TOTAL: ${formatRupiah(totalItem)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL: ${formatRupiah(getTotalPrice())}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          final selectedProducts = cartList.value
                              .where((item) => selectedItems[item] == true)
                              .toList();

                          if (selectedProducts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Pilih minimal satu produk untuk checkout",
                                ),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${selectedProducts.length} produk dipilih untuk checkout",
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "CHECKOUT",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qtyBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}