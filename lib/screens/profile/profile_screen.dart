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
    await MockData().updateProfile(fullName: _nameCtrl.text, phone: _phoneCtrl.text, address: _addrCtrl.text);
    setState(() { isEditing = false; user = MockData().currentUser; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
  }

  void _logout() {
    MockData().logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Scaffold(body: Center(child: Text("Lỗi user")));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Hồ sơ nhân viên"), actions: [IconButton(onPressed: _logout, icon: Icon(Icons.logout, color: Colors.red))]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            CircleAvatar(radius: 50, backgroundColor: Colors.blue[50], child: Text(user!.fullName[0], style: TextStyle(fontSize: 40, color: Colors.blue, fontWeight: FontWeight.bold))),
            SizedBox(height: 16),
            Text(user!.fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(margin: EdgeInsets.only(top: 8), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)), child: Text(user!.roleName.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("THÔNG TIN LIÊN HỆ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                SizedBox(height: 16),
                _buildProfileField("Email", _nameCtrl, false), // Email readonly
                _buildProfileField("Họ tên", _nameCtrl, isEditing),
                _buildProfileField("Số điện thoại", _phoneCtrl, isEditing),
                _buildProfileField("Địa chỉ", _addrCtrl, isEditing),
                SizedBox(height: 30),
                if (isEditing)
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => setState(() => isEditing = false), child: Text("Hủy"))),
                    SizedBox(width: 16),
                    Expanded(child: ElevatedButton(onPressed: _saveProfile, child: Text("Lưu thay đổi"))),
                  ])
                else
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => setState(() => isEditing = true), icon: Icon(Icons.edit_outlined), label: Text("Chỉnh sửa hồ sơ"))),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController ctrl, bool enabled) {
    if (!enabled) {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(children: [SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600]))), Expanded(child: Text(ctrl.text, style: TextStyle(fontWeight: FontWeight.w500)))]),
      );
    } else {
      return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: TextField(controller: ctrl, decoration: InputDecoration(labelText: label, floatingLabelBehavior: FloatingLabelBehavior.always)));
    }
  }
}