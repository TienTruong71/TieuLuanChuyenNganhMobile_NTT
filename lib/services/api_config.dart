// lib/services/api_config.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
   // 1. Nếu chạy máy ảo Android (Emulator): Dùng 'http://10.0.2.2:5000/api'
  // 2. Nếu chạy máy ảo iOS (Simulator): Dùng 'http://localhost:5000/api'
  // 3. Nếu chạy trên điện thoại thật: Dùng IP LAN của máy tính (VD: 'http://192.168.1.15:5000/api')
  static const String baseUrl = "http://localhost:5000/api";

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          // DEBUG – bạn có thể xóa sau
          print("INTERCEPTOR TOKEN: $token");

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
        onError: (DioException e, handler) {
          print(
              "API ERROR: ${e.response?.statusCode} - ${e.response?.data}");
          handler.next(e);
        },
      ),
    );
}
