import 'package:flutter/material.dart';
import 'package:food_order_ui/screens/login_screen.dart';
// আপনার প্রজেক্টের সঠিক পাথ অনুযায়ী নিচে স্ক্রিনগুলোর ফাইল ইমপোর্ট করে নিন:
import 'all_orders_screen.dart';
import 'manage_foods_screen.dart';
import 'add_food_screen.dart';
import 'users_screen.dart';
import 'admin_support_messages_screen.dart'; // 👈 সাপোর্ট স্ক্রিনের ফাইলটি এখানে ইমপোর্ট করে নিবেন
// import 'login_screen.dart'; // আপনার লগইন স্ক্রিনের ফাইলটি এখানে ইমপোর্ট করে নিবেন

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // লগইন পেজে যাওয়ার এবং রাউট ক্লিয়ার করার ফাংশন
  void _goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // 👈 আপনার লগইন স্ক্রিনের নাম এখানে বসাবেন (যেমন: const LoginScreen())
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToLogin(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF5252),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _goToLogin(context),
          ),
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dashboard Refreshed!')),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // টপ স্ট্যাটাস কার্ড (Total Foods & Total Orders)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageFoodsScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fastfood, color: Color(0xFFFF5252), size: 30),
                            SizedBox(height: 12),
                            Text(
                              'Foods',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage Foods',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Material(
                      color: const Color(0xFFEEF5FF),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllOrdersScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.shopping_bag, color: Colors.blue, size: 30),
                              SizedBox(height: 12),
                              Text(
                                'Orders',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'View All Orders',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action কার্ডগুলোর গ্রিড
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  // ১. Add Food
                  _buildActionCard(
                    context,
                    icon: Icons.add_circle_outline,
                    iconColor: Colors.green,
                    title: 'Add Food',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFoodScreen(),
                        ),
                      );
                    },
                  ),
                  // ২. Manage Foods
                  _buildActionCard(
                    context,
                    icon: Icons.restaurant_menu,
                    iconColor: Colors.purple,
                    title: 'Manage Foods',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageFoodsScreen(),
                        ),
                      );
                    },
                  ),
                  // ৩. View Orders
                  _buildActionCard(
                    context,
                    icon: Icons.list_alt,
                    iconColor: Colors.blue,
                    title: 'View Orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllOrdersScreen()),
                      ).then((value) {
                        // 🎯 এই লাইনটি যোগ করার ফলে AllOrdersScreen থেকে ব্যাক করে আসার সাথে সাথে
                        // ব্যাকগ্রাউন্ডে অটোমেটিক নতুন অর্ডারগুলো আবার ফেচ (fetch) হয়ে স্ক্রিন আপডেট হয়ে যাবে।
                        setState(() {});
                      });
                    },
                  ),
                  // ৪. Users
                  _buildActionCard(
                    context,
                    icon: Icons.people_outline,
                    iconColor: Colors.teal,
                    title: 'Users List',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UsersScreen(),
                        ),
                      );
                    },
                  ),
                  // ৫. Support Requests (👈 এখানে নতুন কার্ডটি বসানো হয়েছে)
                  _buildActionCard(
                    context,
                    icon: Icons.support_agent,
                    iconColor: Colors.orange,
                    title: 'Support Requests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminSupportScreen(),                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}