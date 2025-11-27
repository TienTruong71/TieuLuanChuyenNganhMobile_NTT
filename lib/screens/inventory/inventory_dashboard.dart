import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';

class InventoryDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kho Phụ Tùng"),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
            child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.orange[800])),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Center(child: Text("Chức năng đang phát triển cho Inventory Staff")),
    );
  }
}