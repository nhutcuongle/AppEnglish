import 'package:flutter/material.dart';

class AppTheme {
  // Bảng màu mới: Indigo & Amber (Hiện đại, Sáng tạo & Năng động)
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600 - Màu xanh tím hiện đại
  static const Color secondaryColor = Color(0xFFF59E0B); // Amber 500 - Màu vàng cam ấm áp
  
  // Đã điều chỉnh màu nền tối hơn một chút để dịu mắt, không bị chói
  static const Color backgroundColor = Color(0xFFF0F2F5); // Xám khói (Smoke White) - Rất êm dịu
  
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800 - Đen xám
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 - Xám ghi

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar sạch, hiện đại
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      
      // Card được thiết kế lại mềm mại hơn
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, 
        shadowColor: const Color(0x1A000000), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: Colors.grey.shade200, width: 1), 
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),
      
      // Nút bấm nổi bật
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), 
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.4), 
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Input field thân thiện
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      
      // Bottom Nav Bar tinh tế
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      
      // Text Theme mặc định
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
    );
  }
}
