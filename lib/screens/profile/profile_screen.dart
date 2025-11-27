import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addrCtrl;
  User? user;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    user = MockData().currentUser;
    _nameCtrl = TextEditingController(text: user?.fullName);
    _phoneCtrl = TextEditingController(text: user?.phone);
    _addrCtrl = TextEditingController(text: user?.address);
  }

  void _saveProfile() async {
    await MockData().updateProfile(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      address: _addrCtrl.text,
    );
    setState(() {
      isEditing = false;
      user = MockData().currentUser; // Refresh
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
  }

  void _logout() {
    MockData().logout();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => LoginScreen()),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Scaffold(body: Center(child: Text("Lỗi user")));

    return Scaffold(
      appBar: AppBar(title: Text("Thông tin cá nhân"), backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, backgroundColor: Colors.blue[100], child: Text(user!.fullName[0], style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            Text(user!.email, style: TextStyle(color: Colors.grey)),
            Text("Role: ${user!.roleName.toUpperCase()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
            Divider(height: 30),

            // Form fields
            _buildTextField("Họ và tên", _nameCtrl, isEditing),
            _buildTextField("Số điện thoại", _phoneCtrl, isEditing),
            _buildTextField("Địa chỉ", _addrCtrl, isEditing),

            SizedBox(height: 20),
            if (isEditing)
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => setState(() => isEditing = false), child: Text("Hủy"))),
                  SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: _saveProfile, child: Text("Lưu"))),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => setState(() => isEditing = true),
                icon: Icon(Icons.edit),
                label: Text("Chỉnh sửa thông tin"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
              ),

            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                // Show change password dialog
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tính năng đổi mật khẩu (Dialog)...")));
              },
              icon: Icon(Icons.lock),
              label: Text("Đổi mật khẩu"),
              style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),

            SizedBox(height: 30),
            TextButton(
              onPressed: _logout,
              child: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: !enabled,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}