import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String token;
  final int userId;

  TaskService(this.token, this.userId);

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('http://192.168.185.37:8000/api/getUserTasks?user_id=$userId'), // Pass user ID in the query parameter
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> taskJson = json.decode(response.body);
      return taskJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}


class Task {
  final int id;
  final String title;
  final String? description;
  final List<Comment> comments;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.comments,
  });

  // Factory method to create a Task from a JSON object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? 'No title', // Handle missing titles
      description: json['description'], // Nullable field
      comments: (json['comments'] as List<dynamic>)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
    );
  }
}

class Comment {
  final String userName;
  final String comment;

  Comment({required this.userName, required this.comment});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userName: json['userName'] ?? 'Anonymous',
      comment: json['comment'] ?? '',
    );
  }
}
