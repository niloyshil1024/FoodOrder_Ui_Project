import 'package:flutter/foundation.dart';

class OrderItem {
  final String id;
  final String userName;
  final String item;
  final double totalPrice;
  final String location;
  String status;

  OrderItem({
    required this.id,
    required this.userName,
    required this.item,
    required this.totalPrice,
    required this.location,
    this.status = 'Pending', // নতুন অর্ডার সবসময় 'Pending' থাকবে
  });
}

class OrderProvider extends ChangeNotifier {
  final List<OrderItem> _orders = []; // 👈 একদম ফাঁকা লিস্ট

  List<OrderItem> get orders => _orders;

  // ➕ নতুন অর্ডার যোগ করার মেথড
  void addOrder(OrderItem order) {
    _orders.insert(0, order); // নতুন অর্ডার সবার উপরে দেখাবে
    notifyListeners();
  }

  // ✅ স্ট্যাটাস আপডেট (Approve বা Cancel) করার মেথড
  void updateOrderStatus(String id, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index].status = newStatus;
      notifyListeners();
    }
  }

  // 🗑️ অর্ডার ডিলিট করার মেথড
  void removeOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}