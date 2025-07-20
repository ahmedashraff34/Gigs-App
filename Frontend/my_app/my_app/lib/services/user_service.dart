import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/api.dart';

class UserService {
  String authEndpoint = apiBaseUrl;

  /// Check if the current token is valid and not expired
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found");
        return false;
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        print("❌ Token is expired");
        return false;
      }

      print("✅ Token is valid and not expired");
      return true;
    } catch (e) {
      print("❌ Error validating token: $e");
      return false;
    }
  }

  /// Get current token info for debugging
  Future<Map<String, dynamic>?> getTokenInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    } catch (e) {
      print("❌ Error decoding token: $e");
      return null;
    }
  }

  Future<bool> loginUser(
      {required String username,
      required String password,
      required String selectedRole}) async {
    try {
      final response = await http.post(
        Uri.parse("$authEndpoint/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        // ✅ Decode JWT
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

        final userId = data['user_id'].toString(); // Also present in response
        final email = decodedToken['email'];
        final username = decodedToken['preferred_username'];

        // ✅ Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken);
        await prefs.setString('userId', userId);
        await prefs.setString('email', email);
        await prefs.setString('username', username);
        await prefs.setString('role', selectedRole);

        print("Login Successfully");

        return true;
      } else {
        print('Login failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> registerUser({
    required String firstname,
    required String lastname,
    required String email,
    required String username,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$authEndpoint/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstname,
          'lastName': lastname,
          'email': email,
          'username': username,
          'phoneNumber': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return null;
      }

      final response = await http.get(
        Uri.parse("$authEndpoint/api/user/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromMap(data);
      } else {
        print('Failed to fetch user: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> updateUserById({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return false;
      }

      final response = await http.put(
        Uri.parse("$authEndpoint/auth/profile/basic?userId=$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ User updated successfully");
        return true;
      } else {
        print("❌ Failed to update user: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating user: $e");
      return false;
    }
  }

  Future<bool> updateProfileUrl(
      {required String userId, required String profileUrl}) async {
    try {
      print(profileUrl);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('No token found');
        return false;
      }
      final response = await http.patch(
        Uri.parse(
            "$authEndpoint/api/user/$userId/profile-url?profileUrl=${profileUrl}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print("✅ Profile URL updated successfully");
        return true;
      } else {
        print("❌ Failed to update profile URL: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating profile URL: $e");
      return false;
    }
  }

  saveToken() {}

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('username');
    print("User logged out successfully.");
  }

  Future<String?> getUsernameById(String userId) async {
    final user = await getUserById(userId);
    return user?.username;
  }

  /// Handle invalid token by clearing stored data and redirecting to login
  Future<void> handleInvalidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('email');
      await prefs.remove('username');
      await prefs.remove('role');
      print("🔒 Cleared invalid token and user data");
    } catch (e) {
      print("❌ Error clearing invalid token: $e");
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        return false;
      }

      return await isTokenValid();
    } catch (e) {
      print("❌ Error checking login status: $e");
      return false;
    }
  }

  /// Debug method to print current authentication state
  Future<void> debugAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      final email = prefs.getString('email');
      final username = prefs.getString('username');
      final role = prefs.getString('role');

      print("🔍 === AUTH DEBUG INFO ===");
      print("Token exists: ${token != null}");
      print("User ID: $userId");
      print("Email: $email");
      print("Username: $username");
      print("Role: $role");

      if (token != null) {
        final isExpired = JwtDecoder.isExpired(token);
        print("Token expired: $isExpired");

        if (!isExpired) {
          final decodedToken = JwtDecoder.decode(token);
          print("Token payload: $decodedToken");
        }
      }
      print("==========================");
    } catch (e) {
      print("❌ Error in debug auth state: $e");
    }
  }
}
