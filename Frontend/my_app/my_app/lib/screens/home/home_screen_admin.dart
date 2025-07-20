// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
// import '../../services/user_service.dart';
// import '../../services/task_service.dart';
// import '../../models/user_model.dart';
// import '../../models/task_model.dart';
//
// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});
//
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   final AuthService _authService = AuthService();
//   final UserService _userService = UserService();
//   final TaskService _taskService = TaskService();
//   int _selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await _authService.signOut();
//               if (mounted) {
//                 Navigator.of(context).pushReplacementNamed('/auth');
//               }
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: _buildContent(),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Overview',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: 'Users',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.warning),
//             label: 'Disputes',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.assignment),
//             label: 'Tasks',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         onTap: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildOverview();
//       case 1:
//         return _buildUsersList();
//       case 2:
//         return _buildDisputesList();
//       case 3:
//         return _buildTasksList();
//       default:
//         return const Center(child: Text('Select a section'));
//     }
//   }
//
//   Widget _buildOverview() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Dashboard Overview',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Statistics Cards
//           FutureBuilder<List<UserModel>>(
//             future: _userService.getAllUsers(),
//             builder: (context, userSnapshot) {
//               int totalUsers = 0;
//               if (userSnapshot.hasData) {
//                 totalUsers = userSnapshot.data!.length;
//               }
//               return FutureBuilder<List<TaskResponse>>(
//                 future: _taskService.getAllTasks(),
//                 builder: (context, taskSnapshot) {
//                   int totalTasks = 0;
//                   if (taskSnapshot.hasData) {
//                     totalTasks = taskSnapshot.data!.length;
//                   }
//                   return LayoutBuilder(
//                     builder: (context, constraints) {
//                       int crossAxisCount = constraints.maxWidth > 1200 ? 4 :
//                         constraints.maxWidth > 800 ? 3 :
//                         constraints.maxWidth > 600 ? 2 : 1;
//                       return GridView.count(
//                         crossAxisCount: crossAxisCount,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                         childAspectRatio: 1.5,
//                         children: [
//                           _buildStatCard('Total Users', totalUsers.toString(), Icons.people),
//                           _buildStatCard('Total Tasks', totalTasks.toString(), Icons.assignment),
//                           _buildStatCard('Open Disputes', '0', Icons.warning),
//                           _buildStatCard('Completed Tasks', '0', Icons.check_circle),
//                           _buildStatCard('Total Revenue', '\$0', Icons.attach_money),
//                           _buildStatCard('Success Rate', '0%', Icons.trending_up),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 32, color: Theme.of(context).primaryColor),
//             const SizedBox(height: 8),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUsersList() {
//     return FutureBuilder<List<UserModel>>(
//       future: _userService.getAllUsers(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('An error occurred: \\${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No users found.'));
//         }
//
//         final users = snapshot.data!;
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final user = users[index];
//             return Card(
//               margin: const EdgeInsets.only(bottom: 8),
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 leading: CircleAvatar(
//                   backgroundImage: user.profileImageUrl != null
//                       ? NetworkImage(user.profileImageUrl!)
//                       : null,
//                   child: user.profileImageUrl == null
//                       ? const Icon(Icons.person)
//                       : null,
//                 ),
//                 title: Text('${user.firstName} ${user.lastName}'),
//                 subtitle: Text(user.email),
//                 trailing: Text(user.roles.join(', ')),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildDisputesList() {
//     return const Center(child: Text('Disputes section not implemented yet.'));
//   }
//
//   Widget _buildTasksList() {
//     return const Center(child: Text('Tasks section not implemented yet.'));
//   }
// }
