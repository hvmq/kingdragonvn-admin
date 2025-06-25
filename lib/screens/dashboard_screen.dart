import 'package:admin_kingdragonvn/screens/money_orders_tab.dart';
import 'package:admin_kingdragonvn/screens/user_list_tab.dart';
import 'package:admin_kingdragonvn/screens/vip_packages_tab.dart';
import 'package:admin_kingdragonvn/widgets/profile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_list_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/vip_provider.dart';

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
