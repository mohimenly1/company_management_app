import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/task_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/singleChat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login':(context) => const LoginScreen(),
        '/task': (context) =>  TaskScreen(),
        '/chats': (context) =>  ChatsScreen(),
        '/singleChat': (context) =>  SingleChatScreen(),
      },
    );
  }
}
