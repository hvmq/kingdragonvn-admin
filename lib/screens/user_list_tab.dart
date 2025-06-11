import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/user_list_provider.dart';
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

class UserListTable extends StatelessWidget {
  final List<UserListItem> users;

  const UserListTable({
    super.key,
    required this.users,
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
                      color: _getVipColor(user.vip),
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
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getVipColor(String vip) {
    switch (vip) {
      case 'VIP 0':
        return Colors.grey;
      case 'VIP 1':
        return Colors.blue;
      case 'VIP 2':
        return Colors.purple;
      case 'VIP 3':
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

              return UserListTable(users: userListProvider.users);
            },
          ),
        ),
      ],
    );
  }
}
