import 'package:flutter/material.dart';
import '../service/TaskService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/custom_app_bar.dart'; // Import your custom AppBar

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Future<List<Task>> futureTasks;
  String? authToken;
  List<TextEditingController> commentControllers = []; // List of controllers

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
      int? userId = prefs.getInt('user_id');

      if (authToken != null && userId != null) {
        futureTasks = TaskService(authToken!, userId).fetchTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          title: 'أهلا بك',
          showDrawer: true,
          onDrawerIconTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        drawer: _buildDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: authToken == null
              ? Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Task>>(
                  future: futureTasks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Failed to load tasks: ${snapshot.error}'));
                    } else {
                      final tasks = snapshot.data ?? [];

                      // Initialize a controller for each task
                      commentControllers = List.generate(
                          tasks.length, (index) => TextEditingController());

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'AbdElRady',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    task.description ?? 'No Description',
                                    style: TextStyle(
                                      fontFamily: 'AbdElRady',
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: commentControllers[index], // Use individual controller
                                    decoration: InputDecoration(
                                      labelText: 'اكتب تعليق',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog(
                                          'ارسال',
                                          commentControllers[index].text, // Pass comment of the specific task
                                          task.id,
                                        );
                                      },
                                      child: Text(
                                        'ارسال تعليق',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'AbdElRady',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 12,
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }

void _showConfirmationDialog(String action, String comment, int taskId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'تأكيد $action',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد إرسال هذا التعليق؟\n\n$comment',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: Text(
              'الغاء',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'تأكيد',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _sendComment(comment, taskId); // Pass task ID here
            },
          ),
        ],
      );
    },
  );
}


void _sendComment(String comment, int taskId) async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');  // Retrieve the user ID
  final response = await http.post(
    Uri.parse('http://192.168.185.37:8000/api/task/comment'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
    body: jsonEncode({
      'task_id': taskId,
      'user_id': userId, // Pass the user ID retrieved from SharedPreferences
      'comment': comment,
    }),
  );

  if (response.statusCode == 201) {
    print('Comment added successfully');
    commentControllers.clear();
    // You can refresh the comments section here if needed
  } else {
    print(json.decode(response.body));
  }
}

}
