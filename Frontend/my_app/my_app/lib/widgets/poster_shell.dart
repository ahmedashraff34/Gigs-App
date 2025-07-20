import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../screens/home/home_screen_poster.dart';
import '../screens/messages_screen.dart';
import '../screens/task/my_tasks_screen.dart';
import '../screens/offers_screen.dart';
import '../screens/profile/profile_screen.dart';

class PosterShell extends StatefulWidget {
  const PosterShell({Key? key}) : super(key: key);

  @override
  State<PosterShell> createState() => _PosterShellState();
}

class _PosterShellState extends State<PosterShell> {
  int _currentIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenPoster();
      case 1:
        return MyTasksScreen();
      case 2:
        return MessagesScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeScreenPoster();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) => setState(() => _currentIndex = newIndex),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
