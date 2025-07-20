import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api.dart';

class DisputeService {
  // Use 10.0.2.2 for Android emulator to access host machine
  final String baseUrl = '$apiBaseUrl/api/disputes';

  Future<bool> sendDispute({
    required int taskId,
    required int complainantId,
    required int defendantId,
    required String reason,
    required List<String> evidenceUris,
  }) async {
    final body = jsonEncode({
      'taskId': taskId,
      'complainantId': complainantId,
      'defendantId': defendantId,
      'reason': reason,
      'evidenceUris': evidenceUris,
    });
    try {
      print('Sending dispute: ' + body);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Dispute response status: \\${response.statusCode}');
      print('Dispute response body: \\${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending dispute: $e');
      return false;
    }
  }
}
