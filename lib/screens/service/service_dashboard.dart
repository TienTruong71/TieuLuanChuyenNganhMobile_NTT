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

  final List<Widget> _tabs = [
    AppointmentTab(),
    ServiceBayTab(),
    RepairProgressTab(),
  ];

  final List<String> _titles = [
    "Lịch Hẹn & Tiếp Nhận",
    "Khu Vực Sửa Chữa",
    "Tiến Độ Công Việc"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue[800]),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Lịch hẹn"),
          BottomNavigationBarItem(icon: Icon(Icons.garage), label: "Khoang xe"),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle), label: "Tiến độ"),
        ],
      ),
    );
  }
}