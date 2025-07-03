import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_response.dart';
import '../services/task_service.dart';
import '../services/token_service.dart';
import 'poster_home_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final TaskService _taskService = TaskService();
  Future<List<Task>>? _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final userId = await TokenService.getUserId();
    if (userId != null) {
      setState(() {
        _tasksFuture = _taskService.getTasksByPoster(userId);
      });
    }
  }

  Future<void> _cancelTask(Task task) async {
    final userId = await TokenService.getUserId();
    if (task.taskId == null || userId == null) return;

    final result =
        await _taskService.updateTaskStatus(int.parse(task.taskId!), 'CANCELLED', userId);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task cancelled successfully!')),
        );
        _loadTasks(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel task: ${result['error']}')),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final userIdStr = await TokenService.getUserId();
    if (task.taskId == null || userIdStr == null) return;
    final userId = int.tryParse(userIdStr);
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final taskResponse = TaskResponse.fromJson(task.toJson());
    final result = await _taskService.deleteTask(taskResponse, userId);
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully!')),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: ${result['error']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Tasks'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have not posted any tasks yet.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return MyTaskCard(
                task: tasks[index],
                onCancel: () => _cancelTask(tasks[index]),
                onDelete: () => _deleteTask(tasks[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class MyTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const MyTaskCard({super.key, required this.task, required this.onCancel, required this.onDelete});

  @override
  State<MyTaskCard> createState() => _MyTaskCardState();
}

class _MyTaskCardState extends State<MyTaskCard> {
  late String _selectedStatus;
  final List<String> _statusOptions = ['OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status ?? 'OPEN';
  }

  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus == null || newStatus == _selectedStatus) return;
    setState(() { _isUpdating = true; });
    final userIdStr = await TokenService.getUserId();
    if (widget.task.taskId == null || userIdStr == null) return;
    final userId = userIdStr;
    final result = await TaskService().updateTaskStatus(
      int.parse(widget.task.taskId!),
      newStatus,
      userId,
    );
    setState(() { _isUpdating = false; });
    if (result['success']) {
      setState(() { _selectedStatus = newStatus; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated to $newStatus.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${result['error']}')),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    IconData statusIcon;
    switch (status) {
      case 'IN_PROGRESS':
        chipColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'COMPLETED':
        chipColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'OPEN':
        chipColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case 'CANCELLED':
        chipColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        statusIcon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Open';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDeadline(dynamic deadline) {
    if (deadline == null) return 'No deadline';
    if (deadline is String) {
      try {
        final dt = DateTime.parse(deadline);
        return 'Due: ${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        return 'Due: $deadline';
      }
    }
    if (deadline is DateTime) {
      return 'Due: ${deadline.day}/${deadline.month}/${deadline.year}';
    }
    return 'Due: $deadline';
  }

  String _getTimeRemaining(dynamic deadline) {
    if (deadline == null) return '';
    DateTime? dt;
    if (deadline is String) {
      try {
        dt = DateTime.parse(deadline);
      } catch (_) {}
    } else if (deadline is DateTime) {
      dt = deadline;
    }
    if (dt == null) return '';
    final now = DateTime.now();
    final difference = dt.difference(now);
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Due now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(_selectedStatus),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      );
                    }).toList(),
                    onChanged: _isUpdating ? null : _updateStatus,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.type.isNotEmpty ? task.type : 'Other',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DBF73).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ' ${(task.amount ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF1DBF73),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/images/placeholder_profile.jpg'),
                ),
                const SizedBox(width: 8),
                Text(
                  'Posted by You',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.location_on, color: Colors.red.shade300, size: 18),
                Text(
                  task.additionalRequirements?['location'] ?? 'N/A',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDeadline(task.additionalAttributes != null && task.additionalAttributes!['dateTime'] != null ? task.additionalAttributes!['dateTime'] : task.startTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (_selectedStatus == 'IN_PROGRESS')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeRemaining(task.additionalAttributes != null && task.additionalAttributes!['dateTime'] != null ? task.additionalAttributes!['dateTime'] : task.startTime),
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_offer, color: Colors.blue),
                  label: const Text('View Offers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    print('[DEBUG] View Offers clicked for taskId: \'${widget.task.taskId}\'');
                    if (widget.task.taskId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OffersListScreen(taskId: widget.task.taskId!),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Task',
                ),
                TextButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 