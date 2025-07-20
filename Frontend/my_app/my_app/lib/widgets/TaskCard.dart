import 'package:ali_grad/models/task_model.dart';
import 'package:ali_grad/utils/date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme.dart';
import '../models/event_application_model.dart';
import '../screens/chat_screen.dart';
import '../screens/task/task_details.dart';
import '../screens/task/post_task_screen.dart';
import 'my_box.dart';
import '../services/event_application_service.dart';
import '../services/user_service.dart';
import '../services/task_service.dart';
import '../models/user_model.dart';
import '../screens/chat/chat_screen.dart';

class TaskCard extends StatefulWidget {
  final TaskResponse task;
  final double? distance;
  final String? city;
  final VoidCallback? button2OnPress;
  final bool showActions;
  final bool isButtonDisabled;
  const TaskCard({
    super.key,
    required this.task,
    this.distance,
    this.city,
    this.button2OnPress,
    this.showActions = true,
    this.isButtonDisabled = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String? selectedRole;
  Future<void> fetchSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSelectedRole();
  }

  @override
  Widget build(BuildContext context) {
    return MyBox(
      boxPadding: AppTheme.paddingLarge,
      boxChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: AppTheme.textStyle1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppTheme.paddingSmall),
              if (selectedRole == "runner")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.task.category.name == "EVENT_STAFFING"
                          ? widget.task.fixedPay.toString()
                          : widget.task.amount.toString(),
                      style: AppTheme.textStyle0,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("EGP")
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: AppTheme.borderRadius,
                  ),
                  child: Text(
                    widget.task.category.name == "EVENT_STAFFING"
                        ? "Event"
                        : widget.task.category.name,
                    style: AppTheme.textStyle1.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Icon(FontAwesomeIcons.clock,
                  color: AppTheme.textColor1, size: 18),
              SizedBox(width: AppTheme.paddingTiny),
              Text(
                timeAgoFromString(widget.task.createdDate),
                style:
                    AppTheme.textStyle2.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot,
                  color: AppTheme.textColor1, size: 17),
              SizedBox(width: AppTheme.paddingTiny),
              Text(
                widget.city ??
                    (widget.distance != null
                        ? "${widget.distance!.toStringAsFixed(1)} km"
                        : "Unknown"),
                style: AppTheme.textStyle2,
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showActions) ...[
                Expanded(
                  child: FloatingActionButton.small(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    child: Text(
                      selectedRole == "runner" ? "View details" : "Edit",
                      style: AppTheme.textStyle2.copyWith(
                        fontWeight: FontWeight.w100,
                        color: AppTheme.textColor,
                      ),
                    ),
                    onPressed: () {
                      if (selectedRole == "runner") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskDetailsScreen(task: widget.task),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostTaskScreen(taskToEdit: widget.task),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: AppTheme.paddingMedium),
                if (selectedRole == "runner")
                  Expanded(
                    child: FloatingActionButton.small(
                      heroTag: widget.task.taskId,
                      elevation: 0,
                      backgroundColor: widget.isButtonDisabled
                          ? AppTheme.disabledColor
                          : AppTheme.primaryColor,
                      child: Text(
                        widget.task.category.name == "EVENT_STAFFING"
                            ? "Apply"
                            : "Raise Offer",
                        style: AppTheme.textStyle1.copyWith(
                          fontWeight: FontWeight.w500,
                          color: widget.isButtonDisabled
                              ? AppTheme.textColor1
                              : Colors.white,
                        ),
                      ),
                      onPressed: widget.isButtonDisabled
                          ? null
                          : widget.button2OnPress,
                    ),
                  )
                else
                  Expanded(
                    child: FloatingActionButton.small(
                      elevation: 0,
                      backgroundColor: AppTheme.urgentColor.withOpacity(0.15),
                      child: Text(
                        "Delete",
                        style: AppTheme.textStyle1.copyWith(
                          color: AppTheme.urgentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: widget.button2OnPress,
                    ),
                  ),
              ] else ...[
                if (selectedRole == "poster" &&
                    widget.task.category.name == "EVENT_STAFFING") ...[
                  Expanded(
                    child: FloatingActionButton.small(
                      elevation: 0,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        "View Runners",
                        style: AppTheme.textStyle2.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RunnersListScreen(task: widget.task),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: AppTheme.paddingMedium,
                  )
                ],
                Expanded(
                  child: FloatingActionButton.small(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    child: Text(
                      "View details",
                      style: AppTheme.textStyle2.copyWith(
                        fontWeight: FontWeight.w100,
                        color: AppTheme.textColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailsScreen(task: widget.task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// --- Runners List Screen ---
class RunnersListScreen extends StatefulWidget {
  final TaskResponse task;
  const RunnersListScreen({Key? key, required this.task}) : super(key: key);
  @override
  State<RunnersListScreen> createState() => _RunnersListScreenState();
}

class _RunnersListScreenState extends State<RunnersListScreen> {
  List<EventAppResponse> runners = [];
  Map<int, UserModel> runnerUsers = {};
  bool isLoading = true;
  final EventApplicationService eventService = EventApplicationService();
  final UserService userService = UserService();
  final TaskService taskService = TaskService();

  List<int> getRunnerIds() {
    return widget.task.runnerIds ?? [];
  }

  @override
  void initState() {
    super.initState();
    fetchRunners();
  }

  Future<void> fetchRunners() async {
    setState(() => isLoading = true);
    final ids = getRunnerIds();
    Map<int, UserModel> users = {};
    for (final id in ids) {
      final user = await userService.getUserById(id.toString());
      if (user != null) users[id] = user;
    }
    setState(() {
      runners = ids
          .map((id) => EventAppResponse(
                applicationId: 0,
                taskId: widget.task.taskId,
                applicantId: id,
                comment: '',
                resumeLink: '',
                status: 'ACCEPTED',
              ))
          .toList();
      runnerUsers = users;
      isLoading = false;
    });
  }

  Future<void> removeRunner(int runnerId) async {
    final success = await taskService.removeRunnerFromEventTask(
      taskId: widget.task.taskId,
      runnerId: runnerId,
      taskPosterId: widget.task.taskPoster,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Runner removed successfully.')),
      );
      fetchRunners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove runner.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Runners for Event')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : runners.isEmpty
              ? const Center(child: Text('No runners assigned.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: runners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final runner = runners[idx];
                    final user = runnerUsers[runner.applicantId];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            user?.profileUrl != null &&
                                    user!.profileUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        NetworkImage(user.profileUrl!),
                                    backgroundColor: Colors.grey[200],
                                  )
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    child: Text(
                                      user != null && user.firstName.isNotEmpty
                                          ? user.firstName[0]
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user != null
                                        ? '${user.firstName} ${user.lastName}'
                                        : 'Unknown',
                                    style: AppTheme.textStyle1
                                        .copyWith(fontSize: 18),
                                  ),
                                  if (user != null)
                                    Text(
                                      user.username,
                                      style: AppTheme.textStyle2,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat, color: Colors.blue),
                              onPressed: user == null
                                  ? null
                                  : () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final currentUserId =
                                          prefs.getString('userId') ?? '';
                                      final currentUsername =
                                          prefs.getString('username') ?? 'Me';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            currentUserId: currentUserId,
                                            currentUsername: currentUsername,
                                            otherUserId: user.id,
                                            otherUsername: user.username,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => removeRunner(runner.applicantId),
                              tooltip: 'Remove from task',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
