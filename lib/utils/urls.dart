class Urls {
  Urls._();

  // Change this IP for Android Emulator!
  static const String baseUrl = "http://10.0.2.2/food_api";
  static const String getFoods = "$baseUrl/get_foods.php";
  static const String login = "$baseUrl/login.php";
  static const String register = "$baseUrl/register.php";
  static const String addFood = "$baseUrl/add_food.php";

  // নতুন এবং জরুরি এন্ডপয়েন্টগুলো এখানে যুক্ত করা হলো
  static const String placeOrder = "$baseUrl/place_order.php";
  static const String getAllOrders = "$baseUrl/get_all_orders.php";
  static const String updateStatus = "$baseUrl/update_status.php";
  static const String getUserOrders = "$baseUrl/get_user_orders.php";

  static const String dashboardStats = "$baseUrl/get_dashboard_stats.php";
  static const String getSupportMessages = "$baseUrl/get_support_messages.php";
  static String sendSupportMessage = "$baseUrl/send_support_messages.php";
}