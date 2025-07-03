/// task_detail_screen.dart
/// ----------------------
/// Screen for displaying the details of a single task, including offers, requirements, and Q&A.
/// Allows runners to make offers and view task information in detail.
///
/// Suggestions:
/// - Move business logic (e.g., offer posting, data fetching) to services or providers.
/// - Split out large widgets (e.g., offer dialog, requirements section) into separate files in Widgets/.
/// - Use state management for complex state.
import 'package:flutter/material.dart';
import '../Widgets/offers_card.dart';
import '../models/task_response.dart';
import '../widgets/questions_card.dart';

import '../services/task_service.dart';
import '../services/token_service.dart';
import '../models/offer.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskResponse task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();

  Future<List<Offer>> get _offersFuture => _taskService.getOffersForTask(widget.task.taskId);

  Future<void> _refreshOffers() async {
    setState(() {}); // Triggers rebuild and refetches offers
  }

  Future<void> _showMakeOfferDialog() async {
    final _amountController = TextEditingController();
    final _messageController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;
    String? successMessage;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Make an Offer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Offer Amount',
                      prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _messageController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      prefixIcon: Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(successMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final amount = double.tryParse(_amountController.text);
                                  final message = _messageController.text.trim();
                                  if (amount == null || amount <= 0) {
                                    setState(() => errorMessage = 'Enter a valid amount.');
                                    return;
                                  }
                                  if (message.isEmpty) {
                                    setState(() => errorMessage = 'Enter a message.');
                                    return;
                                  }
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                    successMessage = null;
                                  });
                                  final runnerIdStr = await TokenService.getUserId();
                                  if (runnerIdStr == null) {
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = 'User not authenticated.';
                                    });
                                    return;
                                  }
                                  final runnerId = int.tryParse(runnerIdStr);
                                  if (runnerId == null) {
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = 'Invalid user ID.';
                                    });
                                    return;
                                  }
                                  final result = await _taskService.postOffer(
                                    taskId: widget.task.taskId,
                                    runnerId: runnerId,
                                    amount: amount,
                                    message: message,
                                  );
                                  if (result['success']) {
                                    setState(() {
                                      isLoading = false;
                                      successMessage = 'Offer sent successfully!';
                                    });
                                    await Future.delayed(const Duration(seconds: 1));
                                    if (context.mounted) Navigator.of(context).pop();
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = result['error'] ?? 'Failed to send offer.';
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Send Offer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
          title: const Text('Task'),
          actions: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // Handle share/send action
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // Handle add action
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Handle more options
              },
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Questions'),
              Tab(text: 'Offers'),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            // Info Tab Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Budget, Duration, Level, Location
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 6),
                              Text('Budget', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 2),
                              Text(' 24 ${(widget.task.amount ?? 0).toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 6),
                              Text('Location', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 2),
                              Text(
                                widget.task.additionalRequirements?['location'] ?? 'Not specified',
                                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 6),
                              Text('Duration', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 2),
                              Text(
                                widget.task.additionalAttributes['duration'] ?? 'N/A',
                                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 6),
                              Text('Type', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 2),
                              Text(
                                widget.task.category.name,
                                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Requirements (dynamic)
                  Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.task.description, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.primary)),
                          if (widget.task.additionalRequirements != null && widget.task.additionalRequirements!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...widget.task.additionalRequirements!.entries.map((entry) {
                              if (entry.key == 'location') return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('- ${entry.value}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Safety Rules (static)
                  Text('Safety Rules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('• Never share sensitive information or passwords.', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text('• Meet in safe, public places if required.', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text('• Report any suspicious activity to support.', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Questions Tab Content
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                QuestionsCard(
                  profileImage: 'https://via.placeholder.com/50',
                  userName: 'Sarah Johnson',
                  rating: 4.8,
                  question: 'What is the expected duration of this task?',
                  answer: 'The task should take approximately 2-3 hours to complete.',
                ),
                QuestionsCard(
                  profileImage: 'https://via.placeholder.com/50',
                  userName: 'Mike Thompson',
                  rating: 4.5,
                  question: 'Are there any specific tools required?',
                  answer: 'Yes, you will need basic gardening tools. We can provide some if needed.',
                ),
                QuestionsCard(
                  profileImage: 'https://via.placeholder.com/50',
                  userName: 'Emily Davis',
                  rating: 4.9,
                  question: 'Is there parking available nearby?',
                  answer: 'Yes, there is street parking available and a parking lot within walking distance.',
                ),
              ],
            ),
            // Offers Tab Content
            RefreshIndicator(
              onRefresh: _refreshOffers,
              child: FutureBuilder<List<Offer>>(
                future: _offersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\n${snapshot.error}'));
                  }
                  final offers = snapshot.data ?? [];
                  if (offers.isEmpty) {
                    return const Center(child: Text('No offers yet for this task.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return OffersCard(
                        profileImage: 'https://via.placeholder.com/50',
                        runnerName: 'Runner #${offer.runnerId}',
                        amount: offer.amount,
                        message: offer.message,
                        timestamp: offer.timestamp,
                        rating: 4.5, // Placeholder
                        offerId: offer.id,
                        taskId: widget.task.taskId.toString(),
                        taskPosterId: widget.task.taskPoster,
                        status: offer.status,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _showMakeOfferDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50), // full width
            ),
            child: const Text('Make an Offer', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
} 