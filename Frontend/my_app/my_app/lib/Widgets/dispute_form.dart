import 'package:flutter/material.dart';
import '../models/task_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DisputeForm extends StatefulWidget {
  final TaskResponse task;
  final int complainantId;
  final int defendantId;

  const DisputeForm({
    Key? key,
    required this.task,
    required this.complainantId,
    required this.defendantId,
  }) : super(key: key);

  @override
  State<DisputeForm> createState() => _DisputeFormState();
}

class _DisputeFormState extends State<DisputeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  List<String> evidenceUris = [];
  bool isLoading = false;

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final url = Uri.parse('http://localhost:8084/api/disputes');
    final body = jsonEncode({
      'taskId': widget.task.taskId,
      'complainantId': widget.complainantId,
      'defendantId': widget.defendantId,
      'reason': _reasonController.text,
      'evidenceUris': evidenceUris,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dispute submitted successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit dispute: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addEvidenceUri() {
    final uri = _evidenceController.text.trim();
    if (uri.isNotEmpty) {
      setState(() {
        evidenceUris.add(uri);
        _evidenceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Dispute')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task: ${widget.task.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Dispute',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a reason' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Evidence URLs (optional):'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _evidenceController,
                      decoration: const InputDecoration(
                        hintText: 'http://example.com/evidence.jpg',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addEvidenceUri,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: evidenceUris.map((uri) => Chip(
                  label: Text(uri),
                  onDeleted: () {
                    setState(() {
                      evidenceUris.remove(uri);
                    });
                  },
                )).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitDispute,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Dispute'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 