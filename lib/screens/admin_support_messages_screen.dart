import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  List supportMessages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSupportMessages();
  }

  // অ্যাডমিনের জন্য সব ইউজারের মেসেজ ফেচ করা
  Future<void> fetchSupportMessages() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2/food_api/get_support_messages.php"),
      );
      if (response.statusCode == 200) {
        setState(() {
          supportMessages = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // অ্যাডমিন কর্তৃক রিপ্লাই পাঠানোর ডায়ালগ ও ফাংশন
  void showReplyDialog(String messageId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send Reply to User"),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Type your reply here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4B)),
              onPressed: () async {
                if (replyController.text.trim().isEmpty) return;

                Navigator.pop(context);

                try {
                  final response = await http.post(
                    Uri.parse("http://10.0.2.2/food_api/send_admin_response.php"),
                    body: {
                      'id': messageId,
                      'admin_reply': replyController.text.trim(),
                    },
                  );

                  final data = jsonDecode(response.body);
                  if (data['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reply sent successfully!"), backgroundColor: Colors.green),
                    );
                    fetchSupportMessages(); // লিস্ট রিফ্রেশ করা
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? "Failed to send reply")),
                    );
                  }
                } catch (e) {
                  print("Error sending reply: $e");
                }
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Support Panel", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF4B4B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : supportMessages.isEmpty
          ? const Center(child: Text("No support messages found!"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: supportMessages.length,
        itemBuilder: (context, index) {
          final msg = supportMessages[index];
          String userName = msg['user_name'] ?? 'Unknown User';
          String address = msg['address'] ?? 'N/A';
          String message = msg['message'] ?? '';
          String adminReply = msg['admin_reply'] ?? '';
          String messageId = msg['id'].toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 ইউজারের নাম শো করানো
                  Text(
                    "👤 User: $userName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("📍 Location: $address", style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("💬 Message: $message"),
                  const Divider(height: 16),

                  // অ্যাডমিন রিপ্লাই স্ট্যাটাস এবং বাটন
                  adminReply.isNotEmpty
                      ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "🟢 Your Reply: $adminReply",
                      style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "⏳ No reply given yet",
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showReplyDialog(messageId),
                        icon: const Icon(Icons.reply, size: 16, color: Colors.white),
                        label: const Text("Reply", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(80, 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}