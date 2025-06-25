import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/user_list_provider.dart';
import '../providers/vip_provider.dart';
import '../models/user_list_response.dart';

class SearchField extends StatefulWidget {
  final Function(String) onSearch;

  const SearchField({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo username, số điện thoại hoặc ref ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _handleSearch,
      ),
    );
  }
}

class VipGrantDialog extends StatefulWidget {
  final UserListItem user;

  const VipGrantDialog({super.key, required this.user});

  @override
  State<VipGrantDialog> createState() => _VipGrantDialogState();
}

class _VipGrantDialogState extends State<VipGrantDialog> {
  String? _selectedPackageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch VIP packages when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VipProvider>(context, listen: false).fetchVipPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cấp gói VIP',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Người dùng: ${widget.user.username}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Chọn gói VIP:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<VipProvider>(
                builder: (context, vipProvider, child) {
                  if (vipProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vipProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lỗi: ${vipProvider.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vipProvider.fetchVipPackages(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final activePackages = vipProvider.packages
                      .where((package) => package.isActive)
                      .toList();

                  if (activePackages.isEmpty) {
                    return const Center(
                      child: Text('Không có gói VIP nào khả dụng'),
                    );
                  }

                  return ListView.builder(
                    itemCount: activePackages.length,
                    itemBuilder: (context, index) {
                      final package = activePackages[index];
                      return Card(
                        child: RadioListTile<String>(
                          title: Text(package.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giá: ${_formatPrice(package.price)}'),
                              Text(
                                  'Thời hạn: ${_formatDuration(package.duration)}'),
                              Text('Mô tả: ${package.description}'),
                            ],
                          ),
                          value: package.id,
                          groupValue: _selectedPackageId,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedPackageId = value;
                                  });
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isLoading || _selectedPackageId == null)
                      ? null
                      : _grantVip,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cấp VIP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }

  String _formatDuration(int duration) {
    if (duration < 30) {
      return '$duration ngày';
    } else if (duration < 365) {
      final months = (duration / 30).round();
      return '$months tháng';
    } else {
      final years = (duration / 365).round();
      return '$years năm';
    }
  }

  Future<void> _grantVip() async {
    if (_selectedPackageId == null) return;

    setState(() => _isLoading = true);

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        await Provider.of<UserListProvider>(context, listen: false)
            .grantUserVip(token, widget.user.id, _selectedPackageId!);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cấp gói VIP cho ${widget.user.username}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        log('Lỗi cấp gói VIP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class UserListTable extends StatelessWidget {
  final List<UserListItem> users;
  final Function(UserListItem) onCancelVip;
  final Function(UserListItem) onGrantVip;

  const UserListTable({
    super.key,
    required this.users,
    required this.onCancelVip,
    required this.onGrantVip,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('VIP')),
            DataColumn(label: Text('Ref ID')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('VIP Package')),
            DataColumn(label: Text('Remaining Days')),
            DataColumn(label: Text('Valid Until')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.username)),
                DataCell(Text(user.phoneNumber)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getVipColor(user),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.vip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(user.refId)),
                DataCell(
                  Text(
                    user.balance.toString(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(user.vipInfo?.package?.name ?? '-')),
                DataCell(Text(user.vipInfo?.remainingDays?.toString() ?? '-')),
                DataCell(Text(user.vipInfo?.endDate != null
                    ? _formatDate(user.vipInfo!.endDate!)
                    : '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.vipInfo?.isActive == true)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Hủy VIP',
                          onPressed: () => onCancelVip(user),
                        ),
                      IconButton(
                        icon: const Icon(Icons.diamond, color: Colors.amber),
                        tooltip: 'Cấp VIP',
                        onPressed: () => onGrantVip(user),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getVipColor(UserListItem user) {
    // If user has no VIP or VIP 0, return grey
    if (user.vipInfo?.package?.id == null || user.vip == 'VIP 0') {
      return Colors.grey;
    }

    // Use package ID for consistent color mapping
    switch (user.vipInfo!.package!.id) {
      case '6848ffdc72a3ffbe01ecca8e': // VIP package 1 (was VIP 1, now VIP 1111)
        return Colors.blue;
      case '6848ffdc72a3ffbe01ecca8f': // VIP package 2
        return Colors.purple;
      case '6848ffdc72a3ffbe01ecca90': // VIP package 3
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class UserListTab extends StatefulWidget {
  const UserListTab({super.key});

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch users when tab is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<UserListProvider>().fetchUsers(token);
      }
    });
  }

  void _handleSearch(String value) {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<UserListProvider>().searchUsers(token, value);
    }
  }

  void _handleCancelVip(UserListItem user) {
    _showCancelVipDialog(user);
  }

  void _handleGrantVip(UserListItem user) {
    _showGrantVipDialog(user);
  }

  void _showCancelVipDialog(UserListItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy gói VIP'),
        content: Text(
          'Bạn có chắc chắn muốn hủy gói VIP hiện tại của người dùng "${user.username}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => _confirmCancelVip(user),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showGrantVipDialog(UserListItem user) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Provider.of<VipProvider>(context, listen: false),
          ),
          ChangeNotifierProvider.value(
            value: Provider.of<UserListProvider>(context, listen: false),
          ),
          ChangeNotifierProvider.value(
            value: Provider.of<AuthProvider>(context, listen: false),
          ),
        ],
        child: VipGrantDialog(user: user),
      ),
    );
  }

  Future<void> _confirmCancelVip(UserListItem user) async {
    try {
      Navigator.of(context).pop(); // Close dialog

      final token = context.read<AuthProvider>().token;
      if (token != null) {
        await context.read<UserListProvider>().cancelUserVip(token, user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã hủy gói VIP của ${user.username}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        SearchField(onSearch: _handleSearch),
        Expanded(
          child: Consumer<UserListProvider>(
            builder: (context, userListProvider, child) {
              if (userListProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userListProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${userListProvider.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) {
                            userListProvider.fetchUsers(token);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return UserListTable(
                users: userListProvider.users,
                onCancelVip: _handleCancelVip,
                onGrantVip: _handleGrantVip,
              );
            },
          ),
        ),
      ],
    );
  }
}
