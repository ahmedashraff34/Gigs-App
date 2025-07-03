/// event_task_card.dart
/// -------------------
/// UI widget for displaying an EventTask in a card format.
/// Used in poster and runner home screens to show event staffing tasks.
///
/// Usage:
///   EventTaskCard(eventTask: eventTask)
///
/// Expects an EventTask model as input.
import 'package:flutter/material.dart';
import '../models/event_task.dart';

/// Card widget for displaying event staffing task details.
class EventTaskCard extends StatelessWidget {
  final EventTask eventTask;
  const EventTaskCard({Key? key, required this.eventTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Main card UI for event task
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted date
            Text(
              'Posted: ${eventTask.createdDate?.toString() ?? ''}',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              eventTask.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 6),
            // Type, Pay, People
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
                      eventTask.type.isNotEmpty ? eventTask.type : '',
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
                        eventTask.fixedPay.toStringAsFixed(0),
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
                  child: Text('People: ${eventTask.requiredPeople}', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              eventTask.description.isNotEmpty ? eventTask.description : '',
              style: TextStyle(fontSize: 15, color: theme.colorScheme.primary.withOpacity(0.85)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            const SizedBox(height: 10),
            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(eventTask.location.isNotEmpty ? eventTask.location : '', style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            // Dates
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('From: ${eventTask.startDate} To: ${eventTask.endDate}', style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 