import 'package:flutter/material.dart';
import '../../data/repository.dart'; // Đổi từ mock_data sang repository
import '../../models/index.dart';    // Sử dụng index models
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Khởi tạo Controller rỗng trước
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addrCtrl = TextEditingController();

  User? user;
  bool isEditing = false;
  bool isLoading = true; // Thêm trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Hàm tải thông tin User từ bộ nhớ máy (thông qua Repository)
  void _loadUser() async {
    try {
      final u = await Repository().getCurrentUser();
      if (mounted) {
        setState(() {
          user = u;
          // Fill dữ liệu vào Controller
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

    // Show loading hoặc disable nút khi đang lưu (tùy chọn)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));

    try {
      // 1. Gọi API update (Bạn cần đảm bảo Backend có API này và Repository đã implement)
      // Nếu Repository chưa có logic API thật cho updateProfile, nó sẽ chạy logic giả lập hoặc lỗi
      await Repository().updateProfile({
        "full_name": _nameCtrl.text,
        "phone": _phoneCtrl.text,
        "address": _addrCtrl.text,
      });

      // 2. Cập nhật thành công -> Update UI
      setState(() {
        isEditing = false;
        // Cập nhật lại object User cục bộ để hiển thị ngay
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
    // Gọi logout từ Repository (xóa token)
    await Repository().logout();

    // Chuyển về màn hình Login
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => LoginScreen()),
              (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Màn hình Loading
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    // 2. Màn hình Lỗi (nếu không lấy được user)
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

    // 3. Màn hình chính
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hồ sơ nhân viên"),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout, color: Colors.red))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[50],
              child: Text(
                  user!.fullName.isNotEmpty ? user!.fullName[0].toUpperCase() : "?",
                  style: TextStyle(fontSize: 40, color: Colors.blue, fontWeight: FontWeight.bold)
              ),
            ),
            SizedBox(height: 16),
            // Tên & Role
            Text(user!.fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
              child: Text(
                  user!.roleName.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
            ),
            SizedBox(height: 40),

            // Form thông tin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("THÔNG TIN LIÊN HỆ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                  SizedBox(height: 16),

                  // Các trường thông tin
                  // Email (Không cho sửa)
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [SizedBox(width: 100, child: Text("Email", style: TextStyle(color: Colors.grey[600]))), Expanded(child: Text(user!.email, style: TextStyle(fontWeight: FontWeight.w500)))]),
                  ),

                  _buildProfileField("Họ tên", _nameCtrl, isEditing),
                  _buildProfileField("Số điện thoại", _phoneCtrl, isEditing),
                  _buildProfileField("Địa chỉ", _addrCtrl, isEditing),

                  SizedBox(height: 30),

                  // Nút bấm
                  if (isEditing)
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(
                            onPressed: () {
                              // Reset lại dữ liệu nếu hủy
                              _nameCtrl.text = user!.fullName;
                              _phoneCtrl.text = user!.phone;
                              _addrCtrl.text = user!.address;
                              setState(() => isEditing = false);
                            },
                            child: Text("Hủy")
                        )),
                        SizedBox(width: 16),
                        Expanded(child: ElevatedButton(onPressed: _saveProfile, child: Text("Lưu thay đổi"))),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                          onPressed: () => setState(() => isEditing = true),
                          icon: Icon(Icons.edit_outlined),
                          label: Text("Chỉnh sửa hồ sơ")
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController ctrl, bool enabled) {
    if (!enabled) {
      // Chế độ xem: Hiển thị như Text
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
            Expanded(child: Text(ctrl.text, style: TextStyle(fontWeight: FontWeight.w500)))
          ],
        ),
      );
    } else {
      // Chế độ sửa: Hiển thị TextField
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always
          ),
        ),
      );
    }
  }
}