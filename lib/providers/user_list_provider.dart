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
}
