import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserSupportScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserSupportScreen({super.key, required this.userId, required this.userName});

  @override
  State<UserSupportScreen> createState() => _UserSupportScreenState();
}

class _UserSupportScreenState extends State<UserSupportScreen> {
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserMessages();
  }

  Future<void> fetchUserMessages() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2/food_api/get_messages.php?user_id=${widget.userId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/food_api/send_user_message.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': widget.userId,
          'user_name': widget.userName,
          'user_message': _msgController.text.trim(),
          'location': _locationController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _msgController.clear();
        _locationController.clear();
        fetchUserMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message sent successfully!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support & Location", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF4B4B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Your Location / Address",
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _msgController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Message or Request",
                    prefixIcon: Icon(Icons.message, color: Colors.red),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendMessage,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4B)),
                    child: const Text("Send to Admin", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet!"))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                // অ্যাডমিন রিপ্লাইয়ের সঠিক ফিল্ড চেক করা হচ্ছে
                String adminReply = msg['admin_reply'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 Location: ${msg['address'] ?? msg['location'] ?? 'N/A'}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("💬 You: ${msg['message'] ?? msg['user_message'] ?? ''}"),
                        const Divider(),
                        adminReply.isNotEmpty
                            ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "🟢 Admin Reply: $adminReply",
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                            : const Text(
                          "⏳ Waiting for Admin response...",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}