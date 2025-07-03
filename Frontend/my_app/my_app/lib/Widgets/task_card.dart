import 'package:flutter/material.dart';
import '../models/task_response.dart';
import '../Screens/task_detail_screen.dart';
import '../services/task_service.dart';

class TaskCard extends StatelessWidget {
  final TaskResponse task;
  final VoidCallback onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posted time
              Text(
                'Posted yesterday', // TODO: Make dynamic if you have the date
                style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.6)),
              ),
              const SizedBox(height: 4),
              // Title
              Text(
                task.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 6),
              // Type & Budget
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.category.name,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money, size: 16, color: theme.colorScheme.primary),
                        Text(
                          (task.amount).toStringAsFixed(0),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('Expert', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Description
              Text(
                task.description,
                style: TextStyle(fontSize: 15, color: theme.colorScheme.primary.withOpacity(0.85)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              const SizedBox(height: 10),
              // Event Staffing Fields
              if (task.category.name == 'EventStaffing' && task.additionalAttributes['fixedPay'] != null)
                Text('Fixed Pay: \$${task.additionalAttributes['fixedPay']}', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              if (task.category.name == 'EventStaffing' && task.additionalAttributes['requiredPeople'] != null)
                Text('Required People: ${task.additionalAttributes['requiredPeople']}', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              if (task.category.name == 'EventStaffing' && task.additionalAttributes['location'] != null)
                Text('Location: ${task.additionalAttributes['location']}', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              if (task.category.name == 'EventStaffing' && task.additionalAttributes['startDate'] != null && task.additionalAttributes['endDate'] != null)
                Text('From: ${task.additionalAttributes['startDate']} To: ${task.additionalAttributes['endDate']}', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              if (task.category.name == 'EventStaffing' && task.additionalAttributes['numberOfDays'] != null)
                Text('Number of Days: ${task.additionalAttributes['numberOfDays']}', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              const SizedBox(height: 10),
              // Tags (example tags, replace with real tags if available)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (task.additionalRequirements['tags'] != null)
                      ...List.generate((task.additionalRequirements['tags'] as List).length, (i) {
                        final tag = task.additionalRequirements['tags'][i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag, style: TextStyle(color: theme.colorScheme.primary)),
                            backgroundColor: theme.colorScheme.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        );
                      })
                    else ...[
                      Chip(
                        label: Text(
                          task.category.name == 'EventStaffing' ? 'Event Staffing' : 'Regular',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Poster info row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.verified, color: theme.colorScheme.primary, size: 18),
                  Text('Payment verified', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.grey.shade400, size: 18),
                      Icon(Icons.star, color: Colors.grey.shade400, size: 18),
                      Icon(Icons.star, color: Colors.grey.shade400, size: 18),
                      Icon(Icons.star, color: Colors.grey.shade400, size: 18),
                      Icon(Icons.star, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                  Icon(Icons.location_on, color: theme.colorScheme.primary, size: 18),
                  Text(
                    (task.additionalRequirements['posterName'] != null)
                      ? task.additionalRequirements['posterName']
                      : 'User #${task.taskPoster}',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Proposals count
              FutureBuilder<int>(
                future: task.taskId != null ? _fetchOffersCount(task.taskId) : Future.value(0),
                builder: (context, snapshot) {
                  final offersCount = snapshot.data ?? 0;
                  final maxProposals = task.additionalRequirements['maxProposals'] != null
                      ? int.tryParse(task.additionalRequirements['maxProposals'].toString()) ?? 50
                      : 50;
                  return Text(
                    'Proposals: $offersCount / $maxProposals',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.7)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _fetchOffersCount(int taskId) async {
    final taskService = TaskService();
    final offers = await taskService.getOffersForTask(taskId);
    return offers.length;
  }
}
