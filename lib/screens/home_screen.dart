import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_app_bar.dart';  // Import the custom app bar
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'مرحبا، ${userName ?? '...'}',
          showDrawer: true,
        ),
        drawer: _buildDrawer(context),
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
                  const SizedBox(height: 200),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureTile(
                          context,
                          'محادثات',
                          'assets/chat.svg',
                          () {
                            Navigator.pushNamed(context, '/chats');
                          },
                        ),
                        _buildFeatureTile(
                          context,
                          'مهام',
                          'assets/tasks.svg',
                          () {
                            Navigator.pushNamed(context, '/task');
                          },
                        ),
                        _buildFeatureTile(
                          context,
                          'الإعدادات',
                          'assets/settings.svg',
                          () {
                            // Handle Settings
                          },
                        ),
                        _buildFeatureTile(
                          context,
                          'الدعم الفني',
                          'assets/call-center.svg',
                          () {
                            // Handle Support
                          },
                        ),
                      ],
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

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: const Color.fromARGB(144, 1, 97, 232),
          ),
          child: Text(
            'Welcome, ${userName ?? 'User'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.task),
          title: const Text('Tasks'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/task');
          },
        ),
        // Additional items...
        const Divider(), // Add a separator before the logout button
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            // Perform logout logic here
            await _logout(context); // Call the logout method
          },
        ),
      ],
    ),
  );
}

Future<void> _logout(BuildContext context) async {
  // Clear any user-related data from SharedPreferences (or other storage)
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all saved data (like user session)

  // Navigate to the login screen
  Navigator.pushReplacementNamed(context, '/login');
}


  Widget _buildFeatureTile(
      BuildContext context, String title, String assetName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(144, 1, 97, 232),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetName,
              width: 60,
              height: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'AbdElRady',
                fontSize: 18,
                color: Colors.white,
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
