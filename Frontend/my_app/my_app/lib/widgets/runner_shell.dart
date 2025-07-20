import 'package:ali_grad/screens/messages_screen.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/runner_offers_screen.dart';
import '../screens/home/home_screen_runner.dart';

class MyOffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('My Offers'));
}

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Chats'));
}

class RunnerShell extends StatefulWidget {
  const RunnerShell({Key? key}) : super(key: key);

  @override
  State<RunnerShell> createState() => _RunnerShellState();
}

class _RunnerShellState extends State<RunnerShell> {
  int _currentIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenRunner();
      case 1:
        return RunnerOffersScreen();
      case 2:
        return MessagesScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeScreenRunner();
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
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in),
            label: 'My Offers',
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
