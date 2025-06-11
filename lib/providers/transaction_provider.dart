import 'package:flutter/foundation.dart';
import '../models/transaction_response.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 10;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get limit => _limit;

  Future<void> fetchTransactions(String token) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getTransactions(
        token,
        page: _currentPage,
        limit: _limit,
      );

      _transactions = response.transactions;
      _totalPages = response.totalPages;
      _totalItems = response.totalItems;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _transactions = [];
      _totalPages = 1;
      _totalItems = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage(String token) async {
    if (_isLoading || _currentPage >= _totalPages) return;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.getTransactions(
        token,
        page: _currentPage + 1,
        limit: _limit,
      );

      _transactions.addAll(response.transactions);
      _currentPage++;
      _totalPages = response.totalPages;
      _totalItems = response.totalItems;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String token) async {
    _currentPage = 1;
    _transactions = [];
    _error = null;
    await fetchTransactions(token);
  }

  Future<void> updateTransactionStatus(
    String token,
    String transactionId,
    String status,
  ) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      await ApiService.updateTransactionStatus(token, transactionId, status);

      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index] = _transactions[index].copyWith(status: status);
        notifyListeners();
      }

      await refresh(token);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  void reset() {
    _transactions = [];
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    notifyListeners();
  }
}
