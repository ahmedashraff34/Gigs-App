import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/api_config.dart';
import 'token_service.dart';

class UserService {
  Future<List<UserModel>> getAllUsers() async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse(ApiConfig.getAllUsersEndpoint);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> userData = jsonDecode(response.body);
        return userData.map((data) => UserModel.fromMap(data)).toList();
      } else {
        throw Exception(
            'Failed to load users. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching users: ${e.toString()}');
    }
  }
} 