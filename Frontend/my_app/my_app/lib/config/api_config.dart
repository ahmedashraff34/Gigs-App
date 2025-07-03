import 'dart:io';

class ApiConfig {
  static const String _localIP = '10.0.2.2'; // Use 10.0.2.2 for Android Emulator

  // --- Auth Service ---
  static const String _authPort = '8888';
  static String get authBaseUrl {
    if (Platform.isAndroid) {
      return 'http://$_localIP:$_authPort';
    }
    // Add other platforms if needed
    return 'http://localhost:$_authPort';
  }
  static String get registerEndpoint => '$authBaseUrl/auth/register';
  static String get loginEndpoint => '$authBaseUrl/auth/login';

  // --- User Service ---
  static String get getAllUsersEndpoint => '$authBaseUrl/api/user/all';

  // --- Task Service ---
  static const String _taskPort = '8081';
  static String get taskBaseUrl {
    if (Platform.isAndroid) {
      return 'http://$_localIP:$_taskPort/api/tasks';
    }
    // Add other platforms if needed
    return 'http://localhost:$_taskPort/api/tasks';
  }
  static String get postTaskEndpoint => '$taskBaseUrl/postTask';
  static String getTasksByPosterEndpoint(String posterId) => '$taskBaseUrl/poster/$posterId';
  static String updateTaskStatusEndpoint(int taskId) => '$taskBaseUrl/$taskId/status';
  static String get getAllTasksEndpoint => '$authBaseUrl/api/tasks/all';
} 