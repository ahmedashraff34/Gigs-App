/// runner_home_screen.dart
/// ----------------------
/// Main screen for runners. Handles navigation between tabs (Home, Offers, My Tasks, Chat, Profile).
/// Fetches tasks, offers, and user info. Contains logic for filtering and displaying tasks, handling offers, and user profile actions.
///
/// Suggestions:
/// - This file is very large; consider splitting into smaller widgets and moving business logic to services or providers.
/// - Move helper widgets/classes to their own files in Widgets/.
/// - Use state management (Provider, Riverpod, Bloc) for complex state.
/// - Remove commented-out or unused code.
import 'package:flutter/material.dart';
import '../widgets/runner_nav_bar.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/my_tasks_card.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';
import 'accepted_task_detail_screen.dart';
import 'auth.dart';
import '../models/offer.dart';
import '../services/token_service.dart';
import '../Screens/chat_page.dart';
import '../services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../Widgets/chat_card.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'poster_home_screen.dart';
import '../models/task_response.dart';
import '../widgets/profile_screen_widget.dart';
import 'package:geolocator/geolocator.dart';
import '../Widgets/mytasks_runner_info.dart';

class RunnerHomeScreen extends StatefulWidget {
  const RunnerHomeScreen({super.key});

  @override
  State<RunnerHomeScreen> createState() => _RunnerHomeScreenState();
}

class _RunnerHomeScreenState extends State<RunnerHomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  late Future<List<TaskResponse>> _tasksFuture = Future.value([]);
  String _selectedCategory = 'All';
  Future<List<Map<String, dynamic>>>? _myOffersFuture;
  Future<List<Map<String, dynamic>>>? _acceptedOffersFuture;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.all_inclusive},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Event Staffing', 'icon': Icons.people},
    {'name': 'Delivery', 'icon': Icons.delivery_dining},
    {'name': 'Handyman', 'icon': Icons.handyman},
    {'name': 'Moving', 'icon': Icons.local_shipping},
    {'name': 'Technology', 'icon': Icons.computer},
    {'name': 'Gardening', 'icon': Icons.landscape},
  ];

  @override
  void initState() {
    super.initState();
    _fetchNearbyTasks();
    _loadMyOffers();
  }

  Future<void> _fetchNearbyTasks() async {
    try {
      // For testing: use hardcoded location (31.248, 30.061) and radius 1
      setState(() {
        _tasksFuture = _taskService.getNearbyTasks(
          latitude: 31.248,
          longitude: 30.061,
          radius: 300,
        );
      });
    } catch (e) {
      setState(() {
        _tasksFuture = Future.error('Failed to fetch tasks: \\${e.toString()}');
      });
    }
  }

  /// Loads the offers and accepted offers for the current runner.
  /// Used in initState and when refreshing offers.
  Future<void> _loadMyOffers() async {
    final runnerId = await TokenService.getUserId();
    if (runnerId == null) return;
    setState(() {
      _myOffersFuture = _fetchOffersWithTasks(runnerId);
      _acceptedOffersFuture = _fetchAcceptedOffersWithTasks(runnerId);
    });
  }

  /// Fetches all offers made by the runner and their associated tasks.
  /// Used by _loadMyOffers and the "My Proposals" tab.
  Future<List<Map<String, dynamic>>> _fetchOffersWithTasks(String runnerId) async {
    final offers = await _taskService.getOffersByRunner(runnerId);
    List<Map<String, dynamic>> result = [];
    for (final offer in offers) {
      try {
        final task = await _taskService.getTaskById(offer.taskId ?? offer.id);
        result.add({'offer': offer, 'task': TaskResponse.fromJson(task.toJson())});
      } catch (_) {
        result.add({'offer': offer, 'task': null});
      }
    }
    return result;
  }

  /// Fetches all accepted offers by the runner and their associated tasks.
  /// Used by _loadMyOffers and the "My Tasks" tab.
  Future<List<Map<String, dynamic>>> _fetchAcceptedOffersWithTasks(String runnerId) async {
    print('[DEBUG] _fetchAcceptedOffersWithTasks called with runnerId: $runnerId');
    try {
      // The getAcceptedOffersByRunner method now returns the data directly
      final result = await _taskService.getAcceptedOffersByRunner(runnerId);
      print('[DEBUG] getAcceptedOffersByRunner returned ${result.length} items');
      
      print('[DEBUG] _fetchAcceptedOffersWithTasks returning ${result.length} items');
      return result;
    } catch (e) {
      print('[DEBUG] Error in _fetchAcceptedOffersWithTasks: $e');
      rethrow;
    }
  }

  /// Deletes an offer by its ID. Used in the "My Proposals" tab when cancelling an offer.
  Future<void> _deleteOffer(String offerId) async {
    final result = await _taskService.deleteOffer(offerId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer deleted.')));
      _loadMyOffers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete offer: \\${result['error']}')));
    }
  }

  /// Handles navigation when a bottom navigation bar item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Handles tapping a task card in the home tab. Used in the home tab ListView.
  // void _handleTaskTap(TaskResponse task) {
  //   // TODO: Update navigation to use TaskResponse
  // }

  /// Handles tapping an accepted task in the "My Tasks" tab. Used in MyTasksCard.
  // void _handleAcceptedTaskTap(TaskResponse task, Offer offer) {
  //   // TODO: Update navigation to use TaskResponse
  // }

  /// Logs out the current user and navigates to the AuthScreen. Used in the profile tab.
  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  /// Builds the horizontal category selection buttons. Used in the home tab.
  Widget _buildCategoryButtons() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['name'];
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the greeting at the top of the home tab. Used in the home tab.
  Widget _buildHomeGreeting() {
    return FutureBuilder<String?>(
      future: TokenService.getToken(),
      builder: (context, snapshot) {
        String name = '';
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          try {
            final user = JwtDecoder.decode(snapshot.data!);
            name = user['firstName'] ?? user['username'] ?? user['name'] ?? user['sub'] ?? 'User';
          } catch (_) {}
        }
        // Time-based greeting
        String greeting = 'Good Morning';
        final hour = DateTime.now().hour;
        if (hour >= 12 && hour < 17) {
          greeting = 'Good Afternoon';
        } else if (hour >= 17 || hour < 4) {
          greeting = 'Good Evening';
        }
        return Container(
          width: double.infinity,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 28, color: Theme.of(context).colorScheme.primary),
                    Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                    Stack(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 28, color: Theme.of(context).colorScheme.primary),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8, bottom: 2),
                child: Text(
                  'Hi ${name.isNotEmpty ? name : 'User'}!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 16),
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the main body of the screen based on the selected tab.
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Home (was Explore)
        // Home Tab: Shows greeting, category buttons, and a list of all available tasks for the runner.
        // The user can filter tasks by category and tap a task to view details.
        return Column(
          children: [
            _buildHomeGreeting(), // Shows a personalized greeting at the top
            _buildCategoryButtons(), // Horizontal scrollable list of categories
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchNearbyTasks();
                },
                child: FutureBuilder<List<TaskResponse>>(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('An error occurred: \\${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No tasks available at the moment.'));
                    }

                    // Helper to normalize category names for comparison (e.g., 'Event Staffing' == 'EventStaffing')
                    String normalizeCategoryName(String name) =>
                        name.replaceAll(' ', '').replaceAll('_', '').toLowerCase();

                    final tasks = snapshot.data!;
                    // List of TaskCards for each available task, filtered by selected category
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        // Use normalization so UI category names and enum names match (e.g., 'Event Staffing' and 'EventStaffing')
                        if (_selectedCategory == 'All' ||
                            normalizeCategoryName(task.category.name) == normalizeCategoryName(_selectedCategory)) {
                          return TaskCard(
                            task: task,
                            onTap: () {
                              // Navigates to the task detail screen for this task
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailScreen(task: task),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      case 1: // Offers (was My Offers)
        // My Proposals Tab: Shows all offers the runner has made on tasks.
        // The user can edit or cancel their offers here.
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _myOffersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(child: Text('You have not made any offers yet.'));
            }
            // List of MyTasksCard for each offer made by the runner
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'My Proposals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.shield_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Never send payment or share sensitive info outside the app. All communication should stay within the platform for your safety.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final offer = data[index]['offer'] as Offer;
                      final task = data[index]['task'] as TaskResponse?;
                      if (task == null) {
                        return ListTile(title: Text('Task not found for offer \\${offer.id}'));
                      }
                      // Each MyTasksCard shows the offer details and allows editing/cancelling
                      return Column(
                        children: [
                          MyTasksCard(
                            taskTitle: task.title,
                            taskType: task.category.name,
                            status: offer.message,
                            deadline: task.additionalAttributes['startTime'] != null ? DateTime.tryParse(task.additionalAttributes['startTime']) ?? DateTime.now() : DateTime.now(),
                            offerAmount: offer.amount,
                            taskPoster: task.taskPoster.toString(),
                            onTap: () {},
                            taskPosterImage: 'https://via.placeholder.com/50',
                            onCancel: () async {
                              // Cancels the offer
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Offer'),
                                  content: const Text('Are you sure you want to cancel this offer?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Yes, Cancel'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _deleteOffer(offer.id);
                              }
                            },
                            onEdit: () async {
                              // Allows editing the offer amount/message
                              final amountController = TextEditingController(text: offer.amount.toString());
                              final messageController = TextEditingController(text: offer.message);
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Theme.of(context).colorScheme.background,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      left: 24,
                                      right: 24,
                                      top: 24,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        Text('Edit Offer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                        const SizedBox(height: 18),
                                        TextField(
                                          controller: amountController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Offer Amount',
                                            prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            filled: true,
                                            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        TextField(
                                          controller: messageController,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            labelText: 'Message',
                                            prefixIcon: Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            filled: true,
                                            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Dummy: just close the sheet
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: const Text('Save Changes'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            onChat: () async {
                              final myUserId = await TokenService.getUserId();
                              final otherUserId = task.taskPoster.toString();
                              final otherUserName = task.additionalRequirements['posterName'] ?? 'User #$otherUserId';
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    otherUserId: otherUserId,
                                    otherUserName: otherUserName,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      case 2: // My Tasks (was Assigned Tasks)
        // My Tasks Tab: Shows all tasks for which the runner's offer was accepted.
        // Tasks are grouped by status: In Progress, Completed, Cancelled.
        // The user can tap a task to view details or raise a dispute for cancelled tasks.
        return RefreshIndicator(
          onRefresh: () async {
            print('[DEBUG] Refreshing My Tasks tab');
            await _loadMyOffers();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _acceptedOffersFuture,
            builder: (context, snapshot) {
              print('[DEBUG] My Tasks FutureBuilder - ConnectionState: ${snapshot.connectionState}');
              print('[DEBUG] My Tasks FutureBuilder - HasError: ${snapshot.hasError}');
              print('[DEBUG] My Tasks FutureBuilder - HasData: ${snapshot.hasData}');
              if (snapshot.hasError) {
                print('[DEBUG] My Tasks FutureBuilder - Error: ${snapshot.error}');
              }
              if (snapshot.hasData) {
                print('[DEBUG] My Tasks FutureBuilder - Data length: ${snapshot.data?.length}');
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                print('[DEBUG] My Tasks tab - No data to display');
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No assigned tasks yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your accepted offers will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              print('[DEBUG] My Tasks tab - Processing ${data.length} items');
              
              // Split tasks by status
              final inProgress = data.where((item) {
                final status = (item['task'] as TaskResponse?)?.status?.toLowerCase();
                print('[DEBUG] Task status: $status');
                // Handle different status formats
                return status == 'in progress' || 
                       status == 'in_progress' || 
                       status == 'accepted' ||
                       status == 'inprogress';
              }).toList();
              final completed = data.where((item) {
                final status = (item['task'] as TaskResponse?)?.status?.toLowerCase();
                return status == 'completed' || status == 'done';
              }).toList();
              final cancelled = data.where((item) {
                final status = (item['task'] as TaskResponse?)?.status?.toLowerCase();
                return status == 'cancelled' || status == 'canceled';
              }).toList();
              
              print('[DEBUG] My Tasks tab - In Progress: ${inProgress.length}, Completed: ${completed.length}, Cancelled: ${cancelled.length}');
              
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (inProgress.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        'Assigned Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...inProgress.map((item) {
                      final offer = item['offer'] as Offer;
                      final task = item['task'] as TaskResponse;
                      print('[DEBUG] Displaying in-progress task: ${task.title}');
                      return MyTasksCard(
                        taskTitle: task.title,
                        taskType: task.category.name,
                        status: 'In Progress',
                        deadline: task.additionalAttributes['startTime'] != null ? DateTime.tryParse(task.additionalAttributes['startTime']) ?? DateTime.now().add(const Duration(days: 7)) : DateTime.now().add(const Duration(days: 7)),
                        offerAmount: offer.amount,
                        taskPoster: 'Task Poster #${task.taskPoster}',
                        taskPosterImage: 'https://via.placeholder.com/50',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyTasksRunnerInfo(
                                task: task,
                                onChat: null, // handled in MyTasksRunnerInfo
                              ),
                            ),
                          );
                        },
                        onChat: () async {
                          final myUserId = await TokenService.getUserId();
                          final otherUserId = task.taskPoster.toString();
                          final otherUserName = task.additionalRequirements['posterName'] ?? 'User #$otherUserId';
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                otherUserId: otherUserId,
                                otherUserName: otherUserName,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                  if (completed.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
                      child: Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...completed.map((item) {
                      final offer = item['offer'] as Offer;
                      final task = item['task'] as TaskResponse;
                      print('[DEBUG] Displaying completed task: ${task.title}');
                      return MyTasksCard(
                        taskTitle: task.title,
                        taskType: task.category.name,
                        status: 'Completed',
                        deadline: task.additionalAttributes['startTime'] != null ? DateTime.tryParse(task.additionalAttributes['startTime']) ?? DateTime.now().add(const Duration(days: 7)) : DateTime.now().add(const Duration(days: 7)),
                        offerAmount: offer.amount,
                        taskPoster: 'Task Poster #${task.taskPoster}',
                        taskPosterImage: 'https://via.placeholder.com/50',
                        onTap: () {
                          // Navigates to accepted task detail screen (implement if needed)
                        },
                      );
                    }).toList(),
                  ],
                  if (cancelled.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
                      child: Text(
                        'Cancelled Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...cancelled.map((item) {
                      final offer = item['offer'] as Offer;
                      final task = item['task'] as TaskResponse;
                      print('[DEBUG] Displaying cancelled task: ${task.title}');
                      return Row(
                        children: [
                          Expanded(
                            child: MyTasksCard(
                              taskTitle: task.title,
                              taskType: task.category.name,
                              status: 'Cancelled',
                              deadline: task.additionalAttributes['startTime'] != null ? DateTime.tryParse(task.additionalAttributes['startTime']) ?? DateTime.now().add(const Duration(days: 7)) : DateTime.now().add(const Duration(days: 7)),
                              offerAmount: offer.amount,
                              taskPoster: 'Task Poster #${task.taskPoster}',
                              taskPosterImage: 'https://via.placeholder.com/50',
                              onTap: () {
                                // Navigates to accepted task detail screen (implement if needed)
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implement raise dispute action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Raise Dispute clicked!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Raise Dispute'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                  if (inProgress.isEmpty && completed.isEmpty && cancelled.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: Text('No assigned, completed, or cancelled tasks yet.')),
                    ),
                ],
              );
            },
          ),
        );
      case 3: // Chat (was Chat, previously index 5)
        // Chat Tab: Shows all chat conversations for the runner.
        // The user can search, view, and tap to open a chat with another user.
        final myUserIdFuture = TokenService.getUserId();
        return FutureBuilder<String?>(
          future: myUserIdFuture,
          builder: (context, snapshot) {
            final myUserId = snapshot.data;
            if (myUserId == null) return const Center(child: CircularProgressIndicator());
            return _ChatTabWithSearchAndSettings(myUserId: myUserId);
          },
        );
      case 4: // Profile
        // Profile Tab: Shows the runner's profile, stats, and allows switching roles or logging out.
        return ProfileScreenWidget(
          isRunner: true,
          onSwitchRole: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PosterHomeScreen()),
            );
          },
          switchRoleLabel: 'Switch to Poster',
        );
      default:
        return const Center(
          child: Text('Unknown Tab'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Main build method for the RunnerHomeScreen.
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: RunnerNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class _ChatTabWithSearchAndSettings extends StatefulWidget {
  final String myUserId;
  const _ChatTabWithSearchAndSettings({required this.myUserId});

  @override
  State<_ChatTabWithSearchAndSettings> createState() => _ChatTabWithSearchAndSettingsState();
}

class _ChatTabWithSearchAndSettingsState extends State<_ChatTabWithSearchAndSettings> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search message',
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Implement settings action
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ListView(
                      shrinkWrap: true,
                      children: const [
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Settings'),
                        ),
                        ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: ChatService().getUserChats(widget.myUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No chats yet.'));
              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final lastMessage = (data['lastMessage'] ?? '').toString().toLowerCase();
                final users = List<String>.from(data['users']);
                final otherUserId = users.firstWhere((id) => id != widget.myUserId, orElse: () => '');
                // For name, we need to fetch user data, so filter by lastMessage only here
                return lastMessage.contains(_searchQuery.toLowerCase());
              }).toList();
              return ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, i) {
                  final data = filteredDocs[i].data() as Map<String, dynamic>;
                  final users = List<String>.from(data['users']);
                  final otherUserId = users.firstWhere((id) => id != widget.myUserId, orElse: () => '');
                  final lastMessage = data['lastMessage'] ?? '';
                  final lastTimestamp = data['lastTimestamp'] != null
                      ? (data['lastTimestamp'] as Timestamp).toDate()
                      : null;
                  return FutureBuilder<UserModel?>(
                    future: AuthService().getUserData(otherUserId),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data;
                      final fullName = user != null
                          ? '${user.firstName} ${user.lastName}'
                          : 'User $otherUserId';
                      final avatarUrl = user?.profileImageUrl ?? 'https://via.placeholder.com/50';
                      final timeStr = lastTimestamp != null
                          ? '${lastTimestamp.hour}:${lastTimestamp.minute.toString().padLeft(2, '0')}'
                          : '';
                      // Also filter by name if needed
                      if (_searchQuery.isNotEmpty &&
                          !fullName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                          !lastMessage.toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
                        return const SizedBox.shrink();
                      }
                      return ChatCard(
                        name: fullName,
                        lastMessage: lastMessage,
                        time: timeStr,
                        avatarUrl: avatarUrl,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                otherUserId: otherUserId,
                                otherUserName: fullName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 
