import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/services/task_service.dart';
import 'package:ali_grad/utils/location.dart';
import 'package:ali_grad/widgets/TaskCard.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/task_model.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  TaskService taskService = TaskService();
  Map<String, bool> showSections = {
    'OPEN': true,
    'IN_PROGRESS': true,
    'DONE': true,
    'COMPLETED': false,
    'CANCELLED': true,
  };

  Future<String> getCityName(lat, lon) async {
    var res = await fetchCity(
      latitude: lat,
      longitude: lon,
    );
    return res.toString();
  }

  List<TaskResponse> allTasks = [];

  List<TaskResponse> getTasksByStatus(String status) =>
      allTasks.where((task) => task.status == status).toList();

  Future<void> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await taskService.getTasksByTaskPosterId(userId!);

    setState(() {
      allTasks = response!;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "My Tasks",
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getAllTasks();
        },
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingHuge),
            child: Column(
              children: [
                if (allTasks.isEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/no_tasks.svg',
                        width: 150,
                        height: 150,
                        semanticsLabel: 'Logo',
                      ),
                      Text(
                        "No tasks found",
                        style: AppTheme.textStyle2
                            .copyWith(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                if (allTasks.isNotEmpty) ...[
                  Text(
                    "All Tasks",
                    style: AppTheme.textStyle0,
                  ),
                  SizedBox(
                    height: AppTheme.paddingMedium,
                  ),
                  // Status Sections
                  for (String status in [
                    'OPEN',
                    'IN_PROGRESS',
                    'DONE',
                    'COMPLETED',
                    'CANCELLED'
                  ]) ...[
                    if (getTasksByStatus(status).isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showSections[status] =
                                !(showSections[status] ?? false);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    _getStatusColor(status).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (showSections[status] ?? false)
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_getStatusLabel(status)} (${getTasksByStatus(status).length})',
                                style: AppTheme.textStyle1.copyWith(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showSections[status] ?? false) ...[
                        const SizedBox(height: 16),
                        for (var i = 0;
                            i < getTasksByStatus(status).length;
                            i++) ...[
                          FutureBuilder<String?>(
                            future: fetchCity(
                              latitude: getTasksByStatus(status)[i].latitude,
                              longitude: getTasksByStatus(status)[i].longitude,
                            ),
                            builder: (context, snapshot) {
                              return TaskCard(
                                task: getTasksByStatus(status)[i],
                                city: snapshot.hasData ? snapshot.data : null,
                                showActions: false,
                              );
                            },
                          ),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                        ],
                      ],
                      const SizedBox(height: 8),
                    ],
                  ],
                ]
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return AppTheme.successColor;
      case 'IN_PROGRESS':
        return AppTheme.warningColor;
      case 'DONE':
        return AppTheme.urgentColor;
      case 'COMPLETED':
        return AppTheme.primaryColor;
      case 'CANCELLED':
        return AppTheme.urgentColor;
      default:
        return AppTheme.textColor1;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Open Tasks';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'DONE':
        return 'Done Tasks';
      case 'COMPLETED':
        return 'Completed Tasks';
      case 'CANCELLED':
        return 'Cancelled Tasks';
      default:
        return status;
    }
  }
}
