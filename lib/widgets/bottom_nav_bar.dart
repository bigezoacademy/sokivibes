import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.library_music),
        label: 'Library',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.upload_file),
          label: 'Upload',
        )
      else
        const BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: 'Downloads',
        ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        )
      else
        const BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Login',
        ),
    ];
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
    );
  }
}
