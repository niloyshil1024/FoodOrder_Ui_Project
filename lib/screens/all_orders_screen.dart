import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  List ordersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final String url = '${Urls.baseUrl}/get_all_orders.php?t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is Map && decodedData.containsKey('data')) {
          setState(() {
            ordersList = decodedData['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    setState(() {
      if (newStatus.toLowerCase() == 'cancelled') {
        ordersList.removeWhere((order) => order['id'].toString() == orderId);
      } else {
        for (var order in ordersList) {
          if (order['id'].toString() == orderId) {
            order['status'] = newStatus;
          }
        }
      }
    });

    try {
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/update_status.php'),
        body: {
          'order_id': orderId,
          'status': newStatus,
        },
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData['message'] ?? 'Order $newStatus successfully'),
            backgroundColor: newStatus.toLowerCase() == 'approved' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Update Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status on server!'),
          backgroundColor: Colors.red,
        ),
      );
      fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = ordersList.where((order) {
      if (order == null || order['status'] == null) return false;
      String status = order['status'].toString().trim().toLowerCase();
      return status != 'cancelled';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF5252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchOrders();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF5252)),
      )
          : RefreshIndicator(
        color: const Color(0xFFFF5252),
        onRefresh: fetchOrders,
        child: activeOrders.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'No pending or approved orders found!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: activeOrders.length,
          itemBuilder: (context, index) {
            final order = activeOrders[index];
            String orderId = order['id']?.toString() ?? '';

            // 🎯 শুধুমাত্র কাস্টমার বা ইউজারের নাম ফেচ করা (আইডি বাদ দিয়ে)
            String userName = order['user_name'] ?? order['name'] ?? 'Customer';

// 🎯 ডাটাবেজ বা পিএইচপি থেকে আসা ফুডের নাম বিভিন্ন ফিল্ড থেকে চেক করার ব্যবস্থা
            String foodName = order['food_name'] ?? order['item_name'] ?? order['item'] ?? order['name'] ?? 'Food Item';            String total = order['total_price']?.toString() ?? order['price']?.toString() ?? '0.00';
            String address = order['address'] ?? 'No Address Provided';
            String status = order['status'] ?? 'Pending';

            // 🎯 ডেটাবেজ থেকে ডেট ও টাইম ফেচ করা (created_at বা order_date)
            String orderDate = order['created_at'] ?? order['order_date'] ?? '';

            Color statusColor = status.toLowerCase() == 'approved'
                ? Colors.green
                : Colors.orange;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          userName, // 👈 এখানে শুধু ইউজারের নাম দেখাবে
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Item: $foodName',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Price: \$$total',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Location: $address',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 🎯 ডেট ও টাইম দেখানোর জন্য উইজেট
                  if (orderDate.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Time: $orderDate',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],

                  if (status.toLowerCase() == 'pending') ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => updateOrderStatus(orderId, 'Cancelled'),
                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                          label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => updateOrderStatus(orderId, 'Approved'),
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                          label: const Text('Approve', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}