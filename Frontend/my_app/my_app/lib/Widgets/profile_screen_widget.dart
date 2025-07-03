/// profile_screen_widget.dart
/// -------------------------
/// Reusable profile screen widget for both runner and poster roles.
///
/// Usage:
///   ProfileScreenWidget(
///     isRunner: true/false,
///     onSwitchRole: () { ... },
///     statsLabel1: 'Tasks Done',
///     statsValue1: ...,
///     statsLabel2: 'Earnings',
///     statsValue2: ...,
///   )
///
/// This widget handles JWT decoding, user info display, and role switching.
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../Screens/auth.dart'; // Fix import for AuthScreen
import '../Screens/edit_profile_screen.dart'; // Added import for EditProfileScreen
import '../Widgets/emergency_location_button.dart'; // Added import for EmergencyLocationButton

class ProfileScreenWidget extends StatelessWidget {
  final bool isRunner;
  final VoidCallback onSwitchRole;
  final String switchRoleLabel;

  const ProfileScreenWidget({
    Key? key,
    required this.isRunner,
    required this.onSwitchRole,
    required this.switchRoleLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch and decode JWT for user info
    return FutureBuilder<String?>(
      future: TokenService.getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('Not logged in. Please log in again.'));
        }
        final token = snapshot.data!;
        Map<String, dynamic> user;
        try {
          user = JwtDecoder.decode(token);
        } catch (e) {
          return const Center(child: Text('Invalid session. Please log in again.'));
        }
        // Determine stats based on role
        int statsValue1;
        double statsValue2;
        String statsLabel1;
        String statsLabel2;
        String roleLabel;
        if (isRunner) {
          statsValue1 = user['completedTasks'] ?? 0;
          statsValue2 = (user['earnings'] is num) ? user['earnings'].toDouble() : 0.0;
          statsLabel1 = 'Tasks Done';
          statsLabel2 = 'Earnings';
          roleLabel = 'Runner';
        } else {
          statsValue1 = user['tasksPosted'] ?? 0;
          statsValue2 = (user['totalSpent'] is num) ? user['totalSpent'].toDouble() : 0.0;
          statsLabel1 = 'Tasks Posted';
          statsLabel2 = 'Total Spent';
          roleLabel = 'Task Poster';
        }
        final String name =
        user['firstName'] != null && user['lastName'] != null
            ? '${user['firstName']} ${user['lastName']}'
            : user['firstName'] ?? user['username'] ?? user['name'] ?? user['sub'] ?? 'No Name';
        final String initial = (name.isNotEmpty ? name.trim().split(' ')[0][0].toUpperCase() : 'U');
        // Main profile UI
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                constraints: const BoxConstraints(minHeight: 350),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: (user['profileImageUrl'] != null && (user['profileImageUrl'] as String).isNotEmpty)
                          ? NetworkImage(user['profileImageUrl'])
                          : null,
                      child: (user['profileImageUrl'] == null || (user['profileImageUrl'] as String).isEmpty)
                          ? Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Color(0xFF2C5364),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roleLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$statsValue1',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statsLabel1,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: Colors.white24,
                        ),
                        Column(
                          children: [
                            Text(
                              '\$${statsValue2.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statsLabel2,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // SOS Emergency Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Emergency',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    EmergencyLocationButton(
                      telegramNumber: '+1234567890', // TODO: Replace with real emergency contact
                      customMessage: '🚨 EMERGENCY: I need immediate help! 🚨',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Switch role button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSwitchRole,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(switchRoleLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Profile actions
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.edit, color: Colors.blue, size: 26),
                        ),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                firstName: user['firstName'] ?? '',
                                lastName: user['lastName'] ?? '',
                                email: user['email'] ?? '',
                                phoneNumber: user['phoneNumber'] ?? '',
                              ),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        hoverColor: Colors.grey[100],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.payment, color: Colors.blue, size: 26),
                        ),
                        title: Text(
                          'Payment History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          // TODO: Add your payment history logic here
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        hoverColor: Colors.grey[100],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.support_agent, color: Colors.blue, size: 26),
                        ),
                        title: Text(
                          'Support',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          // TODO: Add your support logic here
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        hoverColor: Colors.grey[100],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.logout, color: Colors.red, size: 26),
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          await TokenService.clearAuthData();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                                  (route) => false,
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        hoverColor: Colors.grey[100],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}