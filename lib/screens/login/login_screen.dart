import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../service/service_dashboard.dart';
import '../inventory/inventory_dashboard.dart'; // File mới
import '../sale/sale_dashboard.dart'; // File mới

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  // Hàm helper để điền nhanh info test
  void _fillCredentials(String email) {
    _emailController.text = email;
    _passController.text = "123456";
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await MockData().login(_emailController.text, _passController.text);

      // Routing Logic (Phân quyền)
      Widget nextScreen;
      switch (user.roleName) {
        case 'service':
          nextScreen = ServiceDashboard();
          break;
        case 'inventory':
          nextScreen = InventoryDashboard();
          break;
        case 'sale':
          nextScreen = SaleDashboard();
          break;
        default:
          throw Exception("Role không hợp lệ");
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
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.garage, size: 80, color: Colors.blue[800]),
              SizedBox(height: 16),
              Text("GARA STAFF APP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              SizedBox(height: 40),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
              SizedBox(height: 16),
              TextField(controller: _passController, obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
              Text("--- Quick Login (Dev Mode) ---", style: TextStyle(color: Colors.grey)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => _fillCredentials('service@gara.com'), child: Text("Service")),
                  TextButton(onPressed: () => _fillCredentials('kho@gara.com'), child: Text("Inventory")),
                  TextButton(onPressed: () => _fillCredentials('sale@gara.com'), child: Text("Sale")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}