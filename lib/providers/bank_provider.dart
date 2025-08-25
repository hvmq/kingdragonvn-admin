import 'package:flutter/foundation.dart';
import '../models/bank_accounts_response.dart';
import '../models/banks_list_response.dart';
import '../services/api_service.dart';
import '../services/session_storage_service.dart';

class BankProvider extends ChangeNotifier {
  List<BankAccount> _accounts = [];
  List<BankInfo> _banks = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<BankAccount> get accounts => _accounts;
  List<BankInfo> get banks => _banks;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  BankAccount? get activeAccount {
    try {
      return _accounts.firstWhere((a) => a.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAccounts() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final json = await ApiService.getDepositAccounts(token);
      final response = BankAccountsResponse.fromJson(json);
      _accounts = response.accounts;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _accounts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBanks() async {
    try {
      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final json = await ApiService.getBanksList(token);
      final response = BanksListResponse.fromJson(json);
      _banks = response.banks;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    if (_isSubmitting) return;
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.createDepositAccount(
        token,
        bankCode: bankCode,
        accountNumber: accountNumber,
      );

      await fetchAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String accountId) async {
    if (_isSubmitting) return;
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.deleteDepositAccount(token, accountId: accountId);

      _accounts.removeWhere((a) => a.id == accountId);
      notifyListeners();
      await fetchAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> activateAccount(String accountId) async {
    if (_isSubmitting) return;
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      final token = SessionStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ApiService.activateDepositAccount(token, accountId: accountId);

      // Locally update list to mark active and others inactive
      _accounts = _accounts
          .map((a) => a.id == accountId
              ? BankAccount(
                  id: a.id,
                  bankCode: a.bankCode,
                  bankName: a.bankName,
                  accountNumber: a.accountNumber,
                  isActive: true,
                  createdAt: a.createdAt,
                  updatedAt: DateTime.now(),
                )
              : BankAccount(
                  id: a.id,
                  bankCode: a.bankCode,
                  bankName: a.bankName,
                  accountNumber: a.accountNumber,
                  isActive: false,
                  createdAt: a.createdAt,
                  updatedAt: a.updatedAt,
                ))
          .toList();
      notifyListeners();

      await fetchAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void refresh() {
    _accounts = [];
    _error = null;
    notifyListeners();
  }
} 