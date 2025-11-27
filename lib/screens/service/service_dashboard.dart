import 'package:flutter/material.dart';
import 'appointment_tab.dart';
import 'service_bay_tab.dart';
import 'repair_progress_tab.dart';
import '../profile/profile_screen.dart';

class ServiceDashboard extends StatefulWidget {
  @override
  _ServiceDashboardState createState() => _ServiceDashboardState();
}

class _ServiceDashboardState extends State<ServiceDashboard> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [AppointmentTab(), ServiceBayTab(), RepairProgressTab()];
  final List<String> _titles = ["Lịch hẹn", "Khoang xe", "Tiến độ"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none_rounded)),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.blue[100], child: Icon(Icons.person, size: 20, color: Colors.blue[800])),
            ),
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Lịch hẹn'),
          NavigationDestination(icon: Icon(Icons.garage_outlined), selectedIcon: Icon(Icons.garage), label: 'Khoang xe'),
          NavigationDestination(icon: Icon(Icons.timelapse_outlined), selectedIcon: Icon(Icons.timelapse), label: 'Tiến độ'),
        ],
      ),
    );
  }
}