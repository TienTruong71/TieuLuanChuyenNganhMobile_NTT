import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
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

  void _fillCredentials(String email) {
    _emailController.text = email;
    _passController.text = "123456";
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await MockData().login(_emailController.text, _passController.text);
      Widget nextScreen;
      switch (user.roleName) {
        case 'service': nextScreen = ServiceDashboard(); break;
        case 'inventory': nextScreen = InventoryDashboard(); break;
        case 'sale': nextScreen = SaleDashboard(); break;
        default: throw Exception("Role không hợp lệ");
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
              // Logo Area
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(color: Color(0xFF0F62FE).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.garage_rounded, size: 40, color: Color(0xFF0F62FE)),
              ),
              SizedBox(height: 24),
              Text("Gara Staff", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text("Quản lý vận hành chuyên nghiệp", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 40),

              // Input Area
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email đăng nhập", prefixIcon: Icon(Icons.email_outlined))),
              SizedBox(height: 16),
              TextField(controller: _passController, obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu", prefixIcon: Icon(Icons.lock_outline))),
              SizedBox(height: 24),

              // Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("ĐĂNG NHẬP"),
              ),

              Spacer(),
              // Quick Login Tools (Dev Mode - Subtle Design)
              Text("Dev Quick Access:", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickLoginBtn("Service", "service@gara.com", Colors.blue),
                  _buildQuickLoginBtn("Kho", "kho@gara.com", Colors.orange),
                  _buildQuickLoginBtn("Sale", "sale@gara.com", Colors.green),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginBtn(String label, String email, Color color) {
    return TextButton(
      onPressed: () => _fillCredentials(email),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}