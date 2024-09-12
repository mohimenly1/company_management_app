import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x/screens/home_screen.dart';
// import 'task_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<void> _login() async {
  try {
    final response = await http.post(
      // IP 127.0.0.1:8000/api/login-app
      Uri.parse('http://192.168.185.37:8000/api/login-app'), // Replace with your API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']); // Save token
        await prefs.setInt('user_id', data['user']['id']);   // Save user ID

        // Navigate to the home screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Handle login error
        print('Login failed');
      }
    } else {
      print('Server error');
    }
  } catch (e) {
    print('Error during login: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Background Sun-like Curve
            Positioned(
              top: 0,
              right: -80,
              child: CustomPaint(
                size: const Size(200, 100),
                painter: SunPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'تسجيل الدخول',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AbdElRady',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      labelStyle: TextStyle(fontFamily: 'AbdElRady'),
                      prefixIcon: Icon(Icons.email),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'ادخل كلمة السر',
                      labelStyle: TextStyle(fontFamily: 'AbdElRady'),
                      prefixIcon: Icon(Icons.lock),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color.fromARGB(144, 1, 97, 232),
                    ),
                    child: const Text(
                      'تسجيل دخول',
                      style: TextStyle(
                        fontFamily: 'AbdElRady',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'ليس لديك حساب ؟ طلب انشاء حساب',
                      style: TextStyle(
                        fontFamily: 'AbdElRady',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..color = const Color.fromARGB(144, 1, 97, 232)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color.fromARGB(255, 1, 97, 232).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0);

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.66,
      shadowPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.5,
      sunPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
