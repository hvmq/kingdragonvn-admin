import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user_list_response.dart';
import '../models/transaction_response.dart';

class ApiService {
  // TODO: Update this URL with your current ngrok URL
  static const String baseUrl = 'https://kingdragonvn.com/api';
  // static const String baseUrl = 'http://localhost:3000/api';

  static Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      print('ApiService - Making login request for phone: $phoneNumber');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'deviceId': 'admin',
        }),
      );

      print('ApiService - Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('ApiService - Parsed response: $jsonResponse');
        return AuthResponse.fromJson(jsonResponse);
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during login: $e');
      rethrow;
    }
  }

  static Future<UserListResponse> getUsers(String token) async {
    try {
      print('ApiService - Fetching users list');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw users response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('ApiService - Parsed users response: $jsonResponse');
        return UserListResponse.fromJson(jsonResponse);
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during users fetch: $e');
      rethrow;
    }
  }

  static Future<TransactionResponse> getTransactions(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('ApiService - Fetching transactions');
      final response = await http.get(
        Uri.parse('$baseUrl/transactions?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw transactions response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('ApiService - Parsed transactions response: $jsonResponse');
        return TransactionResponse.fromJson(jsonResponse);
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch transactions: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during transactions fetch: $e');
      rethrow;
    }
  }

  static Future<void> updateTransactionStatus(
    String token,
    String transactionId,
    String status,
  ) async {
    try {
      print('ApiService - Updating transaction status');
      print('$baseUrl/transactions/$transactionId');
      print('ApiService - Status: $status');
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      print('ApiService - Raw update response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update transaction: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during transaction update: $e');
      rethrow;
    }
  }

  static Future<UserListResponse> searchUsers(
      String token, String query) async {
    try {
      print('ApiService - Searching users with query: $query');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw search response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('ApiService - Parsed search response: $jsonResponse');
        return UserListResponse.fromJson(jsonResponse);
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to search users: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during users search: $e');
      rethrow;
    }
  }

  static Future<VipPackageResponse> getVipPackages(String token) async {
    try {
      print('ApiService - Fetching VIP packages');
      final response = await http.get(
        Uri.parse('$baseUrl/vip/packages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw VIP packages response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('ApiService - Parsed VIP packages response: $jsonResponse');
        return VipPackageResponse.fromJson(jsonResponse);
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch VIP packages: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during VIP packages fetch: $e');
      rethrow;
    }
  }

  static Future<void> updateVipPackage(
    String token,
    String packageId,
    VipPackage package,
  ) async {
    try {
      print('ApiService - Updating VIP package: $packageId');
      final response = await http.put(
        Uri.parse('$baseUrl/vip/admin/packages/$packageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(package.toJson()),
      );

      print('ApiService - Raw VIP package update response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update VIP package: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during VIP package update: $e');
      rethrow;
    }
  }

  static Future<void> cancelUserVip(String token, String userId) async {
    try {
      print('ApiService - Cancelling VIP for user: $userId');
      final response = await http.delete(
        Uri.parse('$baseUrl/vip/admin/users/$userId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw cancel VIP response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to cancel user VIP: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during VIP cancellation: $e');
      rethrow;
    }
  }

  static Future<void> grantUserVip(
      String token, String userId, String packageId) async {
    try {
      print('ApiService - Granting VIP to user: $userId, package: $packageId');
      final response = await http.post(
        Uri.parse('$baseUrl/vip/admin/users/$userId/grant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'packageId': packageId}),
      );

      print('ApiService - Raw grant VIP response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to grant user VIP: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during VIP grant: $e');
      rethrow;
    }
  }
}
