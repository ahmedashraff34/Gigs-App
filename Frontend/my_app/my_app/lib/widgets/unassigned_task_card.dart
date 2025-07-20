import 'package:ali_grad/widgets/my_box.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Model class representing an unassigned task.
class UnassignedTask {
  final String title;
  final String category;
  final int offers;
  final DateTime date;

  UnassignedTask({
    required this.title,
    required this.category,
    required this.offers,
    required this.date,
  });
}

/// A clean, spaced card for unassigned tasks with category, title, offers, and time.
class UnassignedTaskCard extends StatelessWidget {
  final UnassignedTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnassignedTaskCard({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return MyBox(
      boxPadding: AppTheme.paddingMedium,
      boxChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
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
                  task.category,
                  style: AppTheme.textStyle1.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: AppTheme.textColor,
              ),
              const SizedBox(width: 4),
              Text(_formatRelative(task.date),
                  style:
                      AppTheme.textStyle2.copyWith(color: AppTheme.textColor)),
              const SizedBox(width: 16),
              Icon(FontAwesomeIcons.handshake,
                  size: 14, color: AppTheme.successColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${task.offers} offer${task.offers == 1 ? '' : 's'} received',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FloatingActionButton.small(
                  elevation: 0,
                  backgroundColor: AppTheme.dividerColor,
                  child: Text(
                    "Edit",
                    style: AppTheme.textStyle2.copyWith(
                      fontWeight: FontWeight.w100,
                      color: AppTheme.textColor,
                    ),
                  ),
                  onPressed: onEdit,
                ),
              ),
              SizedBox(width: AppTheme.paddingMedium),
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
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
