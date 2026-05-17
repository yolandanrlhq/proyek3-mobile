import 'package:flutter/material.dart';
import 'product_page.dart';
import 'checkout_page.dart';

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
    syncCartData();
    unreadCartCount.value = 0;
  }

  int getTotalPrice() {
    int total = 0;

    for (var item in cartList.value) {
      if (selectedItems[item] == true) {
        total += item.price * (qty[item] ?? 1);
      }
    }

    return total;
  }

  void syncCartData() {
    for (var item in cartList.value) {
      qty[item] = qty[item] ?? 1;
      selectedItems[item] = selectedItems[item] ?? true;
    }

    qty.removeWhere(
      (key, value) => !cartList.value.contains(key),
    );

    selectedItems.removeWhere(
      (key, value) => !cartList.value.contains(key),
    );
  }

  void removeItem(Product item) async {
    setState(() {
      cartList.value = cartList.value.where((p) => p != item).toList();

      qty.remove(item);
      selectedItems.remove(item);
      selectedSizeCart.remove(item.kode);

      cartList.notifyListeners();
    });

    await saveCartAndFavorite();
  }

  @override
  Widget build(BuildContext context) {
    syncCartData();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD6DF),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: Color(0xFF3D2B2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: cartList.value.isEmpty
          ? _emptyCart()
          : Column(
              children: [

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      10,
                    ),

                    itemCount: cartList.value.length,

                    itemBuilder: (context, index) {

                      final item =
                          cartList.value[index];

                      final itemQty =
                          qty[item] ?? 1;

                      final totalItem =
                          item.price * itemQty;

                      final isSelected =
                          selectedItems[item] ?? true;

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.06),

                              blurRadius: 12,

                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Checkbox(
                              activeColor:
                                  const Color(0xFFE75480),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5),
                              ),

                              value: isSelected,

                              onChanged: (value) {
                                setState(() {
                                  selectedItems[item] =
                                      value ?? false;
                                });
                              },
                            ),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(16),

                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,

                                      width: 86,
                                      height: 100,

                                      fit: BoxFit.cover,

                                      errorBuilder:
                                          (_, __, ___) =>
                                              _imageFallback(),
                                    )
                                  : _imageFallback(),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    item.name,

                                    maxLines: 2,

                                    overflow:
                                        TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    item.kategori,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Size: ${selectedSizeCart[item.kode] ?? '-'}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    formatRupiah(item.price),
                                    style: const TextStyle(
                                      color:
                                          Color(0xFFE75480),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  Text(
                                    "Subtotal: ${formatRupiah(totalItem)}",

                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [

                                      _qtyButton(
                                        icon: Icons.remove,

                                        onTap: () {
                                          if (itemQty > 1) {
                                            setState(() {
                                              qty[item] =
                                                  itemQty - 1;
                                            });
                                          }
                                        },
                                      ),

                                      Container(
                                        width: 34,

                                        alignment:
                                            Alignment.center,

                                        child: Text(
                                          "$itemQty",

                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      _qtyButton(
                                        icon: Icons.add,

                                        onTap: () {
                                          setState(() {
                                            qty[item] =
                                                itemQty + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              padding: EdgeInsets.zero,

                              constraints:
                                  const BoxConstraints(),

                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),

                              onPressed: () =>
                                  removeItem(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                _checkoutBar(),
              ],
            ),
    );
  }

  Widget _checkoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),

            blurRadius: 14,

            offset: const Offset(0, -5),
          ),
        ],

        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [

                const Text(
                  "Total Pembayaran",

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  formatRupiah(getTotalPrice()),

                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE75480),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFE75480),

              foregroundColor: Colors.white,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              elevation: 0,
            ),

            onPressed: () {

              final selectedProducts =
                  cartList.value
                      .where(
                        (item) =>
                            selectedItems[item] == true,
                      )
                      .toList();

              if (selectedProducts.isEmpty) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Pilih minimal satu produk untuk checkout",
                    ),
                  ),
                );

                return;
              }

              final selectedQty =
                  <Product, int>{};

              for (var item
                  in selectedProducts) {

                selectedQty[item] =
                    qty[item] ?? 1;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    products: selectedProducts,
                    quantities: selectedQty,
                    allSelectedProducts: selectedProducts,
                  ),
                ),
              );
            },

            child: const Text(
              "Checkout",

              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              padding: const EdgeInsets.all(26),

              decoration: const BoxDecoration(
                color: Color(0xFFFFDDE6),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,

                size: 70,

                color: Color(0xFFE75480),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Keranjang masih kosong",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Yuk pilih hijab favorit Teteh dulu ✨",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(9),

      child: Container(
        width: 28,
        height: 28,

        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF3),

          borderRadius:
              BorderRadius.circular(9),

          border: Border.all(
            color: const Color(0xFFFFC2D1),
          ),
        ),

        child: Icon(
          icon,

          size: 16,

          color: const Color(0xFFE75480),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 86,
      height: 100,

      color: const Color(0xFFFFEEF3),

      alignment: Alignment.center,

      child: const Icon(
        Icons.image_not_supported_outlined,

        color: Color(0xFFE75480),
      ),
    );
  }
}