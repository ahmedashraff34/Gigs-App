import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'token_service.dart';
import '../config/api_config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roles = List<String>.from(data['roles'] ?? []);
        return roles.contains('admin');
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Register user with Spring backend
  Future<Map<String, dynamic>> registerWithBackend({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle non-JSON success response from backend
        if (response.body.isEmpty || !response.body.trim().startsWith('{')) {
          return {'success': true, 'data': response.body};
        }
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'error': errorData['errorMessage'] ?? errorData['message'] ?? 'Registration failed',
          };
        } catch (e) {
          return {
            'success': false,
            'error': response.body,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login user with Spring backend
  Future<Map<String, dynamic>> loginWithBackend({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      // Print the full response for debugging
      print('Login Response Status: [32m${response.statusCode}[0m');
      print('Login Response Body: [36m${response.body}[0m');

      if (response.statusCode == 200) {
        // Ensure the success response is valid JSON
        if (response.body.isEmpty || !response.body.trim().startsWith('{')) {
          return {
            'success': false,
            'error': 'Received an invalid response from the server.',
          };
        }
        final responseData = jsonDecode(response.body);
        final result = <String, dynamic>{
          'success': true,
          'data': responseData,
          'token': responseData['access_token'],
        };

        // Try to get user_id from response, else fallback to numeric_id from JWT
        String? userIdToStore;
        if (responseData.containsKey('user_id')) {
          userIdToStore = responseData['user_id'].toString();
        } else if (responseData.containsKey('access_token')) {
          String token = responseData['access_token'];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          if (decodedToken.containsKey('numeric_id')) {
            userIdToStore = decodedToken['numeric_id'].toString();
          }
        }
        if (userIdToStore != null) {
          await TokenService.storeUserId(userIdToStore);
          print('Stored userId: ' + userIdToStore);
        } else {
          print('WARNING: No user_id or numeric_id found in login response or token.');
        }

        // Optionally, store the token as well
        if (responseData.containsKey('access_token')) {
          await TokenService.storeToken(responseData['access_token']);
        }

        return result;
      } else {
        // Handle error responses
        var errorMessage = 'Login failed with status: ${response.statusCode}'; // Default error
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['errorMessage'] ?? errorData['message'] ?? response.body;
          } catch (e) {
            // The response body is not valid JSON. Use the raw string.
            errorMessage = response.body;
          }
        }
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Sign up with email and password (keeping Firebase for now as fallback)
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String governmentId,
    List<String> roles,
    String? profileImageUrl,
  ) async {
    try {
      // First create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Then create the user document in Firestore
      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          governmentId: governmentId,
          roles: roles,
          profileImageUrl: profileImageUrl,
          createdAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.id).set({
          'id': user.id,
          'email': user.email,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'governmentId': user.governmentId,
          'roles': user.roles,
          'profileImageUrl': user.profileImageUrl,
          'rating': user.rating,
          'completedTasks': user.completedTasks,
          'createdAt': user.createdAt.toIso8601String(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign in with email and password (keeping Firebase for now as fallback)
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  // Add a role to user
  Future<void> addRole(String userId, String role) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'roles': FieldValue.arrayUnion([role])
      });
    } catch (e) {
      print('Error adding role: $e');
      throw Exception('Failed to add role');
    }
  }

  // Remove a role from user
  Future<void> removeRole(String userId, String role) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'roles': FieldValue.arrayRemove([role])
      });
    } catch (e) {
      print('Error removing role: $e');
      throw Exception('Failed to remove role');
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Clear stored token
    await TokenService.clearAuthData();
    // Sign out from Firebase (if still using it)
    return _auth.signOut();
  }
}