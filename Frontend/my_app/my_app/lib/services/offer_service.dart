import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import '../models/task_model.dart';
import '../services/user_service.dart';
import '../utils/api.dart';

class OfferService {
  final String offerEndpoint = "$apiBaseUrl/api/offers";
  final UserService _userService = UserService();

  Future<List<OfferResponse>> getOffersForTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for getting offers");
        return [];
      }

      final url = Uri.parse('$offerEndpoint/task/$taskId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("📡 Get offers response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OfferResponse.fromJson(json)).toList();
      } else {
        print("❌ Failed to get offers: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error getting offers: $e");
      return [];
    }
  }

  Future<bool> placeOffer(Offer offer) async {
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
      print("📤 Offer request: ${jsonEncode(offer.toJson())}");

      final url = Uri.parse(offerEndpoint);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(offer.toJson()),
      );

      print("📡 Place offer response status: ${response.statusCode}");
      print("📡 Response headers: ${response.headers}");
      print("📡 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Offer placed successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed - Token may be expired or invalid");
        print("💡 Clearing invalid token and user data");
        await _userService.handleInvalidToken();
        return false;
      } else {
        print("❌ Failed to place offer: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error placing offer: $e");
      return false;
    }
  }

  Future<bool> acceptOffer(
      {required int taskId,
      required int offerId,
      required int taskPosterId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for accepting offer");
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

      final url = Uri.parse(
          '$offerEndpoint/$offerId/accept?taskId=$taskId&taskPosterId=$taskPosterId');
      final response = await http.put(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("📡 Accept offer response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Offer accepted successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed when accepting offer");
        await _userService.handleInvalidToken();
        return false;
      } else {
        print("❌ Failed to accept offer: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error accepting offer: $e");
      return false;
    }
  }

  Future<List<OfferResponse>> getOffersByRunner(int runnerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for getting runner offers");
        return [];
      }

      final url = Uri.parse('$offerEndpoint/runner/$runnerId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("📡 Get runner offers response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OfferResponse.fromJson(json)).toList();
      } else {
        print("❌ Failed to get runner offers: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error getting runner offers: $e");
      return [];
    }
  }

  Future<bool> cancelOffer(int offerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for canceling offer");
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

      final url = Uri.parse('$offerEndpoint/$offerId/cancel');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("📡 Cancel offer response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Offer cancelled successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed when canceling offer");
        await _userService.handleInvalidToken();
        return false;
      } else {
        print("❌ Failed to cancel offer: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error canceling offer: $e");
      return false;
    }
  }

  Future<List<TaskResponse>> getAcceptedOffersTasks(int runnerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for getting accepted offers tasks");
        return [];
      }

      final url = Uri.parse('$offerEndpoint/accepted/runner/$runnerId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print(
          "📡 Get accepted offers tasks response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskResponse.fromJson(json)).toList();
      } else {
        print("❌ Failed to get accepted offers tasks: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error getting accepted offers tasks: $e");
      return [];
    }
  }

  Future<bool> hasRunnerOffered(int taskId, int runnerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found for checking if runner has offered");
        return false;
      }

      final url =
          Uri.parse('$offerEndpoint/exists?taskId=$taskId&runnerId=$runnerId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print(
          "📡 Check if runner has offered response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Runner has already offered on this task");
        return true;
      } else if (response.statusCode == 400) {
        print("❌ Runner has not offered on this task");
        return false;
      } else {
        print(
            "❌ Failed to check if runner has offered: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error checking if runner has offered: $e");
      return false;
    }
  }

  // Get offer count for a task
  Future<int> getOfferCountForTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("❌ No token found for getting offer count");
        return 0;
      }
      final url = Uri.parse('$offerEndpoint/count/$taskId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print("📡 Get offer count response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      } else {
        print("❌ Failed to get offer count: ${response.statusCode}");
        print("Body: ${response.body}");
        return 0;
      }
    } catch (e) {
      print("❌ Error getting offer count: $e");
      return 0;
    }
  }

  // Future<bool> updateOfferStatus(int offerId, OfferStatus status) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final url = Uri.parse('$offerEndpoint/$offerId/status?status=${status.toString().split('.').last}');
  //   final response = await http.put(url, headers: {
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   });
  //   return response.statusCode == 200;
  // }
}
