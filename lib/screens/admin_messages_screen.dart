import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  List messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllMessages();
  }

  Future<void> fetchAllMessages() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2/food_api/get_messages.php"),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendReply(String messageId, String replyText) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/food_api/send_admin_response.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'message_id': messageId,
          'admin_response': replyText,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchAllMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reply sent!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print("Error replying: $e");
    }
  }

  void showReplyDialog(Map messageItem) {
    TextEditingController replyController = TextEditingController(
      text: messageItem['admin_response'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reply to ${messageItem['user_name'] ?? 'User'}"),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Type response here...",
            border: OutlineInputBorder(),
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
              sendReply(messageItem['id'].toString(), replyController.text.trim());
            },
            child: const Text("Send Reply"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Messages & Location"),
        backgroundColor: const Color(0xFFFF4B4B),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
          ? const Center(child: Text("No user messages found!"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final item = messages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text("${item['user_name']} (ID: ${item['user_id']})", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("📍 Location: ${item['location'] ?? 'Not provided'}", style: const TextStyle(color: Colors.blue)),
                  Text("💬 Message: ${item['user_message']}"),
                  if (item['admin_response'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("✅ Replied: ${item['admin_response']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => showReplyDialog(item),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4B)),
                child: Text(item['admin_response'] == null ? "Reply" : "Edit Reply", style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}