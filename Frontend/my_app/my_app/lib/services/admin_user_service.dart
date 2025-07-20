import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_user_model.dart';
import '../utils/api.dart';

class AdminUserService {
  static const String usersUrl = '$apiBaseUrl/api/user/all';

  Future<List<AdminUser>> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(usersUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AdminUser.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
      throw Exception('Network error: $e');
    }
  }
}
