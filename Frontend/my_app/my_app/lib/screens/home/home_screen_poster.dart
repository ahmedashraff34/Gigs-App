import 'package:ali_grad/services/task_service.dart';
import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:ali_grad/widgets/greeting_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';
import '../../widgets/my_box.dart';
import '../../widgets/unassigned_task_card.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/task_model.dart';
import '../../widgets/TaskCard.dart';
import '../../utils/location.dart';
import '../task/task_details.dart';
import '../chat_screen.dart';
import '../../utils/cloudinary.dart';

class HomeScreenPoster extends StatefulWidget {
  const HomeScreenPoster({Key? key}) : super(key: key);

  @override
  State<HomeScreenPoster> createState() => _HomeScreenPosterState();
}

class _HomeScreenPosterState extends State<HomeScreenPoster> {
  final TaskService taskService = TaskService();
  final UserService userService = UserService();

  List<TaskResponse> unassignedTasks = [];
  List<TaskResponse> ongoingTasks = [];
  bool _isLoading = true;
  bool _isLoadingOngoing = true;

  // <-- Add this variable

  void deleteTask(int taskId, TaskResponse task) async {
    // Remove all images from Cloudinary before deleting the task
    if (task.imageUrls != null && task.imageUrls!.isNotEmpty) {
      for (final url in task.imageUrls!) {
        final publicId = CloudinaryService.extractPublicId(url);
        await CloudinaryService.deleteImageFromCloudinary(publicId);
      }
    }
    final fullJson = task.toJson();
    final nonNullJson = <String, dynamic>{};
    fullJson.forEach((key, value) {
      if (value != null) nonNullJson[key] = value;
    });
    // Ensure task_type is present for backend compatibility
    if (!nonNullJson.containsKey('task_type')) {
      if (task.category.name == 'EVENT_STAFFING') {
        nonNullJson['task_type'] = 'EVENT';
      } else {
        nonNullJson['task_type'] = 'REGULAR';
      }
    }
    final success = await taskService.deleteTask(taskId, nonNullJson);

    if (success) {
      setState(() {
        unassignedTasks.removeWhere((t) => t.taskId == taskId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUnassignedTasks();
    getOngoingTasks();
  }

  Future<void> getUnassignedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("❌ No userId found");
      return;
    }

    final tasks = await taskService.getUnassignedTasks(userId);
    setState(() {
      unassignedTasks = tasks;
      _isLoading = false;
    });

    // if (unassignedTasks.isNotEmpty) {
    //   print("✅ Found ${unassignedTasks.length} unassigned tasks");
    // } else {
    //   print("❌ No unassigned tasks found");
    // }
  }

  Future<void> getOngoingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      print("❌ No userId found");
      return;
    }
    setState(() => _isLoadingOngoing = true);
    final tasks = await taskService.getOngoingTasks(userId);
    setState(() {
      ongoingTasks = tasks;
      _isLoadingOngoing = false;
    });
  }

  UnassignedTask mapToUnassignedCard(TaskResponse task) {
    return UnassignedTask(
      title: task.title,
      category: task.category.name, // assumes enum with .name
      offers: 1,
      date: DateTime.tryParse(task.additionalRequirements['deadline'] ?? '') ??
          DateTime.now(),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.Cleaning:
        return HugeIcons.strokeRoundedClean;
      case Category.Delivery:
        return HugeIcons.strokeRoundedShippingTruck01;
      case Category.Assembly:
        return HugeIcons.strokeRoundedTools;
      case Category.Handyman:
        return HugeIcons.strokeRoundedLegalHammer;
      case Category.Lifting:
        return HugeIcons.strokeRoundedPackageRemove;
      case Category.Custom:
        return HugeIcons.strokeRoundedIdea01;
      case Category.EVENT_STAFFING:
        return Icons.event;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Home"),
      body: RefreshIndicator(
        backgroundColor: AppTheme.backgroundColor,
        onRefresh: () async {
          getUnassignedTasks();
          getOngoingTasks();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            const GreetingBanner(),
            SizedBox(
              height: AppTheme.paddingMedium,
            ),

            SizedBox(
              height: AppTheme.paddingMedium,
            ),
            // On Going Tasks Header
            Text("On Going Tasks", style: AppTheme.headerTextStyle),
            const SizedBox(height: AppTheme.paddingMedium),

            // PageView for tasks overview
            _isLoadingOngoing
                ? const Center(child: CircularProgressIndicator())
                : (ongoingTasks.isEmpty)
                    ? MyBox(
                        boxPadding: AppTheme.paddingLarge,
                        borderWidth: 3,
                        borderColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        boxChild: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "You're not working on anything currently.",
                                style: AppTheme.textStyle2,
                              ),
                            ),
                            Expanded(
                                child: SvgPicture.asset(
                              'assets/svg/add_task.svg',
                              width: 120,
                              height: 120,
                              semanticsLabel: 'Logo',
                            ))
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ongoingTasks.length,
                          itemBuilder: (context, i) {
                            final task = ongoingTasks[i];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: AppTheme.paddingMedium),
                              child: SizedBox(
                                width: ongoingTasks.length == 1
                                    ? MediaQuery.of(context).size.width -
                                        (AppTheme.paddingMedium * 2)
                                    : MediaQuery.of(context).size.width * 0.80,
                                child: MyBox(
                                  backgroundColor:
                                      i == 0 ? AppTheme.primaryColor : null,
                                  boxPadding: AppTheme.paddingMedium,
                                  boxChild: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Header with category icon and menu
                                      Row(
                                        children: [
                                          Icon(
                                            _getCategoryIcon(task.category),
                                            size: 38,
                                            color: i == 0
                                                ? Colors.white
                                                : AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              task.title,
                                              style:
                                                  AppTheme.textStyle0.copyWith(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: i == 0
                                                    ? Colors.white
                                                    : AppTheme.textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TaskDetailsScreen(
                                                          task: task),
                                                ),
                                              );
                                            },
                                            child: Icon(
                                              FontAwesomeIcons.ellipsisVertical,
                                              size: 18,
                                              color: i == 0
                                                  ? Colors.white
                                                  : AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Description
                                      const SizedBox(
                                          height: AppTheme.paddingSmall),
                                      // Runner info
                                      FutureBuilder<String?>(
                                        future: userService.getUsernameById(
                                            task.runnerId.toString()),
                                        builder: (context, snapshot) {
                                          return Text(
                                            '${snapshot.hasData ? snapshot.data! : 'Loading...'}',
                                            style: AppTheme.textStyle1.copyWith(
                                              color: i == 0
                                                  ? Colors.white
                                                  : AppTheme.textColor1,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      // Message button at bottom
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final currentUserId =
                                                prefs.getString('userId') ?? '';
                                            final currentUsername =
                                                prefs.getString('username') ??
                                                    '';
                                            final otherUserId =
                                                task.runnerId.toString();
                                            final otherUsername =
                                                await userService
                                                        .getUsernameById(
                                                            otherUserId) ??
                                                    'Runner';

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  currentUserId: currentUserId,
                                                  currentUsername:
                                                      currentUsername,
                                                  otherUserId: otherUserId,
                                                  otherUsername: otherUsername,
                                                ),
                                              ),
                                            );
                                          }, // Add message handler
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: i == 0
                                                ? Colors.white
                                                : AppTheme.primaryColor,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            "Message",
                                            style: AppTheme.textStyle2.copyWith(
                                              color: i == 0
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

            const SizedBox(height: AppTheme.paddingLarge),

            // Unassigned Tasks Section
            Text("Unassigned Tasks", style: AppTheme.headerTextStyle),
            const SizedBox(height: AppTheme.paddingMedium),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (unassignedTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text("No tasks found.")),
              )
            else
              Column(
                children: unassignedTasks.map((task) {
                  final taskId = task.taskId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: FutureBuilder<String?>(
                      future: fetchCity(
                        latitude: task.latitude,
                        longitude: task.longitude,
                      ),
                      builder: (context, snapshot) {
                        return TaskCard(
                          task: task,
                          city: snapshot.hasData ? snapshot.data : null,
                          button2OnPress: () {
                            deleteTask(taskId, task);
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/post-task");
        },
        icon: const Icon(Icons.add),
        label: const Text('Post a Task'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
