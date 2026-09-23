import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/urls.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isPlacingOrder = false;

  Future<String> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString() ?? '1';
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF5252),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your Cart is Empty!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                final food = cartItem.food;

                String imagePath = '';
                try {
                  imagePath = food.image ?? food.imageUrl ?? '';
                } catch (_) {
                  imagePath = '';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imagePath.startsWith('http')
                              ? Image.network(
                            imagePath,
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                          )
                              : Image.asset(
                            imagePath.isNotEmpty ? imagePath : 'assets/cheeseBurger.png',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name ?? 'Food Item',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              // 🎯 ফুড ডিটেইলস থেকে আসা কাস্টমার নাম এখানে শো করবে
                              Text(
                                'Name: ${cartItem.userName}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      cartItem.location.isNotEmpty ? cartItem.location : 'Default Location',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${(food.price * cartItem.quantity).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                              onPressed: () {
                                cartProvider.decrementQuantity(index);
                              },
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22),
                              onPressed: () {
                                cartProvider.incrementQuantity(index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${cartProvider.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isPlacingOrder
                        ? null
                        : () async {
                      if (cartItems.isEmpty) return;

                      setState(() {
                        isPlacingOrder = true;
                      });

                      String currentUserId = await getLoggedInUserId();
                      bool allSuccess = true;

                      for (var item in cartItems) {
                        try {
                          final response = await http.post(
                            Uri.parse(Urls.placeOrder),
                            body: {
                              'user_id': currentUserId,
                              'customer_name': item.userName, // 👈 ফুড ডিটেইলস থেকে আসা নাম পাঠানো হচ্ছে
                              'food_id': item.food.id.toString(),
                              'quantity': item.quantity.toString(),
                              'price': item.food.price.toString(),
                              'address': item.location, // 👈 লোকেশন পাঠানো হচ্ছে
                            },
                          );

                          if (response.statusCode == 200) {
                            final resData = jsonDecode(response.body);
                            if (resData['success'] != true) {
                              allSuccess = false;
                            }
                          } else {
                            allSuccess = false;
                          }
                        } catch (e) {
                          print("Order Error: $e");
                          allSuccess = false;
                        }
                      }

                      setState(() {
                        isPlacingOrder = false;
                      });

                      if (allSuccess) {
                        final orderProvider = Provider.of<OrderProvider>(context, listen: false);

                        for (var item in cartItems) {
                          String orderId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

                          orderProvider.addOrder(
                            OrderItem(
                              id: orderId,
                              userName: item.userName,
                              item: item.food.name ?? 'Food Item',
                              totalPrice: item.food.price * item.quantity,
                              location: item.location,
                              status: "Pending",
                            ),
                          );
                        }

                        cartProvider.clearCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to place order. Try again!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: isPlacingOrder
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Place Order",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}