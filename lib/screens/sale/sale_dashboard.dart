import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'contract_tab.dart';
import 'feedback_tab.dart';
import 'support_tab.dart';
import 'test_drive_tab.dart';

class SaleDashboard extends StatefulWidget {
  @override
  _SaleDashboardState createState() => _SaleDashboardState();
}

class _SaleDashboardState extends State<SaleDashboard> {
  int _currentIndex = 0;

  List<Widget> get _tabs => [TestDriveTab(), FeedbackTab(), SupportTab()];
  List<String> get _titles => ["Lịch Lái Thử", "Phản Hồi Khách Hàng", "Hỗ Trợ & Tư Vấn"];

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
              child: CircleAvatar(radius: 16, backgroundColor: Colors.green[50], child: Icon(Icons.person, size: 20, color: Colors.green[800])),
            ),
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: Colors.green[100],
        destinations: [
          NavigationDestination(icon: Icon(Icons.drive_eta_outlined), selectedIcon: Icon(Icons.drive_eta, color: Colors.green[800]), label: "Lái thử"),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star, color: Colors.green[800]), label: "Feedback"),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent, color: Colors.green[800]), label: "Hỗ trợ"),
        ],
      ),
    );
  }
}