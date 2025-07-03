/// accepted_task_detail_screen.dart
/// -------------------------------
/// Screen for displaying details of a task that has been accepted by a runner, including task info, offer details, and progress.
/// Allows runners to view emergency options and communicate with the task poster.
///
/// Suggestions:
/// - Move business logic (e.g., data fetching, emergency actions) to services or providers.
/// - Split out large widgets (e.g., emergency button, offer details) into separate files in Widgets/.
/// - Use state management for complex state.
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/offer.dart';
import '../services/task_service.dart';
import '../services/token_service.dart';
import '../widgets/emergency_location_button.dart';

class AcceptedTaskDetailScreen extends StatefulWidget {
  final Task task;
  final Offer acceptedOffer;

  const AcceptedTaskDetailScreen({
    Key? key,
    required this.task,
    required this.acceptedOffer,
  }) : super(key: key);

  @override
  State<AcceptedTaskDetailScreen> createState() => _AcceptedTaskDetailScreenState();
}

class _AcceptedTaskDetailScreenState extends State<AcceptedTaskDetailScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Assigned Task'),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                // TODO: Navigate to chat with task poster
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show more options
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Task Info'),
              Tab(text: 'Offer Details'),
              Tab(text: 'Progress'),
            ],
            indicatorColor: Color(0xFF1DBF73),
            labelColor: Color(0xFF1DBF73),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            // Task Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Posted by',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'Task Poster #${widget.task.taskPoster}',
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF1DBF73)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.task.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Task Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DBF73).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.task.type,
                      style: const TextStyle(
                        color: Color(0xFF1DBF73),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lat: ${widget.task.latitude}, Lon: ${widget.task.longitude}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  if (widget.task.startTime != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Start Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.task.startTime!.day}/${widget.task.startTime!.month}/${widget.task.startTime!.year} at ${widget.task.startTime!.hour}:${widget.task.startTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Emergency Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  EmergencyLocationButton(
                    telegramNumber: '+201026617175', // Replace with actual Telegram number (e.g., 'john_doe' or '+1234567890')
                    customMessage: '🚨 EMERGENCY: I need help with task: ${widget.task.title}',
                    showConfirmation: true,
                    onLocationSent: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency location sent!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Offer Details Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accepted Offer Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Offer Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${widget.acceptedOffer.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1DBF73),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your Message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.acceptedOffer.message,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Offer Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: const Text(
                              'ACCEPTED',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Accepted On',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.acceptedOffer.timestamp.day}/${widget.acceptedOffer.timestamp.month}/${widget.acceptedOffer.timestamp.year} at ${widget.acceptedOffer.timestamp.hour}:${widget.acceptedOffer.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Progress',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: const Text(
                              'IN PROGRESS',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Next Steps',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Contact the task poster to confirm details\n'
                            '2. Arrange a meeting time and location\n'
                            '3. Complete the task as agreed\n'
                            '4. Request payment upon completion',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement contact task poster functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact functionality coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.contact_phone),
                            label: const Text('Contact Task Poster'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DBF73),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 