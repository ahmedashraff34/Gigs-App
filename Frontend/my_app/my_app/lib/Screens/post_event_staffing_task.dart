import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/event_task.dart';
import '../services/task_service.dart';
import '../services/token_service.dart';

class PostEventStaffingTaskScreen extends StatefulWidget {
  const PostEventStaffingTaskScreen({Key? key}) : super(key: key);

  @override
  State<PostEventStaffingTaskScreen> createState() => _PostEventStaffingTaskScreenState();
}

class _PostEventStaffingTaskScreenState extends State<PostEventStaffingTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _longitudeController = TextEditingController(text: '31.2357');
  final _latitudeController = TextEditingController(text: '30.0444');
  final _dressCodeController = TextEditingController();
  final _languageController = TextEditingController();
  final _fixedPayController = TextEditingController();
  final _requiredPeopleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final _numberOfDaysController = TextEditingController();
  bool _isLoading = false;
  final _taskService = TaskService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _dressCodeController.dispose();
    _languageController.dispose();
    _fixedPayController.dispose();
    _requiredPeopleController.dispose();
    _numberOfDaysController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    setState(() {
      _startDate = date;
    });
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    setState(() {
      _endDate = date;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates.')),
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
        'dressCode': _dressCodeController.text,
        'language': _languageController.text,
      };
      final eventTask = EventTask(
        taskPoster: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: 'EVENT_STAFFING',
        taskType: 'EVENT',
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        additionalRequirements: additionalRequirements,
        location: _locationController.text,
        fixedPay: double.tryParse(_fixedPayController.text) ?? 0.0,
        requiredPeople: int.tryParse(_requiredPeopleController.text) ?? 1,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        numberOfDays: int.tryParse(_numberOfDaysController.text) ?? 1,
      );
      final result = await _taskService.postEventTask(eventTask);
      setState(() { _isLoading = false; });
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event staffing task posted successfully!')),
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

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(
        value == null
            ? label
            : DateFormat.yMd().format(value),
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
      appBar: AppBar(title: const Text('Post Event Staffing Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter longitude' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter latitude' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dressCodeController,
                decoration: const InputDecoration(labelText: 'Dress Code'),
                validator: (value) => value!.isEmpty ? 'Please enter dress code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Language'),
                validator: (value) => value!.isEmpty ? 'Please enter language' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fixedPayController,
                decoration: const InputDecoration(labelText: 'Fixed Pay'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter fixed pay' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requiredPeopleController,
                decoration: const InputDecoration(labelText: 'Required People'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter required people' : null,
              ),
              const SizedBox(height: 16),
              _buildDatePicker('Select Start Date', _startDate, _selectStartDate),
              const SizedBox(height: 16),
              _buildDatePicker('Select End Date', _endDate, _selectEndDate),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfDaysController,
                decoration: const InputDecoration(labelText: 'Number of Days'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter number of days' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Event Staffing Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 