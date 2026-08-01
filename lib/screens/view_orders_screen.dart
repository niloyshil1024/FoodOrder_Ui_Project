import 'package:flutter/material.dart';

class MyOrdersScreen extends StatefulWidget {
  final String userId;

  const MyOrdersScreen({super.key, required this.userId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  // অরিজিনাল অর্ডার লিস্ট
  final List<Map<String, dynamic>> _orders = [
    {
      "id": "8",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 0.00,
      "location": "dhaka",
      "status": "Approved",
    },
    {
      "id": "7",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 5.49,
      "location": "dhaka",
      "status": "Cancelled",
    },
    {
      "id": "6",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 3.00,
      "location": "ctg",
      "status": "Pending",
    },
    {
      "id": "5",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 3.00,
      "location": "Dhaka",
      "status": "Pending",
    },
    {
      "id": "4",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 6.00,
      "location": "N/A",
      "status": "Approved",
    },
    {
      "id": "3",
      "userName": "Guest User",
      "item": "Food Item",
      "totalPrice": 9.00,
      "location": "N/A",
      "status": "Pending",
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 🗑️ Cancel বা ডিলিট করার মেথড (লিস্ট থেকে সম্পূর্ণ মুছে ফেলবে)
  void _removeOrder(int indexInFilteredList, List<Map<String, dynamic>> filteredList, String message) {
    setState(() {
      // অরিজিনাল লিস্ট থেকে নির্দিষ্ট অর্ডারটি খুঁজে বের করে রিমোভ করা
      final targetOrder = filteredList[indexInFilteredList];
      _orders.removeWhere((order) => order['id'] == targetOrder['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 ফিল্টার করা লিস্ট: এখানে 'Cancelled' অর্ডারগুলো ইউজার ইন্টারফেসে শো করবে না
    final activeOrders = _orders.where((order) => order['status'] != 'Cancelled').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF5252),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: activeOrders.isEmpty
          ? const Center(
        child: Text(
          'No active orders found!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          String status = order['status'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${order['id']} - ${order['userName']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // ডিলিট আইকন
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            tooltip: "Delete Order",
                            onPressed: () => _removeOrder(index, activeOrders, 'Order removed successfully!'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Item: ${order['item']}",
                    style: TextStyle(
                        color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Price: \$${order['totalPrice'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        "Location: ${order['location']}",
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  if (status == 'Pending') ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ❌ Cancel বাটন (ক্লিক করলেই লিস্ট থেকে একদম গায়েব হয়ে যাবে)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel'),
                          onPressed: () {
                            _removeOrder(index, activeOrders, 'Order cancelled and removed!');
                          },
                        ),
                        const SizedBox(width: 10),
                        // ✅ Approve বাটন
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approve'),
                          onPressed: () {
                            setState(() {
                              // অরিজিনাল লিস্ট থেকে এই অর্ডারের স্ট্যাটাস Approved করে দেওয়া
                              final targetId = order['id'];
                              final origIndex = _orders.indexWhere((o) => o['id'] == targetId);
                              if (origIndex != -1) {
                                _orders[origIndex]['status'] = 'Approved';
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order approved successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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
    );
  }
}