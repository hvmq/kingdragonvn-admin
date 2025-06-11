import 'package:flutter/material.dart';
import '../services/session_storage_service.dart';
import '../services/api_service.dart';
import '../models/auth_response.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;

  AuthProvider() {
    _loadAuthState();
  }

  void _loadAuthState() {
    _token = SessionStorageService.getToken();
    _isAuthenticated = _token != null;
    print(
        'AuthProvider - Loaded state: isAuthenticated=$_isAuthenticated, token=$_token');
    notifyListeners();
  }

  Future<void> login(String phoneNumber, String password) async {
    try {
      print('AuthProvider - Attempting login with phone: $phoneNumber');
      final response = await ApiService.login(phoneNumber, password);
      print('AuthProvider - Login response: ${response.toJson()}');

      _token = response.token;
      _user = response.user;
      _isAuthenticated = true;

      print('AuthProvider - User data after login: ${_user?.toJson()}');
      print('AuthProvider - Phone number: ${_user?.phoneNumber}');

      SessionStorageService.setToken(_token!);
      notifyListeners();
    } catch (e) {
      print('AuthProvider - Login error: $e');
      _isAuthenticated = false;
      _token = null;
      _user = null;
      SessionStorageService.clearToken();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    print('AuthProvider - Logging out');
    _isAuthenticated = false;
    _token = null;
    _user = null;
    SessionStorageService.clearToken();
    notifyListeners();
  }
}
