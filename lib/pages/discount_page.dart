import 'package:flutter/material.dart';
import 'product_page.dart';
import 'app_drawer.dart';

import '../services/discount_service.dart';
import '../models/discount_model.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: Colors.white,

      drawer: const AppDrawer(
        currentPage: "Discount",
      ),

      appBar: AppBar(

        backgroundColor: const Color(0xFFF7C9C0),

        elevation: 0,

        leading: Builder(
          builder: (context) => IconButton(

            icon: const Icon(
              Icons.menu,
              color: Colors.black54,
            ),

            onPressed: () =>
                Scaffold.of(context).openDrawer(),
          ),
        ),

        title: const Text(

          "Discount",

          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: FutureBuilder<List<DiscountModel>>(

          future: DiscountService.getDiscounts(),

          builder: (context, snapshot) {

            /// LOADING
            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            /// ERROR
            if (snapshot.hasError) {

              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            /// DATA
            final discounts = snapshot.data!;

            /// EMPTY
            if (discounts.isEmpty) {

              return const Center(
                child: Text(
                  "Belum ada discount",
                ),
              );
            }

            return Column(

              children: discounts.map((item) {

                return Container(

                  width: double.infinity,

                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),

                  child: Material(

                    color: Colors.transparent,

                    child: InkWell(

                      onTap: () {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(

                            content: Text(
                              "${item.discountPercent}% Discount Applied!",
                            ),

                            backgroundColor:
                                const Color(0xFFF7C9C0),

                            duration:
                                const Duration(seconds: 1),
                          ),
                        );

                        Future.delayed(
                          const Duration(milliseconds: 700),
                          () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProductPage(),
                              ),
                            );
                          },
                        );
                      },

                      borderRadius:
                          BorderRadius.circular(20),

                      splashColor:
                          const Color(0xFFF7C9C0)
                              .withOpacity(0.3),

                      child: Container(

                        decoration: BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(20),

                          boxShadow: [

                            BoxShadow(

                              color: Colors.grey
                                  .withOpacity(0.2),

                              spreadRadius: 2,

                              blurRadius: 12,

                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Row(

                          children: [

                            /// IMAGE
                            Expanded(

                              flex: 4,

                              child: ClipRRect(

                                borderRadius:
                                    const BorderRadius.only(

                                  topLeft:
                                      Radius.circular(20),

                                  bottomLeft:
                                      Radius.circular(20),
                                ),

                                child: Image.network(

                                  item.banner ?? '',

                                  height: 160,

                                  fit: BoxFit.cover,

                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {

                                    return Container(

                                      height: 160,

                                      color: Colors.grey[300],

                                      child: const Icon(
                                        Icons.image,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            /// TEXT
                            Expanded(

                              flex: 6,

                              child: Padding(

                                padding:
                                    const EdgeInsets.symmetric(

                                  horizontal: 16,
                                  vertical: 12,
                                ),

                                child: Column(

                                  mainAxisAlignment:
                                      MainAxisAlignment.center,

                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,

                                  children: [

                                    Text(

                                      item.title.toUpperCase(),

                                      textAlign:
                                          TextAlign.center,

                                      style: TextStyle(

                                        fontSize:
                                            screenWidth * 0.045,

                                        fontWeight:
                                            FontWeight.w900,

                                        color: Colors.grey[600],

                                        letterSpacing: 0.8,
                                      ),
                                    ),

                                    Text(

                                      "${item.discountPercent}%",

                                      style: TextStyle(

                                        fontSize:
                                            screenWidth * 0.11,

                                        fontWeight:
                                            FontWeight.w900,

                                        height: 1.0,

                                        color: Colors.black87,
                                      ),
                                    ),

                                    const Text(

                                      "DISCOUNT",

                                      style: TextStyle(

                                        fontWeight:
                                            FontWeight.w700,

                                        color: Colors.black54,

                                        letterSpacing: 1.2,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    Container(

                                      padding:
                                          const EdgeInsets.symmetric(

                                        horizontal: 20,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(

                                        color:
                                            const Color(0xFFF7C9C0),

                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),

                                      child: const Text(

                                        "USE NOW",

                                        style: TextStyle(

                                          fontSize: 10,

                                          fontWeight:
                                              FontWeight.w900,

                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(

                                      item.type.toUpperCase(),

                                      textAlign:
                                          TextAlign.center,

                                      style: const TextStyle(

                                        fontSize: 10,

                                        fontWeight:
                                            FontWeight.w500,

                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

              }).toList(),
            );
          },
        ),
      ),
    );
  }
}