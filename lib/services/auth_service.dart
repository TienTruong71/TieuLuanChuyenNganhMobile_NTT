import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';
import 'api_config.dart';

class AuthService {
  // Hàm đăng nhập
  Future<User> login(String email, String password) async {
    try {
      final response = await ApiConfig.dio.post('/client/auth/login', data: {
        "email": email,
        "password": password,
      });

      final data = response.data;

      // --- SỬA LỖI TẠI ĐÂY ---
      // Token lấy từ root
      final String token = data['token'] ?? '';

      // Kiểm tra xem user info nằm ở root hay trong key 'user'
      Map<String, dynamic> userData = {};

      if (data['user'] != null && data['user'] is Map) {
        // Trường hợp 1: { "token": "...", "user": { ... } }
        userData = data['user'];
      } else {
        // Trường hợp 2 (Của bạn): { "token": "...", "role": "service", ... }
        // Dữ liệu user chính là data trả về
        userData = Map<String, dynamic>.from(data);
      }

      // Parse JSON sang Model
      User user = User.fromJson(userData);

      // Gán token (quan trọng để gọi các API sau này)
      user.token = token;

      // In log để kiểm tra Role đã nhận đúng chưa
      print("LOGIN SUCCESS: ${user.email} - Role: ${user.roleName}");

      // Lưu xuống máy
      await _saveUserToLocal(user);

      return user;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "Đăng nhập thất bại");
      } else {
        throw Exception("Lỗi kết nối Server. Vui lòng kiểm tra mạng/IP.");
      }
    } catch (e) {
      throw Exception("Lỗi không xác định: $e");
    }
  }

  Future<void> _saveUserToLocal(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token ?? '');
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    final token = prefs.getString('token');

    if (userJson != null && token != null) {
      User user = User.fromJson(jsonDecode(userJson));
      user.token = token;
      return user;
    }
    return null;
  }
}