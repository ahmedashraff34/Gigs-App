import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../services/user_service.dart';
import '../utils/api.dart';

class TaskService {
  final String taskEndpoint = "$apiBaseUrl/api/tasks";
  final UserService _userService = UserService();

  Future<bool> postTask(taskRequest) async {
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
      print("📤 Request body: ${jsonEncode(taskRequest.toJson())}");

      final response = await http.post(
        Uri.parse("$taskEndpoint/postTask"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskRequest.toJson()),
      );

      print("📡 Response status: ${response.statusCode}");
      print("📡 Response headers: ${response.headers}");
      print("📡 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Task posted successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed - Token may be expired or invalid");
        print("💡 Clearing invalid token and user data");
        await _userService.handleInvalidToken();
        return false;
      } else {
        print("❌ Failed to post task: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error posting task: $e");
      return false;
    }
  }

  Future<List<TaskResponse>> getUnassignedTasks(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found");
        return [];
      }
      final response = await http.get(
        Uri.parse("$taskEndpoint/regular/open?taskPosterId=$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<TaskResponse> tasks = data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();

        // print("✅ Unassigned tasks fetched: ${tasks.length}");
        return tasks;
      } else {
        print("❌ Failed to fetch unassigned tasks: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching unassigned tasks: $e");
      return [];
    }
  }

  Future<List<TaskResponse>> getOngoingTasks(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found");
        return [];
      }

      final response = await http.get(
        Uri.parse("$taskEndpoint/poster/ongoing?taskPosterId=$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<TaskResponse> tasks = data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();

        // print("✅ Ongoing tasks fetched: ${tasks.length}");
        return tasks;
      } else {
        print("❌ Failed to fetch ongoing tasks: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching ongoing tasks: $e");
      return [];
    }
  }

  Future<List<TaskResponse>?> getTasksByTaskPosterId(
      String taskPosterId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];
    final response = await http.get(
      Uri.parse("$taskEndpoint/poster/$taskPosterId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<TaskResponse> tasks = data
          .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      return tasks;
    } else {
      print("jkashdfjah");
    }
    return [];
  }

  Future<List<TaskResponse>> getNearbyTasks({
    required double latitude,
    required double longitude,
    required double radius,
    required String userId,
  }) async {
    final url = Uri.parse(
        '$taskEndpoint/nearby?lat=$latitude&lon=$longitude&radius=$radius&userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to fetch nearby tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching nearby tasks: $e');
      return [];
    }
  }

  Future<bool> deleteTask(int taskId, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return false;
      }

      final url = Uri.parse('$taskEndpoint/delete/$taskId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Task deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete task: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }

  Future<TaskResponse?> fetchRegularTaskById(int taskId) async {
    final url = Uri.parse('$taskEndpoint/regular/$taskId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        print("Task not found");
      } else if (response.statusCode == 400) {
        print("Task is not a RegularTask");
      } else {
        print("Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching task: $e");
    }

    return null;
  }

  Future<bool> updateTaskStatus({
    required int taskId,
    required String newStatus, // or TaskStatus if you have an enum
    required int userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return false;
      }

      final url = Uri.parse(
          "$taskEndpoint/$taskId/status?newStatus=$newStatus&userId=$userId");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Task status updated successfully');
        return true;
      } else {
        print('❌ Failed to update task status: \\${response.statusCode}');
        print('Response body: \\${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating task status: $e');
      return false;
    }
  }

  Future<bool> editTask(int taskId, dynamic taskRequest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('❌ No token found - User needs to login again');
        await _userService.handleInvalidToken();
        return false;
      }
      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print('❌ Token is invalid or expired');
        await _userService.handleInvalidToken();
        return false;
      }
      print('📤 Edit Task body: ${jsonEncode(taskRequest.toJson())}');
      final response = await http.put(
        Uri.parse('$taskEndpoint/edit/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskRequest.toJson()),
      );
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      if (response.statusCode == 200) {
        print('✅ Task edited successfully');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired or invalid');
        await _userService.handleInvalidToken();
        return false;
      } else {
        print('❌ Failed to edit task: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error editing task: $e');
      return false;
    }
  }

  /// Count tasks by status for a specific user
  ///
  /// [userId] - The ID of the user (task poster or runner)
  /// [status] - The status to count (e.g., 'DONE', 'OPEN', 'IN_PROGRESS', etc.)
  /// Returns the count of tasks with the specified status for the user
  Future<int> countTasksByStatusForUser(int userId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ No token found - User needs to login again');
        await _userService.handleInvalidToken();
        return 0;
      }

      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print('❌ Token is invalid or expired');
        await _userService.handleInvalidToken();
        return 0;
      }

      final url =
          Uri.parse('$taskEndpoint/count?userId=$userId&status=$status');

      print('📡 Counting tasks for user $userId with status: $status');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Count response status: ${response.statusCode}');
      print('📡 Count response body: ${response.body}');

      if (response.statusCode == 200) {
        final count = int.tryParse(response.body) ?? 0;
        print('✅ Found $count tasks with status: $status for user: $userId');
        return count;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired or invalid');
        await _userService.handleInvalidToken();
        return 0;
      } else {
        print('❌ Failed to count tasks: ${response.statusCode}');
        print('Body: ${response.body}');
        return 0;
      }
    } catch (e) {
      print('❌ Error counting tasks: $e');
      return 0;
    }
  }

  Future<int> countCompletedTasksForUser(int userId) async {
    return await countTasksByStatusForUser(userId, 'DONE');
  }

  Future<int> countOpenTasksForUser(int userId) async {
    return await countTasksByStatusForUser(userId, 'OPEN');
  }

  Future<int> countInProgressTasksForUser(int userId) async {
    return await countTasksByStatusForUser(userId, 'IN_PROGRESS');
  }

  Future<bool> removeRunnerFromEventTask({
    required int taskId,
    required int runnerId,
    required int taskPosterId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('No token found');
        return false;
      }
      final url = Uri.parse(
          '$taskEndpoint/$taskId/remove-runner/$runnerId?taskPosterId=$taskPosterId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print('✅ Runner removed and refund processed successfully.');
        return true;
      } else {
        print('❌ Failed to remove runner: \\${response.statusCode}');
        print('Response body: \\${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error removing runner from event task: $e');
      return false;
    }
  }

  /// Calls the AI description generation endpoint and returns the generated description.
  Future<String?> generateAIDescription(Map<String, dynamic> taskData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('❌ No token found - User needs to login again');
        await _userService.handleInvalidToken();
        return null;
      }
      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print('❌ Token is invalid or expired');
        await _userService.handleInvalidToken();
        return null;
      }
      final url = Uri.parse(
          'https://3551e03c7702.ngrok-free.app/api/tasks/suggest-description');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskData),
      );
      print('📡 AI Description response status: ${response.statusCode}');
      print('📡 AI Description response body: ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('❌ Failed to generate AI description: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error generating AI description: $e');
      return null;
    }
  }

  Future<String?> generateAIPrice(Map<String, dynamic> taskData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('❌ No token found - User needs to login again');
        await _userService.handleInvalidToken();
        return null;
      }
      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print('❌ Token is invalid or expired');
        await _userService.handleInvalidToken();
        return null;
      }
      final url = Uri.parse(
          'https://3551e03c7702.ngrok-free.app/api/tasks/suggest-price');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskData),
      );
      print('📡 AI Description response status: ${response.statusCode}');
      print('📡 AI Description response body: ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('❌ Failed to generate AI description: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error generating AI description: $e');
      return null;
    }
  }
}
