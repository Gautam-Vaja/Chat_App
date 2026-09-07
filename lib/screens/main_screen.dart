import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3525CD);
    const unselectedColor = Color(0xFF64748B);

    final List<Widget> screens = [
      HomeScreen(
        onProfileTap: () {
          _onTabTapped(3); // Switch to Settings/Profile tab
        },
      ),
      _buildPlaceholderScreen("Calls", Icons.call_outlined),
      _buildPlaceholderScreen("People", Icons.people_outline),
      ProfileScreen(
        onBack: () {
          _onTabTapped(0); // Go back to Chats tab
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFF1F3F9), width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectedColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.history),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3525CD),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              "No $title Yet",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E202B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your $title will show up here.",
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
