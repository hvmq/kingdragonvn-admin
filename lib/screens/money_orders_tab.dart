import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_response.dart';

class MoneyOrdersTab extends StatefulWidget {
  const MoneyOrdersTab({super.key});

  @override
  State<MoneyOrdersTab> createState() => _MoneyOrdersTabState();
}

class _MoneyOrdersTabState extends State<MoneyOrdersTab> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'all';
  bool _isInitialized = false;
  String? _processingTransactionId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      await context.read<TransactionProvider>().fetchTransactions(token);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      await context.read<TransactionProvider>().loadNextPage(token);
    }
  }

  Future<void> _handleStatusUpdate(String transactionId, String status) async {
    if (!mounted) return;
    print('handleStatusUpdate - Transaction ID: $transactionId');
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      setState(() {
        _processingTransactionId = transactionId;
      });
      try {
        await context.read<TransactionProvider>().updateTransactionStatus(
              token,
              transactionId,
              status,
            );
        await _loadInitialData();
      } finally {
        if (mounted) {
          setState(() {
            _processingTransactionId = null;
          });
        }
      }
    }
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    switch (_selectedCategory) {
      case 'pending':
        return transactions.where((t) => t.status == 'pending').toList();
      case 'approved':
        return transactions.where((t) => t.status == 'approved').toList();
      case 'rejected':
        return transactions.where((t) => t.status == 'rejected').toList();
      default:
        return transactions;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chưa duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final transactions = _getFilteredTransactions(provider.transactions);

        if (provider.error != null && provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: _selectedCategory == 'all',
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() => _selectedCategory = 'all');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Chưa duyệt'),
                    selected: _selectedCategory == 'pending',
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() => _selectedCategory = 'pending');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Đã duyệt'),
                    selected: _selectedCategory == 'approved',
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() => _selectedCategory = 'approved');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Từ chối'),
                    selected: _selectedCategory == 'rejected',
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() => _selectedCategory = 'rejected');
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadInitialData,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Số tiền')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Ref ID')),
                        DataColumn(label: Text('Thời gian')),
                        DataColumn(label: Text('Trạng thái')),
                        DataColumn(label: Text('Thao tác')),
                      ],
                      rows: transactions.map((transaction) {
                        print(
                            'transaction - Transaction ID: ${transaction.id}');
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${transaction.amount.toStringAsFixed(0)}đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(transaction.user.username)),
                            DataCell(Text(transaction.user.refId)),
                            DataCell(Text(_formatDate(transaction.createdAt))),
                            DataCell(
                              Text(
                                transaction.status,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              transaction.status == 'pending'
                                  ? _processingTransactionId == transaction.id
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  _handleStatusUpdate(
                                                transaction.id,
                                                'approved',
                                              ),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                minimumSize: Size.zero,
                                              ),
                                              child: const Text(
                                                'Duyệt',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () =>
                                                  _handleStatusUpdate(
                                                transaction.id,
                                                'rejected',
                                              ),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                minimumSize: Size.zero,
                                              ),
                                              child: const Text(
                                                'Từ chối',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
