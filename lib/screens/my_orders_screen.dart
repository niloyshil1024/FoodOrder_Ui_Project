import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/urls.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> activeOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  Future<String> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString() ?? '1';
  }

  Future<void> fetchUserOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      String userId = await getLoggedInUserId();
      final response = await http.get(Uri.parse('${Urls.getUserOrders}?user_id=$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            activeOrders = data;
            isLoading = false;
          });
        } else if (data is Map && data['data'] != null) {
          setState(() {
            activeOrders = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            activeOrders = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF5252),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUserOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)))
          : activeOrders.isEmpty
          ? const Center(
        child: Text(
          'No active orders found!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchUserOrders,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: activeOrders.length,
          itemBuilder: (context, index) {
            final order = activeOrders[index];

            // 🎯 ডেটা রিড করার সঠিক লজিক
            String foodName = order['food_name'] ?? order['item_name'] ?? order['item'] ?? 'Food Item';
// 🎯 order['customer_name'] এর বদলে order['user_name'] দিতে হবে (যেহেতু পিএইচপি থেকে এটি পাঠানো হচ্ছে)
            String userName = order['user_name'] ?? order['customer_name'] ?? 'Guest User';            String total = order['total_price']?.toString() ?? order['price']?.toString() ?? '0.00';
            String address = order['address'] ?? order['location'] ?? 'N/A';
            String status = order['status'] ?? 'Pending';
            String orderDate = order['created_at'] ?? order['order_date'] ?? '';

            Color statusColor = _getStatusColor(status);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ফুডের নাম ও স্ট্যাটাস
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            foodName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // মোট দাম
                    Text(
                      "Total Price: \$$total",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),

                    // 🎯 কাস্টমার নাম (লোকেশনের ঠিক উপরে শো করবে)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Name: $userName",
                            style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // লোকেশন
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Location: $address",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // অর্ডারের সময়
                    if (orderDate.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Time: $orderDate",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}