import 'package:admin_kingdragonvn/screens/money_orders_tab.dart';
import 'package:admin_kingdragonvn/screens/user_list_tab.dart';
import 'package:admin_kingdragonvn/screens/vip_packages_tab.dart';
import 'package:admin_kingdragonvn/screens/notification_tab.dart';
import 'package:admin_kingdragonvn/widgets/profile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_list_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/vip_provider.dart';
import '../providers/bank_provider.dart';
import '../providers/notification_provider.dart';
import 'bank_accounts_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserListProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => VipProvider()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Scaffold(
        appBar: const ProfileAppBar(),
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.money),
                  label: Text('Giao dịch'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Danh sách người dùng'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.diamond),
                  label: Text('Gói VIP'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance),
                  label: Text('Bank'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications),
                  label: Text('Thông báo'),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  MoneyOrdersTab(),
                  UserListTab(),
                  VipPackagesTab(),
                  BankAccountsTab(),
                  NotificationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
