import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../services/user_service.dart';
import '../utils/api.dart';

class SosService {
  final String sosEndpoint = "$apiBaseUrl/api/sos";
  final UserService _userService = UserService();

  /// Send SOS alert with current location and optional comment
  ///
  /// [taskId] - The ID of the task where SOS is being sent
  /// [comment] - Optional comment to include with the SOS alert
  /// Returns true if SOS was sent successfully, false otherwise
  Future<bool> sendSosAlert({
    required int taskId,
    String? comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

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

      // Get current location
      Position? currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print(
            '📍 Current location: ${currentPosition.latitude}, ${currentPosition.longitude}');
      } catch (e) {
        print('❌ Error getting location: $e');
        // Continue without location if GPS fails
      }

      // Prepare SOS data
      final sosData = {
        'taskId': taskId,
        'userId': int.parse(userId!),
        'timestamp': DateTime.now().toIso8601String(),
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (currentPosition != null)
          'location': {
            'latitude': currentPosition.latitude,
            'longitude': currentPosition.longitude,
            'accuracy': currentPosition.accuracy,
          },
      };

      print('📤 Sending SOS alert: ${jsonEncode(sosData)}');

      final response = await http.post(
        Uri.parse('$sosEndpoint/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sosData),
      );

      print('📡 SOS response status: ${response.statusCode}');
      print('📡 SOS response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SOS alert sent successfully');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired or invalid');
        await _userService.handleInvalidToken();
        return false;
      } else {
        print('❌ Failed to send SOS alert: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending SOS alert: $e');
      return false;
    }
  }

  /// Get SOS alerts for a specific task
  ///
  /// [taskId] - The ID of the task to get SOS alerts for
  /// Returns list of SOS alerts for the task
  Future<List<Map<String, dynamic>>> getSosAlertsForTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ No token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$sosEndpoint/task/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to get SOS alerts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting SOS alerts: $e');
      return [];
    }
  }

  /// Check if user has permission to send SOS for a task
  ///
  /// [taskId] - The ID of the task
  /// [userId] - The ID of the user
  /// Returns true if user can send SOS for this task
  Future<bool> canSendSosForTask(int taskId, int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse(
            '$sosEndpoint/check-permission?taskId=$taskId&userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['canSend'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error checking SOS permission: $e');
      return false;
    }
  }

  Future<void> sendEmulatorLocationToServer() async {
    try {
      // Dummy location data for Dokki, Egypt
      final double latitude = 30.033333; // Dokki latitude
      final double longitude = 31.216667; // Dokki longitude
      final String city = 'Dokki';
      final String region = 'Giza';
      final String country = 'Egypt';

      final url = Uri.parse('http://10.0.2.2:5000/send_location');

      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'region': region,
        'country': country,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(locationData),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }
}
