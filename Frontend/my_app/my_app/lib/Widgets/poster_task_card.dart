/// poster_task_card.dart
/// --------------------
/// Card widget for displaying a poster's own task with edit and delete actions.
///
/// Usage:
///   PosterTaskCard(
///     task: task,
///     offerCount: 3,
///     onEdit: () { ... },
///     onDelete: () { ... },
///   )
///
/// Shows category, title, offer count, description, and edit/delete buttons.
import 'package:flutter/material.dart';
import '../models/task_response.dart';

class PosterTaskCard extends StatelessWidget {
  final TaskResponse task;
  final int offerCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PosterTaskCard({
    Key? key,
    required this.task,
    required this.offerCount,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.category.name,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF11366A)),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              task.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '$offerCount offers received',
              style: const TextStyle(fontSize: 13, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.primary.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
