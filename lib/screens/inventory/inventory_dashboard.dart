import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'inventory_list_tab.dart';
import 'stock_transaction_tab.dart';
import 'stock_history_tab.dart';

class InventoryDashboard extends StatefulWidget {
  @override
  _InventoryDashboardState createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [InventoryListTab(), StockTransactionTab(), StockHistoryTab()];
  final List<String> _titles = ["Tồn Kho & Sản Phẩm", "Nhập / Xuất Kho", "Lịch Sử Giao Dịch"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.orange[50], child: Icon(Icons.person, size: 20, color: Colors.orange[800])),
            ),
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: Colors.orange[100],
        destinations: [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2, color: Colors.orange[800]), label: "Tồn kho"),
          NavigationDestination(icon: Icon(Icons.swap_horiz_outlined), selectedIcon: Icon(Icons.swap_horiz, color: Colors.orange[800]), label: "Nhập/Xuất"),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Colors.orange[800]), label: "Lịch sử"),
        ],
      ),
    );
  }
}