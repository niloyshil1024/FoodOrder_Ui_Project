import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageFoodsScreen extends StatefulWidget {
  const ManageFoodsScreen({super.key});

  @override
  State<ManageFoodsScreen> createState() => _ManageFoodsScreenState();
}

class _ManageFoodsScreenState extends State<ManageFoodsScreen> {
  List foods = [];
  List filteredFoods = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2/food_api/get_foods.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is List) {
            foods = data;
          } else if (data is Map && data['foods'] != null) {
            foods = data['foods'];
          } else {
            foods = [];
          }
          filteredFoods = List.from(foods);
        });
      }
    } catch (e) {
      print("Error fetching foods: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFoods = List.from(foods);
      } else {
        filteredFoods = foods
            .where((food) => (food['name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // 🖼️ Smart Image Builder (Assets, Network & Local Uploads)
  Widget _buildFoodImage(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const Icon(Icons.fastfood, color: Color(0xFFFF4B4B));
    }

    String path = imagePath.trim();

    if (path.startsWith('assets/')) {
      return Image.asset(path, width: 50, height: 50, fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image));
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, width: 50, height: 50, fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image));
    }

    return Image.network("http://10.0.2.2/food_api/uploads/$path",
        width: 50, height: 50, fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.image));
  }

  // 🗑️ Delete Method
  Future<void> deleteFood(String id) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/food_api/delete_food.php"),
        body: {'id': id},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          foods.removeWhere((item) => item['id'].toString() == id.toString());
          _filterFoods(_searchController.text);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food deleted!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  // ✏️ Update Method (Now with Image)
  Future<void> updateFood(String id, String newName, String newPrice, String newImage) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/food_api/edit_food.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': id,
          'name': newName,
          'price': newPrice,
          'image': newImage, // ছবি আপডেট
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          for (var item in foods) {
            if (item['id'].toString() == id.toString()) {
              item['name'] = newName;
              item['price'] = newPrice;
              item['image'] = newImage;
            }
          }
          _filterFoods(_searchController.text);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food updated successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Update failed!'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print("Update error: $e");
    }
  }

  // ✏️ Edit Dialog Box
  void showEditDialog(Map item) {
    TextEditingController nameController = TextEditingController(text: item['name'].toString());
    TextEditingController priceController = TextEditingController(text: item['price'].toString());
    TextEditingController imageController = TextEditingController(text: item['image']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Food"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Food Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: "Image Path / URL",
                  hintText: "e.g., assets/burger.png",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateFood(
                item['id'].toString(),
                nameController.text.trim(),
                priceController.text.trim(),
                imageController.text.trim(),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B4B),
        title: const Text("Manage Foods", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4B4B)))
          : Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFoods,
              decoration: InputDecoration(
                hintText: "Search food...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF4B4B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // 🍔 FOOD LIST (Now with Images!)
          Expanded(
            child: filteredFoods.isEmpty
                ? const Center(child: Text("No foods found!"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final item = filteredFoods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 55,
                        height: 55,
                        color: const Color(0xFFFFE5E5),
                        child: _buildFoodImage(item['image']),
                      ),
                    ),
                    title: Text(
                      item['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("\$${item['price']}", style: const TextStyle(color: Colors.green)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditDialog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteFood(item['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}