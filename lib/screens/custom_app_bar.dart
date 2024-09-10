import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showDrawer;
  final VoidCallback? onDrawerIconTap; // Add this line

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showDrawer = true,
    this.onDrawerIconTap, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(144, 1, 97, 232),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'AbdElRady',
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: showDrawer
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Open Drawer
                if (onDrawerIconTap != null) {
                  onDrawerIconTap!(); // Call the callback
                } else {
                  Scaffold.of(context).openDrawer(); // Default behavior
                }
              },
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
