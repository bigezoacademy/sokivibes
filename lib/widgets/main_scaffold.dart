import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart';

class MainScaffold extends StatefulWidget {
  final List<Widget> pages;
  const MainScaffold({Key? key, required this.pages}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    return Scaffold(
      body: widget.pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        isAdmin: isAdmin,
      ),
    );
  }
}
