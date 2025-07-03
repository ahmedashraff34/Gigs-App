import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/token_service.dart';

class PostMovingTaskScreen extends StatefulWidget {
  const PostMovingTaskScreen({Key? key}) : super(key: key);

  @override
  State<PostMovingTaskScreen> createState() => _PostMovingTaskScreenState();
}

class _PostMovingTaskScreenState extends State<PostMovingTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  // Standard task fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _deadlineDateTime;
  // Moving-specific fields
  DateTime? _startTime;
  DateTime? _endTime;
  final _numberOfSadController = TextEditingController();
  final _dropoffLocationController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  bool _isLoading = false;
  final _taskService = TaskService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    _numberOfSadController.dispose();
    _dropoffLocationController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadlineDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _deadlineDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _endTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_deadlineDateTime == null || _startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all date and time fields.')),
        );
        return;
      }
      setState(() { _isLoading = true; });
      final userIdStr = await TokenService.getUserId();
      if (userIdStr == null) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        return;
      }
      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID. Please log in again.')),
        );
        return;
      }
      final additionalRequirements = {
        'location': _locationController.text,
        'deadline': _deadlineDateTime!.toIso8601String(),
        'ali': 1,
      };
      final additionalAttributes = {
        'pickupLocation': _pickupLocationController.text,
        'dropoffLocation': _dropoffLocationController.text,
        'number of sad': int.tryParse(_numberOfSadController.text) ?? 0,
        'startTime': _startTime!.toIso8601String(),
        'endTime': _endTime!.toIso8601String(),
      };
      final task = Task(
        taskPoster: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: 'Moving',
        taskType: 'REGULAR',
        longitude: 30.061, // Placeholder
        latitude: 31.248, // Placeholder
        amount: double.parse(_amountController.text),
        additionalRequirements: additionalRequirements,
        additionalAttributes: additionalAttributes,
      );
      final result = await _taskService.postTask(task);
      setState(() { _isLoading = false; });
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Moving task posted successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post task: \\${result['error']}')),
          );
        }
      }
    }
  }

  Widget _buildDateTimePicker(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(
        value == null
            ? label
            : DateFormat.yMd().add_jm().format(value),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[400]!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Moving Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Standard fields
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a budget';
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location Details (e.g., address, zip code)'),
                validator: (value) => value!.isEmpty ? 'Please enter location details' : null,
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker('Select Deadline', _deadlineDateTime, _selectDeadlineDateTime),
              const SizedBox(height: 24),
              // Moving-specific fields
              _buildDateTimePicker('Select Start Time', _startTime, _selectStartTime),
              const SizedBox(height: 16),
              _buildDateTimePicker('Select End Time', _endTime, _selectEndTime),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfSadController,
                decoration: const InputDecoration(labelText: 'Number of sad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter number of sad';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dropoffLocationController,
                decoration: const InputDecoration(labelText: 'Dropoff Location'),
                validator: (value) => value!.isEmpty ? 'Please enter dropoff location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pickupLocationController,
                decoration: const InputDecoration(labelText: 'Pickup Location'),
                validator: (value) => value!.isEmpty ? 'Please enter pickup location' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Moving Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 