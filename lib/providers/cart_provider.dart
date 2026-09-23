import 'package:flutter/material.dart';

class CartItem {
  final dynamic food;
  int quantity;
  final String location;
  final String userName; // 👈 কাস্টমার নাম ফিল্ড যুক্ত করা হলো

  CartItem({
    required this.food,
    this.quantity = 1,
    required this.location,
    required this.userName,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      total += (item.food.price * item.quantity);
    }
    return total;
  }

  // 🎯 নাম এবং লোকেশনসহ কার্টে যোগ করার মেথড
  void addToCart(dynamic food, {int quantity = 1, required String location, required String userName}) {
    int index = _cartItems.indexWhere((item) => item.food.id == food.id && item.location == location && item.userName == userName);
    if (index != -1) {
      _cartItems[index].quantity += quantity;
    } else {
      _cartItems.add(CartItem(food: food, quantity: quantity, location: location, userName: userName));
    }
    notifyListeners();
  }

  void addItem(dynamic food, int quantity, String location, String userName) {
    addToCart(food, quantity: quantity, location: location, userName: userName);
  }

  void incrementQuantity(int index) {
    _cartItems[index].quantity++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}