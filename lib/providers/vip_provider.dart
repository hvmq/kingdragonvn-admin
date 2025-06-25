import 'package:flutter/foundation.dart';
import '../models/user_list_response.dart';
import '../services/api_service.dart';
import '../services/session_storage_service.dart';

class VipProvider with ChangeNotifier {
  List<VipPackage> _packages = [];
  String _currentVip = '';
  int _remainingDays = 0;
  bool _isLoading = false;
  String? _error;

  List<VipPackage> get packages => _packages;
  String get currentVip => _currentVip;
  int get remainingDays => _remainingDays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVipPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.getVipPackages(token);
      _packages = response.packages;
      _currentVip = response.currentVip;
      _remainingDays = response.remainingDays;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('VipProvider - Error fetching VIP packages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVipPackage(
      String packageId, VipPackage updatedPackage) async {
    try {
      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.updateVipPackage(token, packageId, updatedPackage);

      // Update the local list
      final index = _packages.indexWhere((pkg) => pkg.id == packageId);
      if (index != -1) {
        _packages[index] = updatedPackage;
        notifyListeners();
      }

      // Refresh the entire list to get updated data from server
      await fetchVipPackages();
    } catch (e) {
      _error = e.toString();
      print('VipProvider - Error updating VIP package: $e');
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
