import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';
import 'post_delivery_screen.dart';
import 'post_moving_task.dart';
import 'post_event_staffing_task.dart';

class PostTaskScreen extends StatelessWidget {
  const PostTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                'Choose a Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCategoryButton(context, Icons.delivery_dining, 'Delivery'),
                  _buildCategoryButton(context, Icons.handyman, 'Handyman'),
                  _buildCategoryButton(context, Icons.cleaning_services, 'Cleaning'),
                  _buildCategoryButton(context, Icons.people, 'Event Staffing'),
                  _buildCategoryButton(context, Icons.local_shipping, 'Moving'),
                  _buildCategoryButton(context, Icons.grass, 'Gardening'),
                  _buildCategoryButton(context, Icons.computer, 'Tech'),
                  _buildCategoryButton(context, Icons.shopping_cart, 'Shopping'),
                  _buildCategoryButton(context, Icons.pets, 'Pet Care'),
                  _buildCategoryButton(context, Icons.more_horiz, 'Other'),
                ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == 'Delivery') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostDeliveryScreen(),
            ),
          );
        } else if (label == 'Moving') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostMovingTaskScreen(),
            ),
          );
        } else if (label == 'Event Staffing') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostEventStaffingTaskScreen(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(category: label),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
        ),
      ),
    );
  }
} 