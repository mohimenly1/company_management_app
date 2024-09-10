import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<dynamic> teamMembers = [];
  String teamName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamMembers();
  }

Future<void> fetchTeamMembers() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('auth_token');

    if (userId == null || token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.185.37:8000/api/user/$userId/team-members/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        teamMembers = data;

        if (teamMembers.isNotEmpty) {
          final leader = teamMembers[0]['team']['leader'];
          teamName = teamMembers[0]['team']['name'];

          // Check if the leader is already in the teamMembers list
          bool leaderExists = teamMembers.any((member) => member['user']['id'] == leader['id']);

          if (!leaderExists) {
            // If leader isn't in the list, add the leader to teamMembers
            teamMembers.insert(0, {'user': leader, 'isLeader': true});
          }
        }
        isLoading = false;
      });
    } else {
      print('Failed to fetch team members');
    }
  } catch (e) {
    print('Error fetching team members: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color.fromARGB(144, 1, 97, 232),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(teamName.isNotEmpty ? teamName : "Team"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            color: const Color.fromARGB(144, 1, 97, 232),
            child: Row(
              children: [
                FillOutlineButton(press: () {}, text: "Recent Message"),
                const SizedBox(width: 16.0),
                FillOutlineButton(
                  press: () {},
                  text: "Active",
                  isFilled: false,
                ),
              ],
            ),
          ),
Expanded(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            final member = teamMembers[index]['user'];
            final isLeader = teamMembers[index]['isLeader'] ?? false;

            return ChatCard(
              chat: Chat(
                name: member['name'],
                lastMessage: isLeader ? 'Leader' : 'Member',
                image: '',  // Placeholder for images
                time: '',   // Placeholder for time
                isActive: false,
              ),
              press: () {
                // Navigate to SingleChatScreen and pass the member details
                Navigator.pushNamed(
                  context,
                  '/singleChat',
                  arguments: {
                    'userId': member['id'], // Send the member's ID
                    'name': member['name'], // Send the member's name
                  },
                );
              },
            );
          },
        ),
),

        ],
      ),
    );
  }
}

class FillOutlineButton extends StatelessWidget {
  const FillOutlineButton({
    super.key,
    this.isFilled = true,
    required this.press,
    required this.text,
  });

  final bool isFilled;
  final VoidCallback press;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Colors.white),
      ),
      elevation: isFilled ? 2 : 0,
      color: isFilled ? Colors.white : Colors.transparent,
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(
          color: isFilled ? const Color(0xFF1D1D35) : Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.chat,
    required this.press,
  });

  final Chat chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0 * 0.75),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300], // Placeholder background
              child: Text(chat.name[0]), // Display first letter of name
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(chat.time.isNotEmpty ? chat.time : 'No Time'),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  final String name, lastMessage, image, time;
  final bool isActive;

  Chat({
    this.name = '',
    this.lastMessage = 'ssssss',
    this.image = '',
    this.time = '',
    this.isActive = false,
  });
}
