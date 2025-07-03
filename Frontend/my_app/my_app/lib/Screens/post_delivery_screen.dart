import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/token_service.dart';

class PostDeliveryScreen extends StatefulWidget {
  const PostDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<PostDeliveryScreen> createState() => _PostDeliveryScreenState();
}

class _PostDeliveryScreenState extends State<PostDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  // Standard task fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDateTime;
  // Delivery-specific fields
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _numItemsController = TextEditingController();
  final _itemTypeController = TextEditingController();
  bool _isFragile = false;
  bool _isLoading = false;
  final _taskService = TaskService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _numItemsController.dispose();
    _itemTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
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
      _selectedDateTime = DateTime(
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
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time.')),
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
      // Compose additionalRequirements and additionalAttributes
      final additionalRequirements = {
        'location': _locationController.text,
        'deadline': _selectedDateTime!.toIso8601String(),
      };
      final additionalAttributes = {
        'pickupLocation': _pickupController.text,
        'dropoffLocation': _dropoffController.text,
        'numberOfItems': int.tryParse(_numItemsController.text) ?? 0,
        'itemType': _itemTypeController.text,
        'fragile': _isFragile,
      };
      final task = Task(
        taskPoster: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: 'Delivery',
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
            const SnackBar(content: Text('Delivery task posted successfully!')),
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

  Widget _buildDateTimePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(
        _selectedDateTime == null
            ? 'Select Date & Time'
            : DateFormat.yMd().add_jm().format(_selectedDateTime!),
      ),
      onTap: _selectDateTime,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[400]!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Delivery Task')),
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
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              // Delivery-specific fields
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(labelText: 'Pick Up Location'),
                validator: (value) => value!.isEmpty ? 'Please enter pick up location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dropoffController,
                decoration: const InputDecoration(labelText: 'Drop Off Location'),
                validator: (value) => value!.isEmpty ? 'Please enter drop off location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numItemsController,
                decoration: const InputDecoration(labelText: 'Number of Items'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter number of items';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemTypeController,
                decoration: const InputDecoration(labelText: 'Item Type'),
                validator: (value) => value!.isEmpty ? 'Please enter item type' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isFragile,
                    onChanged: (val) {
                      setState(() { _isFragile = val ?? false; });
                    },
                  ),
                  const Text('Fragile'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Delivery Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
