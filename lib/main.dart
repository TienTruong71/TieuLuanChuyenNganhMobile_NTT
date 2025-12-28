import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'screens/login/login_screen.dart'; // Đường dẫn tới màn hình Login

void main() {
  runApp(const GaraStaffApp());
}

class GaraStaffApp extends StatelessWidget {
  const GaraStaffApp({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF0F62FE);
  static const Color secondaryColor = Color(0xFF0043CE);
  static const Color surfaceColor = Color(0xFFF4F7FE); // Màu nền xám xanh rất nhạt, sang trọng hơn trắng tinh

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gara Staff Professional',
      debugShowCheckedModeBanner: false,

      // --- CẤU HÌNH THEME CHUẨN 2025 ---
      theme: ThemeData(
        useMaterial3: true, // Bắt buộc cho Style 2025

        // 1. Cấu hình Màu sắc
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: surfaceColor,
          surface: Colors.white,
        ),

        // 2. Cấu hình Font chữ (Dùng 'Inter' hoặc 'Poppins' cho hiện đại)
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF161616), // Màu chữ đen dịu (không đen tuyền)
          displayColor: const Color(0xFF161616),
        ),

        // 3. Cấu hình Input mặc định (Để không phải viết lại decoration ở mọi nơi)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),

        // 4. Cấu hình Button mặc định
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: primaryColor.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),

        // 5. Cấu hình AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),

        // 6. Hiệu ứng chuyển trang (Page Transitions)
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(), // Hiệu ứng phóng to mượt mà của Android 12+
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      home: LoginScreen(),
    );
  }
}