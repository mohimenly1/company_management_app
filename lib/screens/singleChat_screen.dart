import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key});

  @override
  _SingleChatScreenState createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  List<dynamic> messages = [];
  bool isLoading = true;
  String messageText = "";
  int? userId;
  int? otherUserId;
  final ScrollController _scrollController = ScrollController();  // Add scroll controller

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      otherUserId = args['userId'];

      if (userId == null || otherUserId == null) return;

      final response = await http.get(
        Uri.parse('http://192.168.185.37:8000/api/message/private/$userId/$otherUserId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
          isLoading = false;
        });
        _scrollToBottom();  // Scroll to the latest message
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        print('Network issue: $e');
      } else {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> sendMessage() async {
    if (messageText.isEmpty) return;

    try {
      final newMessage = {
        'sender_id': userId,
        'receiver_id': otherUserId,
        'message': messageText,
        'created_at': DateTime.now().toIso8601String(),  // Add a local timestamp for display
      };

      // Update UI immediately
      setState(() {
        messages.add(newMessage);
        messageText = "";
        _scrollToBottom();
      });

      final response = await http.post(
        Uri.parse('http://192.168.185.37:8000/api/message/private'),
        body: jsonEncode({
          'sender_id': userId,
          'receiver_id': otherUserId,
          'message': newMessage['message'],
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        print('Failed to send message: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final memberName = args['name'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color.fromARGB(144, 1, 97, 232),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              backgroundImage: const NetworkImage("https://i.postimg.cc/cCsYDjvj/user-2.png"),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memberName, style: const TextStyle(fontSize: 16)),
                const Text("Active now", style: TextStyle(fontSize: 12))
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final bool isCurrentUser = message['sender_id'] == userId;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue[100]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                message['created_at'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() {
                      messageText = value;
                    }),
                    decoration: const InputDecoration(hintText: "Type message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
