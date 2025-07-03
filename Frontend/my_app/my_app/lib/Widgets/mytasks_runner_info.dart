import 'package:flutter/material.dart';
import '../models/task_response.dart';
import 'dispute_form.dart';

class MyTasksRunnerInfo extends StatelessWidget {
  final TaskResponse task;
  final VoidCallback? onChat;
  final VoidCallback? onDispute;

  const MyTasksRunnerInfo({
    Key? key,
    required this.task,
    this.onChat,
    this.onDispute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Type: ${task.category.name}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(task.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Status: ${task.status}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Amount: ${task.amount}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (task.additionalRequirements['location'] != null)
              Text('Location: ${task.additionalRequirements['location']}', style: const TextStyle(fontSize: 16)),
            if (task.additionalAttributes['dateTime'] != null)
              Text('Date/Time: ${task.additionalAttributes['dateTime']}', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onChat ?? () {},
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onDispute ?? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisputeForm(
                          task: task,
                          complainantId: task.taskPoster,
                          defendantId: task.runnerId ?? 0,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Raise Dispute'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
