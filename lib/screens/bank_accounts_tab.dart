import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';

class BankAccountsTab extends StatefulWidget {
  const BankAccountsTab({super.key});

  @override
  State<BankAccountsTab> createState() => _BankAccountsTabState();
}

class _BankAccountsTabState extends State<BankAccountsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BankProvider>();
      provider.fetchAccounts();
      provider.fetchBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, provider, _) {
        final body = () {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text('Lỗi: ${provider.error}'),
            );
          }
          final accounts = provider.accounts;
          if (accounts.isEmpty) {
            return const Center(child: Text('Không có tài khoản ngân hàng'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final acc = accounts[index];
                final isActive = acc.isActive;
                return Card(
                  elevation: isActive ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isActive ? Colors.green : Colors.grey.shade300,
                      width: isActive ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isActive ? Icons.check_circle : Icons.account_balance,
                      color: isActive ? Colors.green : null,
                    ),
                    title: Text('${acc.bankName}'),
                    subtitle: Text('Số tài khoản: ${acc.accountNumber}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          const Chip(
                            label: Text('Đang hoạt động'),
                            backgroundColor: Colors.greenAccent,
                          ),
                        if (!isActive)
                          TextButton.icon(
                            onPressed: () => _confirmAndActivate(context, acc.id),
                            icon: const Icon(Icons.flash_on, color: Colors.orange),
                            label: const Text('Kích hoạt'),
                          ),
                        if (!isActive)
                          IconButton(
                            tooltip: 'Xóa',
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmAndDelete(context, acc.id),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddBankDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Thêm bank'),
          ),
          body: body,
        );
      },
    );
  }

  Future<void> _confirmAndActivate(BuildContext context, String accountId) async {
    final provider = context.read<BankProvider>();
    bool submitting = false;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kích hoạt tài khoản?'),
          content: const Text('Tài khoản này sẽ được đặt làm mặc định hoạt động.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      try {
                        setState(() => submitting = true);
                        await provider.activateAccount(accountId);
                        if (context.mounted) Navigator.of(context).pop();
                      } finally {
                        if (mounted) setState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kích hoạt'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, String accountId) async {
    final provider = context.read<BankProvider>();
    bool submitting = false;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xóa tài khoản?'),
          content: const Text('Bạn có chắc chắn muốn xóa tài khoản ngân hàng này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: submitting
                  ? null
                  : () async {
                      try {
                        setState(() => submitting = true);
                        await provider.deleteAccount(accountId);
                        if (context.mounted) Navigator.of(context).pop();
                      } finally {
                        if (mounted) setState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddBankDialog(BuildContext context) async {
    final provider = context.read<BankProvider>();
    String? selectedBankCode;
    String? selectedBankName;
    final TextEditingController accountController = TextEditingController();
    final TextEditingController bankFieldController = TextEditingController();
    bool submitting = false;

    Future<void> openBankPicker() async {
      String searchText = '';
      await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final filtered = provider.banks
                  .where((b) => b.bankName
                      .toLowerCase()
                      .contains(searchText.toLowerCase()))
                  .toList();
              return AlertDialog(
                title: const Text('Chọn ngân hàng'),
                content: SizedBox(
                  width: 420,
                  height: 420,
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Tìm kiếm ngân hàng',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => searchText = v),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final b = filtered[index];
                            return ListTile(
                              title: Text(b.bankName),
                              subtitle: Text('Mã: ${b.bankCode}'),
                              onTap: () {
                                selectedBankCode = b.bankCode;
                                selectedBankName = b.bankName;
                                bankFieldController.text = b.bankName;
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm tài khoản ngân hàng'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: bankFieldController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Ngân hàng',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: openBankPicker,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: accountController,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if ((selectedBankCode ?? '').isEmpty || accountController.text.trim().isEmpty) {
                            return;
                          }
                          try {
                            setState(() => submitting = true);
                            await provider.createAccount(
                              bankCode: selectedBankCode!,
                              accountNumber: accountController.text.trim(),
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          } catch (_) {
                          } finally {
                            if (mounted) setState(() => submitting = false);
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 