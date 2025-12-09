// lib/services/api_config.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // 1. Nếu chạy máy ảo Android (Emulator): Dùng 'http://10.0.2.2:5000/api'
  // 2. Nếu chạy máy ảo iOS (Simulator): Dùng 'http://localhost:5000/api'
  // 3. Nếu chạy trên điện thoại thật: Dùng IP LAN của máy tính (VD: 'http://192.168.1.15:5000/api')

  static const String baseUrl = "http://localhost:5000/api/";
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 15), // Thời gian chờ kết nối
    receiveTimeout: Duration(seconds: 15), // Thời gian chờ nhận dữ liệu
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  ));

  static Dio get dio {
    // Thêm Interceptor để tự động gắn Token vào mỗi request
    _dio.interceptors.clear(); // Xóa cũ để tránh trùng lặp
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ bộ nhớ
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log lỗi ra console để debug
        print("API ERROR: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
    return _dio;
  }
}