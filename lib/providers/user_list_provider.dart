import 'package:flutter/material.dart';
import '../models/user_list_response.dart';
import '../services/api_service.dart';

class UserListProvider extends ChangeNotifier {
  List<UserListItem> _users = [];
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;

  List<UserListItem> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Pagination? get pagination => _pagination;

  Future<void> fetchUsers(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getUsers(token);
      _users = response.users;
      _pagination = response.pagination;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchUsers(String token, String query) async {
    if (query.isEmpty) {
      return fetchUsers(token);
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.searchUsers(token, query);
      _users = response.users;
      _pagination = response.pagination;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancelUserVip(String token, String userId) async {
    try {
      await ApiService.cancelUserVip(token, userId);
      // Refresh users list to get updated data
      await fetchUsers(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> grantUserVip(
      String token, String userId, String packageId) async {
    try {
      await ApiService.grantUserVip(token, userId, packageId);
      // Refresh users list to get updated data
      await fetchUsers(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
