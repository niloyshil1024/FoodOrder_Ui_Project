import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../utils/urls.dart';

class ApiService {
  Future<List<FoodModel>> getFoods() async {
    try {
      final response = await http.get(Uri.parse(Urls.getFoods));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // যদি ডাটা সরাসরি লিস্ট আকারে আসে
        if (decodedData is List) {
          return decodedData.map((item) => FoodModel.fromJson(item)).toList();
        }
        // যদি ডাটা {"success": true, "data": [...]} ফরম্যাটে আসে
        else if (decodedData is Map<String, dynamic> && decodedData['data'] != null) {
          final List<dynamic> foodList = decodedData['data'];
          return foodList.map((item) => FoodModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching foods: $e");
      return [];
    }
  }
}