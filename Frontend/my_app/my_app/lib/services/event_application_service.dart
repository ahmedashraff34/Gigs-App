import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_application_model.dart';
import '../models/task_model.dart';
import '../services/user_service.dart';
import '../utils/api.dart';
// import '../models/event_response.dart'; // Uncomment if you have this model

class EventApplicationService {
  final String baseUrl = '$apiBaseUrl/api/events';
  final UserService _userService = UserService();

  Future<bool> applyToEvent(EventApplication application) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null) {
        print("❌ No token found - User needs to login again");
        await _userService.handleInvalidToken();
        return false;
      }

      if (userId == null) {
        print("❌ No userId found - User needs to login again");
        await _userService.handleInvalidToken();
        return false;
      }

      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print("❌ Token is invalid or expired");
        await _userService.handleInvalidToken();
        return false;
      }

      print("🔑 Token found: ${token.substring(0, 20)}...");
      print("👤 User ID: $userId");
      print("📤 Event application: ${jsonEncode(application.toJson())}");

      final url = Uri.parse('$baseUrl/apply');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(application.toJson()),
      );

      print("📡 Apply to event response status: ${response.statusCode}");
      print("📡 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Event application submitted successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed - Token may be expired or invalid");
        print("💡 Clearing invalid token and user data");
        await _userService.handleInvalidToken();
        return false;
      } else {
        print("❌ Failed to apply to event: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error applying to event: $e");
      return false;
    }
  }

  Future<bool> cancelApplication(
      {required int runnerId, required int taskId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/cancel?runnerId=$runnerId&taskId=$taskId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    return response.statusCode == 200;
  }

  Future<List<TaskResponse>> getTasksForRunner(int runnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/runner/$runnerId/tasks');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<EventAppResponse>> getApplicantsForTask(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/task/$taskId/applicants');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EventAppResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<bool> approveApplication(int taskPoster, int applicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/$taskPoster/approve/$applicationId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print(response.body);
    return response.statusCode == 200;
  }

  Future<bool> updateApplicationStatus(
      {required int id, required ApplicationStatus status}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
        '$baseUrl/update/$id/?status=${status.toString().split('.').last}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteApplicationsForTask(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/delete/$taskId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    return response.statusCode == 200;
  }

  Future<int?> getRemainingSeats(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/remaining-seats/$taskId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return int.tryParse(response.body);
    } else {
      return null;
    }
  }
}
