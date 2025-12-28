import 'package:flutter/material.dart';
import '../../data/repository.dart';
import '../../models/index.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addrCtrl = TextEditingController();

  User? user;
  bool isEditing = false;
  bool isLoading = true;
  final Color primaryColor = Color(0xFF0F62FE);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      final u = await Repository().getCurrentUser();
      if (mounted) {
        setState(() {
          user = u;
          if (user != null) {
            _nameCtrl.text = user!.fullName;
            _phoneCtrl.text = user!.phone;
            _addrCtrl.text = user!.address;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _saveProfile() async {
    if (user == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));

    try {
      await Repository().updateProfile({
        "full_name": _nameCtrl.text,
        "phone": _phoneCtrl.text,
        "address": _addrCtrl.text,
      });

      setState(() {
        isEditing = false;
        user = User(
            id: user!.id,
            fullName: _nameCtrl.text,
            phone: _phoneCtrl.text,
            address: _addrCtrl.text,
            email: user!.email,
            roleName: user!.roleName,
            token: user!.token
        );
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green));

    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  void _logout() async {
    await Repository().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => LoginScreen()),
              (route) => false
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryColor)));

    if (user == null) return Scaffold(
        appBar: AppBar(title: Text("Lỗi")),
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Không tìm thấy thông tin người dùng"),
            TextButton(onPressed: _logout, child: Text("Quay lại đăng nhập"))
          ],
        ))
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text("Hồ sơ nhân viên", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                          user!.fullName.isNotEmpty ? user!.fullName[0].toUpperCase() : "?",
                          style: TextStyle(fontSize: 40, color: primaryColor, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(user!.fullName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        user!.roleName.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Form Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                      SizedBox(width: 8),
                      Text("THÔNG TIN LIÊN HỆ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                    ],
                  ),
                  SizedBox(height: 16),

                  _buildInfoCard(Icons.email_outlined, "Email", user!.email, isEditable: false),
                  SizedBox(height: 12),

                  if (isEditing) ...[
                    TextField(controller: _nameCtrl, decoration: _inputDecoration("Họ tên", Icons.person_outline)),
                    SizedBox(height: 12),
                    TextField(controller: _phoneCtrl, decoration: _inputDecoration("Số điện thoại", Icons.phone_outlined), keyboardType: TextInputType.phone),
                    SizedBox(height: 12),
                    TextField(controller: _addrCtrl, decoration: _inputDecoration("Địa chỉ", Icons.location_on_outlined)),
                  ] else ...[
                    _buildInfoCard(Icons.person_outline, "Họ tên", user!.fullName),
                    SizedBox(height: 12),
                    _buildInfoCard(Icons.phone_outlined, "Số điện thoại", user!.phone),
                    SizedBox(height: 12),
                    _buildInfoCard(Icons.location_on_outlined, "Địa chỉ", user!.address),
                  ],

                  SizedBox(height: 32),

                  // Action Buttons
                  if (isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              _nameCtrl.text = user!.fullName;
                              _phoneCtrl.text = user!.phone;
                              _addrCtrl.text = user!.address;
                              setState(() => isEditing = false);
                            },
                            child: Text("Hủy", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: _saveProfile,
                            child: Text("Lưu thay đổi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryColor.withOpacity(0.5))),
                        ),
                        onPressed: () => setState(() => isEditing = true),
                        icon: Icon(Icons.edit_outlined),
                        label: Text("Chỉnh sửa hồ sơ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, {bool isEditable = true}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEditable ? primaryColor.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isEditable ? primaryColor : Colors.grey[500], size: 22),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                SizedBox(height: 4),
                Text(value.isNotEmpty ? value : "Chưa cập nhật", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}