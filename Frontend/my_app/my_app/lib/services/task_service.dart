import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../config/api_config.dart';
import 'token_service.dart';
import 'dart:io';
import '../models/offer.dart';
import '../models/event_task.dart';
import '../models/task_response.dart';
import '../models/event_task_request.dart';

class TaskService {
  List<Task> getDummyTasks() {
    // This dummy data needs to be updated to match the new Task model.
    // For now, I'll return an empty list to resolve the compilation errors.
    // We can repopulate this later if needed.
    return [];
  }

  Future<Map<String, dynamic>> postTask(Task task) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse(ApiConfig.postTaskEndpoint);

    // Debug print statements
    print('Posting task with posterId: [33m[1m[4m[7m[41m[42m[43m[44m[45m[46m[47m[100m[101m[102m[103m[104m[105m[106m[107m${task.taskPoster}[0m');
    print('Task payload: [36m${jsonEncode(task.toJson())}[0m');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle non-JSON success responses
        if (response.body.isNotEmpty && response.body.trim().startsWith('{')) {
          return {'success': true, 'data': jsonDecode(response.body)};
        }
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error':
              'Failed to post task. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<List<Task>> getTasksByPoster(String posterId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse(ApiConfig.getTasksByPosterEndpoint(posterId));
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskData = jsonDecode(response.body);
        // We'll need a Task.fromJson constructor for this to work
        return taskData.map((data) => Task.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load tasks. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<List<Task>> getAllTasks() async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse(ApiConfig.getAllTasksEndpoint);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskData = jsonDecode(response.body);
        return taskData.map((data) => Task.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load tasks. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(
      int taskId, String newStatus, String userId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse(
        '${ApiConfig.updateTaskStatusEndpoint(taskId)}?newStatus=$newStatus&userId=$userId');

    print('Updating task status - URL: $url');
    print('Task ID: $taskId, New Status: $newStatus, User ID: $userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Task status update response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error':
              'Failed to update status. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      print('Task status update error: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTask(TaskResponse task, int userId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse('${ApiConfig.taskBaseUrl}/delete/${task.taskId}');
    // Determine task_type
    String taskType = 'REGULAR';
    if (task.category == Category.EventStaffing || task.category == Category.Event) {
      taskType = 'EVENT';
    }
    // Build the request body
    if (taskType == 'REGULAR') {
      final bodyMap = {
        'title': task.title,
        'description': task.description,
        'type': task.category.name,
        'task_type': taskType, // Required for backend polymorphic deserialization
        'taskPoster': userId,
        'longitude': task.longitude,
        'latitude': task.latitude,
        'additionalRequirements': task.additionalRequirements,
        'amount': task.amount,
        'additionalAttributes': task.additionalAttributes,
      };
      final body = jsonEncode(bodyMap);
      try {
        final response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        );
        if (response.statusCode == 200) {
          return {'success': true, 'data': response.body};
        } else {
          return {
            'success': false,
            'error': 'Failed to delete task. Status: ${response.statusCode}, Body: ${response.body}',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'An error occurred: ${e.toString()}',
        };
      }
    } else {
      // For event tasks, use EventTaskRequest
      try {
        // Use event-specific fields from top-level TaskResponse properties
        final location = task.location;
        final fixedPay = task.fixedPay;
        final requiredPeople = task.requiredPeople;
        final startDate = task.startDate;
        final endDate = task.endDate;
        final numberOfDays = task.numberOfDays;
        print('[DEBUG] EventTaskRequest location (top-level): $location');
        print('[DEBUG] EventTaskRequest fixedPay (top-level): $fixedPay');
        print('[DEBUG] EventTaskRequest requiredPeople (top-level): $requiredPeople');
        print('[DEBUG] EventTaskRequest startDate (top-level): $startDate');
        print('[DEBUG] EventTaskRequest endDate (top-level): $endDate');
        print('[DEBUG] EventTaskRequest numberOfDays (top-level): $numberOfDays');
        final eventTaskRequest = EventTaskRequest(
          title: task.title,
          description: task.description,
          type: task.category.name,
          taskType: taskType,
          taskPoster: userId,
          longitude: task.longitude,
          latitude: task.latitude,
          location: location ?? '',
          fixedPay: fixedPay ?? 0.0,
          requiredPeople: requiredPeople ?? 1,
          startDate: startDate ?? '',
          endDate: endDate ?? '',
          numberOfDays: numberOfDays ?? 1,
        );
        final body = jsonEncode(eventTaskRequest.toJson());
        final response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        );
        if (response.statusCode == 200) {
          return {'success': true, 'data': response.body};
        } else {
          return {
            'success': false,
            'error': 'Failed to delete task. Status: ${response.statusCode}, Body: ${response.body}',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'An error occurred: ${e.toString()}',
        };
      }
    }
  }

  Future<Map<String, dynamic>> postOffer({
    required int taskId,
    required int runnerId,
    required double amount,
    required String message,
  }) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers');
    final body = jsonEncode({
      'taskId': taskId,
      'runnerId': runnerId,
      'amount': amount,
      'comment': message,
      'status': 'PENDING',
    });
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to post offer. Status: \u001b[31m[0m${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<List<Offer>> getOffersForTask(int taskId) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/task/$taskId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<List<Offer>> getOffersByRunner(String runnerId) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/runner/$runnerId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAcceptedOffersByRunner(String runnerId) async {
    print('[DEBUG] getAcceptedOffersByRunner called with runnerId: $runnerId');
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/accepted/runner/$runnerId');
    print('[DEBUG] Making request to: $url');
    print('[DEBUG] Token available: ${token != null}');
    
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[DEBUG] Parsed ${data.length} items from response');
        
        List<Map<String, dynamic>> result = [];
        for (final item in data) {
          try {
            // The backend now returns task data directly
            // Create a TaskResponse from the item
            final taskResponse = TaskResponse.fromJson(item);
            
            // Create a minimal offer object for compatibility
            final offer = Offer(
              id: taskResponse.taskId.toString(),
              runnerId: runnerId,
              amount: taskResponse.amount,
              message: 'Accepted offer for task',
              timestamp: DateTime.now(),
              taskId: taskResponse.taskId.toString(),
              status: OfferStatus.ACCEPTED,
            );
            
            result.add({'offer': offer, 'task': taskResponse});
            print('[DEBUG] Created offer/task pair for task ${taskResponse.taskId}');
          } catch (e) {
            print('[DEBUG] Failed to parse item: $e');
          }
        }
        
        print('[DEBUG] Created ${result.length} offer/task pairs');
        return result;
      } else {
        print('[DEBUG] API call failed with status: ${response.statusCode}');
        throw Exception('Failed to load accepted offers. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('[DEBUG] Exception in getAcceptedOffersByRunner: $e');
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteOffer(String offerId) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/$offerId/cancel');
    try {
      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to delete offer. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> acceptOffer({
    required String offerId,
    required int taskId,
    required int taskPosterId,
  }) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/$offerId/accept?taskId=$taskId&taskPosterId=$taskPosterId');
    try {
      final response = await http.put(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to accept offer. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteAllOffersForTask(int taskId) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082';
    final url = Uri.parse('$baseUrl/api/offers/task/$taskId');
    try {
      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to delete offers for task. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTaskStatusToInProgress(int taskId) async {
    final userId = await TokenService.getUserId();
    if (userId == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }
    
    print('Updating task $taskId status to IN_PROGRESS for user $userId');
    
    // Try the existing method first
    final result = await updateTaskStatus(taskId, 'IN_PROGRESS', userId);
    print('Task status update result: $result');
    
    // If it fails, try alternative method with body
    if (!result['success']) {
      print('Trying alternative method with request body...');
      final alternativeResult = await updateTaskStatusWithBody(taskId, 'IN_PROGRESS', userId);
      print('Alternative task status update result: $alternativeResult');
      return alternativeResult;
    }
    
    return result;
  }

  Future<Map<String, dynamic>> updateTaskStatusWithBody(
      int taskId, String newStatus, String userId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8081' : 'http://localhost:8081';
    final url = Uri.parse('$baseUrl/api/tasks/regular/$taskId/status');

    print('Alternative task status update - URL: $url');
    print('Task ID: $taskId, New Status: $newStatus, User ID: $userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': newStatus,
          'userId': userId,
        }),
      );

      print('Alternative task status update response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error':
              'Failed to update status. Status: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e) {
      print('Alternative task status update error: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Task> getTaskById(String taskId) async {
    final token = await TokenService.getToken();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8081' : 'http://localhost:8081';
    final url = Uri.parse('$baseUrl/api/tasks/regular/$taskId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to load task. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  /// Posts a new event staffing task to the backend.
  ///
  /// Takes an EventTask model, serializes it to JSON, and sends it to the backend API.
  /// Returns a map with 'success' and either 'data' or 'error'.
  ///
  /// Usage:
  ///   final result = await postEventTask(eventTask);
  Future<Map<String, dynamic>> postEventTask(EventTask eventTask) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    // Prepare the API endpoint URL
    final url = Uri.parse(ApiConfig.postTaskEndpoint);

    // Debug print for developer
    print('Posting event task with posterId: \\${eventTask.taskPoster}');
    print('EventTask payload: \\${jsonEncode(eventTask.toJson())}');

    try {
      // Send POST request with event task data
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(eventTask.toJson()),
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty && response.body.trim().startsWith('{')) {
          return {'success': true, 'data': jsonDecode(response.body)};
        }
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error':
              'Failed to post event task. Status: \\${response.statusCode}, Body: \\${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: \\${e.toString()}',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getTasksByPosterRaw(String posterId) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse(ApiConfig.getTasksByPosterEndpoint(posterId));
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> taskData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(taskData);
    } else {
      throw Exception('Failed to load tasks. Status: [31m${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<List<TaskResponse>> getNearbyTasks({
    required double latitude,
    required double longitude,
    double radius = 300,
  }) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse(
      '${ApiConfig.taskBaseUrl}/nearby?lat=$latitude&lon=$longitude&radius=$radius',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearby tasks. Status: \\${response.statusCode}, Body: \\${response.body}');
    }
  }

  Future<List<TaskResponse>> getOpenRegularTasksByPoster(int posterId) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse('http://10.0.2.2:8081/api/tasks/regular/open?taskPosterId=$posterId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load open regular tasks. Status: \\${response.statusCode}, Body: \\${response.body}');
    }
  }

  Future<List<TaskResponse>> getOpenEventTasksByPoster(int posterId) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse('http://10.0.2.2:8081/api/tasks/event/open?taskPosterId=$posterId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load open event tasks. Status: \\${response.statusCode}, Body: \\${response.body}');
    }
  }

  Future<int> getTaskCountByStatus({required int userId, required String status}) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse('http://10.0.2.2:8081/api/tasks/count?userId=$userId&status=$status');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is int) return data;
      if (data is Map && data.containsKey('count')) return data['count'] as int;
      return int.tryParse(data.toString()) ?? 0;
    } else {
      throw Exception('Failed to fetch task count. Status: \\${response.statusCode}, Body: \\${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteTaskById(int taskId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    final url = Uri.parse('http://10.0.2.2:8081/api/tasks/deleteById/$taskId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to delete task. Status: \\${response.statusCode}, Body: \\${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: \\${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> acceptRegularTaskOffer({
    required int taskId,
    required int taskPosterId,
    required int runnerId,
    required double amount,
  }) async {
    final token = await TokenService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    final url = Uri.parse('http://10.0.2.2:8081/api/tasks/$taskId/accept?taskPosterId=$taskPosterId&runnerId=$runnerId&amount=$amount');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'error': 'Failed to accept offer. Status: \\${response.statusCode}, Body: \\${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: \\${e.toString()}',
      };
    }
  }
}