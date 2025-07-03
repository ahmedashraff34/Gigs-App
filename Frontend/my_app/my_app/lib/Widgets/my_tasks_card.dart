import 'package:flutter/material.dart';

class MyTasksCard extends StatelessWidget {
  final String taskTitle;
  final String taskType;
  final String status;
  final DateTime deadline;
  final double offerAmount;
  final String taskPoster;
  final String taskPosterImage;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onChat;

  const MyTasksCard({
    Key? key,
    required this.taskTitle,
    required this.taskType,
    required this.status,
    required this.deadline,
    required this.offerAmount,
    required this.taskPoster,
    this.taskPosterImage = 'https://via.placeholder.com/50',
    required this.onTap,
    this.onCancel,
    this.onEdit,
    this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Theme.of(context).colorScheme.secondary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      taskTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusChip(status, context),
                      if (onEdit != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 20),
                          tooltip: 'Edit Offer',
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                      if (onCancel != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          tooltip: 'Cancel Offer',
                          onPressed: onCancel,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      taskType,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Theme.of(context).colorScheme.primary),
                        Text(
                          offerAmount.toStringAsFixed(2),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(taskPosterImage),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Posted by $taskPoster',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (onChat != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat with User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDeadline(deadline),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (status.toLowerCase() == 'in progress')
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
                            _getTimeRemaining(deadline),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, BuildContext context) {
    Color chipColor;
    Color textColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'in progress':
        chipColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        statusIcon = Icons.play_circle_outline;
        break;
      case 'completed':
        chipColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending':
        chipColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        statusIcon = Icons.pending_outlined;
        break;
      default:
        chipColor = Theme.of(context).colorScheme.secondary;
        textColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    return 'Due: ${deadline.day}/${deadline.month}/${deadline.year}';
  }

  String _getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

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
}
