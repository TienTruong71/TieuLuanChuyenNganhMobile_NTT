import 'package:flutter/material.dart';
import '../../data/repository.dart';
import '../service/service_dashboard.dart';
import '../inventory/inventory_dashboard.dart';
import '../sale/sale_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true; // Trạng thái ẩn/hiện mật khẩu

  final Color primaryColor = Color(0xFF0F62FE);
  final Color secondaryColor = Color(0xFF0043CE); // Màu đậm hơn để tạo gradient

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await Repository().login(_emailController.text, _passController.text);

      if (!mounted) return;

      Widget nextScreen;
      switch (user.roleName) {
        case 'service': nextScreen = ServiceDashboard(); break;
        case 'inventory': nextScreen = InventoryDashboard(); break;
        case 'sale': nextScreen = SaleDashboard(); break;
        default: throw Exception("Role không hợp lệ.");
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));

    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
        )
    );
  }

  // Input Style chuẩn "Big Tech"
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7), size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50], // Nền xám rất nhạt tạo độ nổi
      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Background tổng thể màu xám nhạt
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          child: Stack(
            children: [
              // 1. BACKGROUND HEADER (Gradient cong)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.garage_rounded, size: 60, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text("Gara Staff", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                      SizedBox(height: 8),
                      Text("Hệ thống quản lý vận hành", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      SizedBox(height: 40), // Đẩy nội dung lên trên
                    ],
                  ),
                ),
              ),

              // 2. FLOATING FORM CARD
              Positioned(
                top: size.height * 0.38, // Card đè lên Header một chút
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Đăng Nhập", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.grey[800])),
                      SizedBox(height: 30),

                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration("Email công việc", Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),

                      // Password
                      TextField(
                        controller: _passController,
                        obscureText: _obscureText,
                        decoration: _inputDecoration("Mật khẩu", Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      SizedBox(height: 30),

                      // Button Login (Gradient)
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. FOOTER INFO
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Phiên bản 1.0.0 • Powered by GaraSystem",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}