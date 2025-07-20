import 'package:flutter/material.dart';
import 'dispute_list_screen.dart';
import 'admin_disputes_table.dart';
import '../widgets/dispute_info_card.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import 'admin_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserService _userService = UserService();

  void _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.deepPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from the admin dashboard?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Perform logout
      await _userService.logoutUser();
      
      // Navigate to login screen and clear navigation stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dispute Statistics Card
          const DisputeInfoCard(),
          
          const SizedBox(height: 24),
          
          // Admin Actions
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people, color: Colors.deepPurple),
              ),
              title: const Text(
                'Users',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('View and manage all users'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUsersScreen()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment, color: Colors.deepPurple),
              ),
              title: const Text(
                'Tasks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('View and manage all tasks'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to tasks management
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.report, color: Colors.deepPurple),
              ),
              title: const Text(
                'Disputes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('View and resolve disputes'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDisputesTable()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications, color: Colors.orange),
              ),
              title: const Text(
                'Test Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Test local and FCM notifications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Test local notification
                // await NotificationService.sendTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}