import 'package:flutter/material.dart';
import '../models/notification_response.dart';
import '../services/api_service.dart';
import '../services/session_storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationData? _notification;
  bool _isLoading = false;
  String? _error;

  NotificationData? get notification => _notification;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotification() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getNotification();
      _notification = response.notification;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNotification(String text) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('Không có token xác thực');
      }

      await ApiService.updateNotification(text, token);
      await fetchNotification(); // Refresh the notification
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 