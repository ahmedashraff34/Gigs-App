import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/theme.dart';
import '../services/task_service.dart';
import '../services/sos_service.dart';
import 'my_box.dart';

class CurrentTaskCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String poster;
  final String date;
  final int taskId;
  final int userId;

  const CurrentTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.poster,
    required this.date,
    required this.taskId,
    required this.userId,
  });

  @override
  State<CurrentTaskCard> createState() => _CurrentTaskCardState();
}

class _CurrentTaskCardState extends State<CurrentTaskCard>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isCompleting = false;
  bool _isSendingSos = false;
  final TaskService _taskService = TaskService();
  final SosService _sosService = SosService();

  @override
  Widget build(BuildContext context) {
    return MyBox(
      boxPadding: AppTheme.paddingLarge,
      borderColor: AppTheme.warningColor,
      borderWidth: 1.5,
      backgroundColor: const Color(0xFFfff9eb),
      boxChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // — HEADER ROW —
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.solidCircle,
                color: AppTheme.warningColor,
                size: 15,
              ),
              const SizedBox(width: 10),
              const Text(
                "Task in Progress",
                style: TextStyle(
                    color: Color(0xFF7d4a29),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Spacer(),
              // Animated chevron
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    FontAwesomeIcons.chevronDown,
                    color: AppTheme.textColor1,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.paddingMedium),

          // — CONTENT ROW —
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Title & Posted by always fixed,
              // then AnimatedSize for the extra lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTheme.textStyle1),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text("Posted by ${widget.poster}",
                        style: AppTheme.textStyle2),

                    // only this block animates its size
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: _isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  top: AppTheme.paddingSmall),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.subtitle,
                                      style: AppTheme.textStyle2),
                                  const SizedBox(height: AppTheme.paddingSmall),
                                  Text("Date: ${widget.date}",
                                      style: AppTheme.textStyle2),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right color bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: 20,
                height: _isExpanded ? 120 : 60,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.borderRadiusPill,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.paddingMedium),

          // — ACTION BUTTONS ROW —
          Row(
            children: [
              // — SOS BUTTON —
              Expanded(
                child: FloatingActionButton.small(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius,
                  ),
                  elevation: 0,
                  onPressed: _isSendingSos
                      ? null
                      : () => _showSosDialog(),
                  backgroundColor: AppTheme.urgentColor,
                  child: _isSendingSos
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "SOS",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: AppTheme.paddingMedium),

              // — COMPLETE BUTTON —
              Expanded(
                child: FloatingActionButton.small(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius,
                  ),
                  elevation: 0,
                  onPressed: _isCompleting
                      ? null
                      : () async {
                          setState(() => _isCompleting = true);

                          try {
                            final success = await _taskService.updateTaskStatus(
                              taskId: widget.taskId,
                              newStatus: 'DONE',
                              userId: widget.userId,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task completed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // You might want to navigate back or refresh the screen
                              Navigator.pushNamed(context, "/runner-home");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to complete task. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() => _isCompleting = false);
                          }
                        },
                  backgroundColor: AppTheme.warningColor,
                  child: _isCompleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Color(0xFF7d4a29),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Complete Task",
                          style: TextStyle(
                              color: Color(0xFF7d4a29),
                              fontWeight: FontWeight.bold,
                              fontSize: AppTheme.paddingMedium),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show SOS dialog with comment input
  void _showSosDialog() {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.borderRadius,
          ),
          title: Row(
            children: [
              Icon(
                Icons.emergency,
                color: AppTheme.urgentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Send SOS Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.urgentColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will send an emergency alert with your current location.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor1,
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              const Text(
                'Add a comment (optional):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the emergency situation...',
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.borderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppTheme.borderRadius,
                    borderSide: BorderSide(color: AppTheme.urgentColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textColor1),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendSosAlert(commentController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.urgentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadius,
                ),
              ),
              child: const Text(
                'Send SOS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Send SOS alert with comment
  Future<void> _sendSosAlert(String comment) async {
    setState(() => _isSendingSos = true);

    try {
      final success = await _sosService.sendSosAlert(
        taskId: widget.taskId,
        comment: comment.isNotEmpty ? comment : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS alert sent successfully! Help is on the way.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send SOS alert. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSendingSos = false);
    }
  }
}
