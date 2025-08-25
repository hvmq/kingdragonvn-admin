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

  static Future<Map<String, dynamic>> getDepositAccounts(String token) async {
    try {
      print('ApiService - Fetching deposit accounts');
      final response = await http.get(
        Uri.parse('$baseUrl/deposit-accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw deposit accounts response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('ApiService - Parsed deposit accounts response: $jsonResponse');
        return jsonResponse;
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch deposit accounts: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during deposit accounts fetch: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getBanksList(String token) async {
    try {
      print('ApiService - Fetching banks list');
      final response = await http.get(
        Uri.parse('$baseUrl/deposit-accounts/banks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw banks list response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('ApiService - Parsed banks list response: $jsonResponse');
        return jsonResponse;
      } else {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch banks list: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during banks list fetch: $e');
      rethrow;
    }
  }

  static Future<void> createDepositAccount(
    String token, {
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      print('ApiService - Creating deposit account');
      final response = await http.post(
        Uri.parse('$baseUrl/deposit-accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bankCode': bankCode,
          'accountNumber': accountNumber,
        }),
      );

      print('ApiService - Raw create deposit account response: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create deposit account: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during create deposit account: $e');
      rethrow;
    }
  }

  static Future<void> deleteDepositAccount(
    String token, {
    required String accountId,
  }) async {
    try {
      print('ApiService - Deleting deposit account: $accountId');
      final response = await http.delete(
        Uri.parse('$baseUrl/deposit-accounts/$accountId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ApiService - Raw delete deposit account response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete deposit account: ${response.body}');
      }
    } catch (e) {
      print('ApiService - Exception during delete deposit account: $e');
      rethrow;
    }
  }

  static Future<void> activateDepositAccount(
    String token, {
    required String accountId,
  }) async {
    try {
      print('ApiService - Activating deposit account: $accountId');
      final response = await http.post(
        Uri.parse('$baseUrl/deposit-accounts/$accountId/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('ApiService - Raw activate deposit account response: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'ApiService - Activate via PATCH failed: ${response.statusCode} - ${response.body}');
        // Fallback: Some browsers/servers block PATCH due to CORS. Retry with POST override.
        final fallback = await http.post(
          Uri.parse('$baseUrl/deposit-accounts/$accountId/activate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-HTTP-Method-Override': 'PATCH',
          },
          body: '{}',
        );
        print('ApiService - Fallback activate response: ${fallback.body}');
        if (fallback.statusCode != 200) {
          throw Exception('Failed to activate deposit account: ${fallback.body}');
        }
      }
    } catch (e) {
      print('ApiService - Exception during activate deposit account: $e');
      // Fallback on client exception as well
      try {
        final fallback = await http.post(
          Uri.parse('$baseUrl/deposit-accounts/$accountId/activate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-HTTP-Method-Override': 'PATCH',
          },
          body: '{}',
        );
        print('ApiService - Fallback activate (exception) response: ${fallback.body}');
        if (fallback.statusCode != 200) {
          rethrow;
        }
      } catch (_) {
        rethrow;
      }
    }
  }
}
