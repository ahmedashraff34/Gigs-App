import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dispute_model.dart';
import '../utils/api.dart';

class AdminDisputeService {
  static const String baseUrl = '$apiBaseUrl/api/admin';
  
  // Check if current user is admin
  Future<bool> _isAdminUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final role = prefs.getString('role');
    
    print('🔍 Checking admin status - Username: $username, Role: $role');
    
    return username == 'admin' || role == 'admin';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Debug token info
    if (token != null) {
      print('🔑 Admin token found: ${token.substring(0, 20)}...');
    } else {
      print('❌ No admin token found');
    }
    
    return token;
  }

  Future<List<Dispute>> getDisputes({String? status}) async {
    try {
      // Check if user is admin
      final isAdmin = await _isAdminUser();
      if (!isAdmin) {
        throw Exception('Access denied: Admin privileges required');
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      String endpoint = '$baseUrl/disputes';
      if (status != null && status.isNotEmpty) {
        endpoint += '/$status';
      }

      print('📡 Fetching disputes from: $endpoint');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response headers: ${response.headers}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dispute.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token might be invalid or expired');
        print('🔍 Token details: ${token.length} characters');
        throw Exception('Authentication failed - Please login as admin again');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied - Admin privileges required');
      } else {
        throw Exception('Failed to fetch disputes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching disputes: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> resolveDispute(String disputeId, String resolution) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('📡 Resolving dispute: $disputeId');

      final response = await http.put(
        Uri.parse('$baseUrl/disputes/$disputeId/resolve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'resolution': resolution,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to resolve dispute: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error resolving dispute: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> resolveDisputeWithPayment({
    required String disputeId,
    required String resolutionType,
    required String adminNotes,
    required int recipientId, // Changed to required int
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url =
          'http://10.0.2.2:8090/api/disputes/admin/$disputeId/resolve-with-payment';
      final Map<String, dynamic> body = {
        'resolutionType': resolutionType,
        'adminNotes': adminNotes,
        'recipientId': recipientId, // Always include recipientId
      };

      print('📡 Resolving dispute with payment: $url');
      print('📦 Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Dispute resolved with payment successfully');
        return true;
      } else {
        print('❌ Failed to resolve dispute with payment: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        throw Exception(
            'Failed to resolve dispute with payment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error resolving dispute with payment: $e');
      throw Exception('Network error: $e');
    }
  }
}
