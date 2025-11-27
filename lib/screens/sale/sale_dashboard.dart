// lib/screens/sale/sale_dashboard.dart
import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'contract_tab.dart';
import 'feedback_tab.dart';
import 'support_tab.dart';

class SaleDashboard extends StatefulWidget {
  @override
  _SaleDashboardState createState() => _SaleDashboardState();
}

class _SaleDashboardState extends State<SaleDashboard> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    ContractTab(),
    FeedbackTab(),
    SupportTab(),
  ];

  final List<String> _titles = [
    "Quản lý Hợp đồng",
    "Phản hồi Khách hàng",
    "Yêu cầu Hỗ trợ"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.green[800], // Màu xanh lá cho Sale
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
            child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.green[800])),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Hợp đồng"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Feedback"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Hỗ trợ"),
        ],
      ),
    );
  }
}